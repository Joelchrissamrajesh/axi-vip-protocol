class xtn extends uvm_sequence_item;

	`uvm_object_utils(xtn)

	//Write Address Signals
rand    bit rst1;
rand    bit AWCLOCK;
rand	bit [3:0] AWID;   //to match responses with requests
rand	bit [31:0] AWADDR;
rand	bit [7:0] AWLEN;  //indicates no. of beats
rand	bit [2:0] AWSIZE;  //size of each beat
rand	bit [1:0] AWBURST;  //0-fixed, 1-incr, 2-wrap
	bit AWVALID;    //asserted by sender
	bit AWREADY;    //asserted by receiver
 

	//Write Data Channels Signals
rand	bit [3:0] WID;
rand	bit [31:0] WDATA[];
	bit [3:0] WSTRB[];
rand	bit WLAST;
	bit WVALID;
	bit WREADY;

	//Write Response Channel Signals
rand	bit [3:0] BID;
	bit [1:0] BRESP;
	bit BVALID;
	bit BREADY;
//        logic BUSER;
	
	// Read Address Channel Signals
rand	bit [3:0] ARID;
rand	bit [31:0] ARADDR;
rand	bit [7:0] ARLEN;
rand	bit [2:0] ARSIZE;
rand	bit [1:0] ARBURST;
	bit ARVALID;
	bit ARREADY;


	//Read Data Channel Signals
rand	bit [3:0] RID;
rand	bit [31:0] RDATA[];
	bit [1:0] RRESP[];
	bit RLAST;
	bit RVALID;
	bit RREADY;


bit [31:0]waddr[];
int no_wbytes;
int aligned_waddr;
int start_waddr;

bit [31:0]raddr[];
int no_rbytes;
int aligned_raddr;
int start_raddr;

rand bit [1:0]write_slave;
rand bit [1:0]read_slave;

constraint valid_Master_addr{
			(write_slave==0) -> AWADDR inside {[32'h0000_0000:32'h00ff_ffff]};
			(write_slave==1) -> AWADDR inside {[32'h0100_0000:32'h01ff_ffff]};
			(write_slave==2) -> AWADDR inside {[32'h0200_0000:32'h02ff_ffff]};
			(write_slave==3) -> AWADDR inside {[32'h0300_0000:32'h03ff_ffff]};
			    }	

constraint valid_slave_addr{
			(read_slave==0) -> ARADDR inside {[32'h0000_0000:32'h00ff_ffff]};
			(read_slave==1) -> ARADDR inside {[32'h0100_0000:32'h01ff_ffff]};
			(read_slave==2) -> ARADDR inside {[32'h0200_0000:32'h02ff_ffff]};
			(read_slave==3) -> ARADDR inside {[32'h0300_0000:32'h03ff_ffff]};
			   }	
					
constraint wdata_c{WDATA.size()==(AWLEN+1);}

constraint rdata_c{RDATA.size()==(ARLEN+1);}

constraint awb{AWBURST dist{0:=10, 1:=10, 2:=10};}

constraint arb{ARBURST dist{0:=10, 1:=10, 2:=10};}

constraint write_id{AWID==WID; BID==WID;}

constraint read_id{RID==ARID;}

constraint aws{AWSIZE dist{0:=10, 1:=10, 2:=10};}

constraint ars{ARSIZE dist{0:=10, 1:=10, 2:=10};}

constraint awl{if(AWBURST==2) 
			(AWLEN+1) inside {2,4,8,16};}

constraint arl{if(ARBURST==2) 
			(ARLEN+1) inside {2,4,8,16};}

constraint write_alignment2{((AWBURST==2'b10 || AWBURST==2'b00) && AWSIZE==1) -> AWADDR%2==0;}//0,2,4,6,8

constraint write_alignment4{((AWBURST==2'b10 || AWBURST==2'b00) && AWSIZE==2) -> AWADDR%4==0;}//0,4,8,12.16

constraint read_alignment2{((ARBURST==2'b10 || ARBURST==2'b00) && ARSIZE==1) -> ARADDR%2==0;}//0,2,4,6,8

constraint read_alignment4{((ARBURST==2'b10 || ARBURST==2'b00) && ARSIZE==2) -> ARADDR%4==0;}//0,4,8,12.16

constraint max_w{(2**AWSIZE)*(AWLEN+1)<4096;}

constraint max_r{(2**ARSIZE)*(ARLEN+1)<4096;}

constraint awlen{AWLEN inside {[1:15]};}

constraint arlen{ARLEN inside {[1:15]};}

function void calc_waddr();

	bit wb;

	int burst_len=AWLEN+1;

	int no_wbytes=2**AWSIZE;

	int N=burst_len;

	int wrap_boundary=(int'(AWADDR/(no_wbytes*burst_len)))*(no_wbytes*burst_len);

	int addr_n=(wrap_boundary+(no_wbytes*burst_len));

	waddr=new[AWLEN+1];

	waddr[0]=AWADDR;

	aligned_waddr=(int'(AWADDR/no_wbytes))*no_wbytes;
	start_waddr=AWADDR;

	for(int i=2;i<(burst_len+1);i++)
	begin
		if(AWBURST==0)
			waddr[i-1]=AWADDR;

		if(AWBURST==1)
			waddr[i-1]=aligned_waddr+(i-1)*no_wbytes;

		if(AWBURST==2)
			begin
				if(wb==0)	
					begin
						waddr[i-1]=aligned_waddr+(i-1)*no_wbytes;	
							if(waddr[i-1]==(wrap_boundary+(no_wbytes*burst_len)))

							begin
								waddr[i-1]=wrap_boundary;
								wb++;
							end

					end
				else	
					waddr[i-1]=start_waddr+((i-1)*no_wbytes)-(no_wbytes*burst_len);
			end

	end

endfunction: calc_waddr
	
function void strb_calc();

	int data_bus_bytes=4;

	int lower_byte_lane, upper_byte_lane;

	int lower_byte_lane_0=start_waddr-((int'(start_waddr/data_bus_bytes))*data_bus_bytes);

	int upper_byte_lane_0=(aligned_waddr+(no_wbytes-1))-((int'(start_waddr/data_bus_bytes))*data_bus_bytes);
	
	for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
	begin
		WSTRB[0][j]=1;
	end

	for(int i=1;i<(AWLEN+1);i++)
	begin
		lower_byte_lane=waddr[i]-(int'(waddr[i]/data_bus_bytes))*data_bus_bytes;
		upper_byte_lane=lower_byte_lane+no_wbytes-1;
		
		for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
		begin
			WSTRB[i][j]=1;
		end
	end

endfunction: strb_calc
				
function void calc_raddr();

	bit wb;
	
 	int no_rbytes=2**ARSIZE;

	int burst_len=ARLEN+1;

	int N=burst_len;

	int wrap_boundary=(int'(ARADDR/(no_rbytes*burst_len)))*(no_rbytes*burst_len);

	int addr_n=wrap_boundary+(no_rbytes*burst_len);

	raddr=new[ARLEN+1];

	raddr[0]=ARADDR;
	
	aligned_raddr=(int'(ARADDR/no_rbytes))*no_rbytes;
	start_raddr=ARADDR;

	for(int i=2;i<(burst_len+1);i++)
	begin
		if(ARBURST==0)
			raddr[i-1]=ARADDR;

		if(ARBURST==1)
			raddr[i-1]=aligned_raddr+(i-1)*no_rbytes;

		if(ARBURST==2)
			begin
				if(wb==0)	
				begin
					raddr[i-1]=aligned_raddr+(i-1)*no_rbytes;	
					if(raddr[i-1]==(wrap_boundary+(no_rbytes*burst_len)))

					begin
						raddr[i-1]=wrap_boundary;
						wb++;
					end

				end
				else	
					raddr[i-1]=start_raddr+((i-1)*no_rbytes)-(no_rbytes*burst_len);
			end

	end

endfunction: calc_raddr
	
function void post_randomize();
	 no_wbytes=2**AWSIZE;
           aligned_waddr= (int'(AWADDR/no_wbytes))*no_wbytes;
           start_waddr=AWADDR;
           WSTRB=new[AWLEN+1];

           /*********for read*************/
           no_rbytes=2**ARSIZE;
           aligned_raddr= (int'(ARADDR/no_rbytes))*no_rbytes;
           start_raddr=ARADDR;
           //RSTRB=new[ARLEN+1];
           /**********************/
	calc_raddr();
	strb_calc();
	calc_waddr();

endfunction: post_randomize
	
	
function new(string name="xtn");

	super.new(name);

endfunction

function void do_print(uvm_printer printer);

	super.do_print(printer);

	//Write Address Signals

	printer.print_string("\n*************** Write Address Channel Signals **************","\n");
	printer.print_field("rst1",    this.rst1,    1, UVM_DEC);
	printer.print_field("AWID",    this.AWID,    4, UVM_DEC);
	printer.print_field("AWADDR",  this.AWADDR,  32,UVM_DEC);		
	printer.print_field("AWLEN",   this.AWLEN,   8, UVM_DEC);	
	printer.print_field("AWBURST", this.AWBURST, 2, UVM_DEC);	
	printer.print_field("AWVALID", this.AWVALID, 1, UVM_DEC);	
	printer.print_field("AWREADY", this.AWREADY, 1, UVM_DEC);	
//	printer.print_field("AWCLOCK", this.AWCLOCK, 1, UVM_DEC);	

	//Write Data Channels Signals	
	
	printer.print_string("\n*************** Write Data Channel Signals **************","\n");
	printer.print_field("WID",     this.WID,     4, UVM_DEC);
	
	foreach(WDATA[i])
	begin
    	printer.print_field($sformatf("WDATA[%0d]",i),     this.WDATA[i], 32, UVM_DEC);
	printer.print_field($sformatf("WSTRB[%0d]",i),   this.WSTRB[i],  4, UVM_BIN);

	end

	printer.print_field("WLAST",   this.WLAST,   1, UVM_DEC);	
	printer.print_field("WREADY",  this.WREADY,  1, UVM_DEC);	

	//Write Response Channel Signals
		
	printer.print_string("\n*************** Write Response Channel Signals **************","\n");      
	printer.print_field("BID",     this.BID,     4, UVM_DEC);	
	printer.print_field("BRESP",   this.BRESP,   2, UVM_DEC);	
	printer.print_field("BVALID",  this.BVALID,  1, UVM_DEC);	
	printer.print_field("BREADY",  this.BREADY,  1, UVM_DEC);	

	// Read Address Channel Signals	
	
	printer.print_string("\n*************** Read Address Channel Signals **************","\n");
	printer.print_field("ARID",    this.ARID,    4, UVM_DEC);	
	printer.print_field("ARADDR",  this.ARADDR,  32,UVM_DEC);	
	printer.print_field("ARLEN",   this.ARLEN,   8, UVM_DEC);	
	printer.print_field("ARSIZE",  this.ARSIZE,  3, UVM_DEC);	
	printer.print_field("ARBURST", this.ARBURST, 2, UVM_DEC);	
        printer.print_field("ARVALID", this.ARVALID, 1, UVM_DEC);	
	printer.print_field("ARREADY", this.ARREADY, 1, UVM_DEC);	

	//Read Data Channel Signals	
	
	printer.print_string("\n*************** Read Data Channel Signals **************","\n");
	printer.print_field("RID",     this.RID,     4, UVM_DEC);
	
	foreach(RDATA[i])
	begin
	printer.print_field($sformatf("RDATA[%0d]",i),   this.RDATA[i],   32,UVM_DEC);

	printer.print_field($sformatf("RRESP[%0d]",i),   this.RRESP[i],   2, UVM_DEC);
	end	
	printer.print_field("RLAST",   this.RLAST,   1, UVM_DEC);	
	printer.print_field("RVALID",  this.RVALID,  1, UVM_DEC);	
	printer.print_field("RREADY",  this.RREADY,  1, UVM_DEC);

	foreach(waddr[i])
	printer.print_field($sformatf("WADDR[%0d]",i), this.waddr[i], 32,UVM_DEC);	

endfunction: do_print

endclass: xtn
