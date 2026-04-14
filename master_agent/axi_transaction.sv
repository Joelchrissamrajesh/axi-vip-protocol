class axi_xtn extends uvm_sequence_item;
	`uvm_object_utils(axi_xtn)

	///  WRITE ADDRESS CHANNEL SIGNAL  ///

	bit ARESETn;
	rand bit[3:0] AWID;
	rand bit[31:0] AWADDR;
	rand bit[3:0] AWLEN;
	rand bit[2:0] AWSIZE;
	rand bit[1:0] AWBURST;
	bit AWVALID;
	bit AWREADY;

	/// WRITE DATA CHANNEL SIGNAL  ///

	rand bit[3:0] WID;
	rand bit[31:0] WDATA[];
 	bit[3:0] WSTRB[];
	bit WLAST;
	bit WVALID;
	bit WREADY;

	/// WRITE RESPONSE CHANNEL SIGNAL  ///

	rand bit[3:0] BID;
 	bit[1:0] BRESP;
	bit BVALID;
	bit BREADY; 
	
	/// READ ADDRESS CHANNEL  ///

	rand bit[3:0] ARID;
	rand bit[31:0] ARADDR;
	rand bit[3:0] ARLEN;
	rand bit[2:0] ARSIZE;
	rand bit[1:0] ARBURST;
	bit ARVALID;
	bit ARREADY;

	/// READ DATA CHANNEL SIGNAL  ///

	rand bit[3:0] RID;
	rand bit[31:0] RDATA[];
	rand bit[1:0] RRESP[];
	bit RLAST;
	bit RVALID;
	bit RREADY;

	bit[31:0] addr[];
	int no_bytes;
	int aligned_addr;
	int start_addr;

	bit[3:0] RSTRB[];
	bit[31:0] raddr[];
	int no_rbytes;
	int aligned_raddr;
	int start_raddr;

	constraint wdata{WDATA.size()==(AWLEN+1);}
	constraint rdata{RDATA.size()==(ARLEN+1);}

	constraint awb {AWBURST dist{0:=10,1:=10,2:=10};}
	constraint arb {ARBURST dist{0:=10,1:=10,2:=10};}

	constraint write_id {AWID == WID; BID == WID;}
	constraint read_id {RID == ARID;}

	constraint aws {AWSIZE dist{0:=10, 1:=10,2:=10};}
	constraint ars {ARSIZE dist{0:=10, 1:=10, 2:=10};}

	constraint awlen_w {if(AWBURST==2) (AWLEN+1) inside {2,4,8,16};}
	constraint arlen_w {if(ARBURST==2) (ARLEN+1) inside {2,4,8,16};}

	constraint write_alignment {(AWBURST == 2'b10 && AWSIZE == 1) -> AWADDR%2 == 0;}
	constraint write_alignment_c {(AWBURST == 2'b10 && AWSIZE == 2) -> AWADDR%4 == 0;}

	constraint read_alignment {(ARBURST == 2'b10 && AWSIZE == 1) -> ARADDR%2 == 0;}
	constraint read_alignment_c {(ARBURST == 2'b10 && AWSIZE == 2) -> ARADDR%4 == 0;}

	constraint max_boundary_w {(2**AWSIZE)*(AWLEN+1) < 4096;}
	constraint max_boundary_r {(2**ARSIZE)*(ARLEN+1) < 4096;}

	constraint awlen {AWLEN inside {[1:15]};}
	constraint arlen {ARLEN inside {[1:15]};}


	function new(string name = "axi_xtn");
		super.new(name);
	endfunction

	function void post_randomize();
		no_bytes = 2**AWSIZE;
		aligned_addr = (int'(AWADDR/no_bytes))*no_bytes;
		start_addr = AWADDR;
		WSTRB = new[AWLEN+1];

		no_rbytes = 2**ARSIZE;
		aligned_raddr = (int'(ARADDR/no_bytes))*no_bytes;
		start_raddr = ARADDR;
		RSTRB = new[ARLEN+1];
		
		cal_addr();
		strb_cal();
	endfunction

	function void cal_addr();
		bit wb;
		int burst_len = AWLEN+1;
		int wrap_boundary = (int'(start_addr/(no_bytes*burst_len)))*(no_bytes*burst_len);
		int addr_n = wrap_boundary + (no_bytes*burst_len);
		addr=new[AWLEN+1];
		addr[0]=AWADDR;
		
		for(int i=1;i<burst_len;i++)
			begin
				if(AWBURST == 0)
					addr[i] = AWADDR;
				
				if(AWBURST == 1)
					addr[i] = aligned_addr+(i*no_bytes);
		
				if(AWBURST == 2)
					begin
						if(wb == 0)
							begin
								addr[i] = aligned_addr+(i*no_bytes);
								if(addr[i] == addr_n)
									begin
										addr[i] = wrap_boundary;
										wb++;
									end
							end
						else
							addr[i] = start_addr + (i*no_bytes)-(no_bytes*burst_len);
					end
			end
	endfunction

	function void strb_cal();	
		int data_bus_bytes = 4;
		int burst_len = AWLEN+1;
		int lower_byte_lane;
		int upper_byte_lane;
		int lower_byte_lane_0 = (int'(start_addr - (int'(start_addr/data_bus_bytes))*data_bus_bytes));
		int upper_byte_lane_0 = (aligned_addr +(no_bytes-1))-(int'(start_addr/data_bus_bytes))*data_bus_bytes;

		for(int i=lower_byte_lane_0;i<=upper_byte_lane_0;i++)
			WSTRB[0][i] = 1;


		for(int i=1;i<burst_len;i++)
			begin
				lower_byte_lane = addr[i] - (int'(addr[i]/data_bus_bytes))*data_bus_bytes;
				upper_byte_lane = lower_byte_lane + no_bytes-1;
				for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
					WSTRB[i][j] = 1;
			end
	endfunction

		
		

	function void do_print(uvm_printer printer);
		super.do_print(printer);

		/// WRITE ADDRESS CHANNEL SIGNAL  ///

		printer.print_string("\n========== WRITE ADDRESS CHANNEL ==========","\n");
		printer.print_field("ARESETn",this.ARESETn,1,UVM_BIN);
		printer.print_field("AWID",this.AWID,4,UVM_BIN);
		printer.print_field("AWADDR",this.AWADDR,32,UVM_DEC);
		printer.print_field("AWLEN",this.AWLEN,4,UVM_BIN);
		printer.print_field("AWSIZE",this.AWSIZE,3,UVM_BIN);
		printer.print_field("AWBURST",this.AWBURST,2,UVM_BIN);
		printer.print_field("AWVALID",this.AWVALID,1,UVM_BIN);
		printer.print_field("AWREADY",this.AWREADY,1,UVM_BIN);

		/// WRITE DATA CHANNEL SIGNAL  ///
	
		printer.print_string("\n========== WRITE DATA CHANNEL ==========","\n");
		printer.print_field("WID",this.WID,4,UVM_BIN);
		foreach(WDATA[i])
			printer.print_field($sformatf("WDATA[%0d]",i),this.WDATA[i],32,UVM_DEC);
		foreach(WSTRB[i])
			printer.print_field($sformatf("WSTRB[%0d]",i),this.WSTRB[i],4,UVM_BIN);
		printer.print_field("WLAST",this.WLAST,1,UVM_BIN);
		printer.print_field("WVALID",this.WVALID,1,UVM_BIN);
		printer.print_field("WREADY",this.WREADY,1,UVM_BIN);

		/// WRITE RESPONSE CHANNEL  ///

		printer.print_string("\n========== WRITE RESPONSE CHANNEL ==========","\n");
		printer.print_field("BID",this.BID,4,UVM_BIN);
		printer.print_field("BRESP",this.BRESP,2,UVM_BIN);
		printer.print_field("BVALID",this.BVALID,1,UVM_BIN);
		printer.print_field("BREADY",this.BREADY,1,UVM_BIN);

		/// READ ADDRESS CHANNEL SIGNAL  ///

		printer.print_string("\n========== READ ADDRESS CHANNEL ==========","\n");
		printer.print_field("ARID",this.ARID,4,UVM_BIN);
		printer.print_field("ARADDR",this.ARADDR,32,UVM_DEC);
		printer.print_field("ARLEN",this.ARLEN,4,UVM_BIN);
		printer.print_field("ARSIZE",this.ARSIZE,3,UVM_BIN);
		printer.print_field("ARBURST",this.ARBURST,2,UVM_BIN);
		printer.print_field("ARVALID",this.ARVALID,1,UVM_BIN);
		printer.print_field("ARREADY",this.ARREADY,1,UVM_BIN);
		
		///  READ DATA CHANNEL  ///

		printer.print_string("\n========== READ DATA CHANNEL ==========","\n");	
		printer.print_field("RID",this.RID,4,UVM_BIN);
		foreach(RDATA[i])
			printer.print_field($sformatf("RDATA[%0d]",i),this.RDATA[i],32,UVM_DEC);
		foreach(RRESP[i])
			printer.print_field($sformatf("RRESP[%0d]",i),this.RRESP[i],2,UVM_BIN);
		printer.print_field("RLAST",this.RLAST,1,UVM_BIN);
		printer.print_field("RVALID",this.RVALID,1,UVM_BIN);
		printer.print_field("RREADY",this.RREADY,1,UVM_BIN);

		/// ADDRESS  ///

		printer.print_string("\n========== WRITE BURST ADDRESS ==========","\n");	
		foreach(addr[i])
			printer.print_field($sformatf("ADDR[%0d]",i),this.addr[i],32,UVM_DEC);




	endfunction

	function bit do_compare(uvm_object rhs,uvm_comparer comparer);
		axi_xtn rhs_;
		
		if(!$cast(rhs_,rhs))
			begin
			`uvm_fatal("do_compare","cast of the rhs object failed")
			return 0;
			end

		if(WDATA.size() !== rhs_.WDATA.size())
			begin
				`uvm_error("do_compare","SIZE OF WDATA MISMATCH")
				return 0;
			end

		if(RDATA.size() !== rhs_.RDATA.size)
			begin
				`uvm_error("do_compare","MISMATCH IN SIZE OF RDATA")
				return 0;
			end

		foreach(WDATA[i])
			begin
				if(WDATA[i] !== rhs_.WDATA[i])
					begin
						`uvm_error("do_compare","WDATA MISMATCH")
						return 0;
					end
			end

		foreach(RDATA[i])
			begin
				if(RDATA[i] !== rhs_.RDATA[i])
					begin
						`uvm_error("do_compare","RDATA MISMATCH")
						return 0;
					end
			end
		return

		super.do_compare(rhs,comparer) &&
		AWID == rhs_.AWID &&
		AWADDR == rhs_.AWADDR &&
		AWLEN == rhs_.AWLEN &&
		AWSIZE == rhs_.AWSIZE &&
		AWBURST == rhs_.AWBURST &&

		WID == rhs_.WID &&
		WLAST == rhs_.WLAST &&

		ARID == rhs_.ARID &&
		ARADDR == rhs_.ARADDR &&
		ARLEN == rhs_.ARLEN &&
		ARSIZE == rhs_.ARSIZE &&
		ARBURST == rhs_.ARBURST &&


		RID == rhs_.RID &&
		RLAST == rhs_.RLAST;
	endfunction
		


endclass
