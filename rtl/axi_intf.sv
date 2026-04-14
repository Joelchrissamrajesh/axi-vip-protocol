interface axi_intf(input bit clock);
	
	logic ACLK;
	logic ARESETn;

	///  WRITE ADDRESS CHANNEL SIGNAL  ///

	logic[3:0] AWID;
	logic[31:0] AWADDR;
	logic[3:0] AWLEN;
	logic[2:0] AWSIZE;
	logic[1:0] AWBURST;
	logic AWVALID;
	logic AWREADY;

	///  WRITE DATA CHANNEL SIGNAL  ///

	logic[3:0] WID;
	logic[31:0] WDATA;
	logic[3:0] WSTRB;
	logic WLAST;
	logic WVALID;
	logic WREADY;

	///  WRITE RESPONSE CHANNEL SIGNAL  ///

	logic[3:0] BID;
	logic[1:0] BRESP;
	logic BVALID;
	logic BREADY;

	/// READ ADDRESS CHANNEL SIGNAL  ///
	
	logic[3:0] ARID;
	logic[31:0] ARADDR;
	logic[3:0] ARLEN;
	logic[2:0] ARSIZE;
	logic[1:0] ARBURST;
	logic ARVALID;
	logic ARREADY;

	/// READ DATA CHANNEL SIGNAL  ///

	logic[3:0] RID;
	logic[31:0] RDATA;
	logic[1:0] RRESP;
	logic RVALID;
	logic RLAST;
	logic RREADY;

	assign ACLK = clock;


	/////////   MASTER    ////////

	clocking mstr_drv_cb@(posedge ACLK);
	
		default input #1 output #1;

	///  WRITE ADDRESS CHANNEL  ///

		output AWID;
		output AWADDR;
		output AWLEN;
		output AWSIZE;
		output AWBURST;
		output AWVALID;

		input AWREADY;

	///  WRITE DATA CHANNEL  ///

		output WID;
		output WDATA;
		output WSTRB;
		output WLAST;
		output WVALID;
	
		input WREADY;

	///  WRITE RESPONSE CHANNEL SIGNAL  ///

		input BID;
		input BRESP;
		input BVALID;
		
		output BREADY;

	/// READ ADDRESS CHANNEL SIGNAL  ///
	
		output ARID;
		output ARADDR;
		output ARLEN;
		output ARSIZE;
		output ARBURST;
		output ARVALID;
		
		input ARREADY;

	/// READ DATA CHANNEL SIGNAL  ///

		input RID;
		input RDATA;
		input RRESP;
		input RLAST;
		input RVALID;
	
		output RREADY;

	endclocking

	clocking mstr_mon_cb@(posedge ACLK);
	
		default input #1 output #1;

	///  WRITE ADDRESS CHANNEL  ///

		input AWID;
		input AWADDR;
		input AWLEN;
		input AWSIZE;
		input AWBURST;
		input AWVALID;

		input AWREADY;

	///  WRITE DATA CHANNEL  ///

		input WID;
		input WDATA;
		input WSTRB;
		input WLAST;
		input WVALID;
	
		input WREADY;

	///  WRITE RESPONSE CHANNEL SIGNAL  ///

		input BID;
		input BRESP;
		input BVALID;
		
		input BREADY;

	/// READ ADDRESS CHANNEL SIGNAL  ///
	
		input ARID;
		input ARADDR;
		input ARLEN;
		input ARSIZE;
		input ARBURST;
		input ARVALID;
		
		input ARREADY;

	/// READ DATA CHANNEL SIGNAL  ///

		input RID;
		input RDATA;
		input RRESP;
		input RLAST;
		input RVALID;
	
		input RREADY;

	endclocking

	///////////    SLAVE     ////////////

	clocking slave_drv_cb@(posedge ACLK);
	
		default input #1 output #1;

	///  WRITE ADDRESS CHANNEL  ///

		input AWID;
		input AWADDR;
		input AWLEN;
		input AWSIZE;
		input AWBURST;
		input AWVALID;

		output AWREADY;

	///  WRITE DATA CHANNEL  ///

		input WID;
		input WDATA;
		input WSTRB;
		input WLAST;
		input WVALID;
	
		output WREADY;

	///  WRITE RESPONSE CHANNEL SIGNAL  ///

		output BID;
		output BRESP;
		output BVALID;
		
		input BREADY;

	/// READ ADDRESS CHANNEL SIGNAL  ///
	
		input ARID;
		input ARADDR;
		input ARLEN;
		input ARSIZE;
		input ARBURST;
		input ARVALID;
		
		output ARREADY;

	/// READ DATA CHANNEL SIGNAL  ///

		output RID;
		output RDATA;
		output RRESP;
		output RLAST;
		output RVALID;
	
		input RREADY;

	endclocking

	clocking slave_mon_cb@(posedge ACLK);
	
		default input #1 output #1;

	///  WRITE ADDRESS CHANNEL  ///

		input AWID;
		input AWADDR;
		input AWLEN;
		input AWSIZE;
		input AWBURST;
		input AWVALID;

		input AWREADY;

	///  WRITE DATA CHANNEL  ///

		input WID;
		input WDATA;
		input WSTRB;
		input WLAST;
		input WVALID;
	
		input WREADY;

	///  WRITE RESPONSE CHANNEL SIGNAL  ///

		input BID;
		input BRESP;
		input BVALID;
		
		input BREADY;

	/// READ ADDRESS CHANNEL SIGNAL  ///
	
		input ARID;
		input ARADDR;
		input ARLEN;
		input ARSIZE;
		input ARBURST;
		input ARVALID;
		
		input ARREADY;

	/// READ DATA CHANNEL SIGNAL  ///

		input RID;
		input RDATA;
		input RRESP;
		input RLAST;
		input RVALID;
	
		input RREADY;

	endclocking

	modport MSTR_DRV_MP(clocking mstr_drv_cb);
	modport MSTR_MON_MP(clocking mstr_mon_cb);
	modport SLAVE_DRV_MP(clocking slave_drv_cb);
	modport SLAVE_MON_MP(clocking slave_mon_cb);

endinterface
	





	

	


	
	
