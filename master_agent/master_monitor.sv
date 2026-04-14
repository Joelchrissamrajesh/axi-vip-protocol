class mstr_monitor extends uvm_monitor;
	`uvm_component_utils(mstr_monitor)

	mstr_config m_cfg;
	virtual axi_intf.MSTR_MON_MP vif;
	uvm_analysis_port #(axi_xtn) monitor_port;

	axi_xtn xtn;//,xtn1;

	axi_xtn q1[$],q2[$],q3[$];
	
	semaphore sem_awc = new(1);
	semaphore sem_wdc = new(1);
	semaphore sem_wrc = new(1);
	semaphore sem_awdc = new();
	semaphore sem_wrdc = new();

	semaphore sem_arc = new(1);
	semaphore sem_rdc = new(1);
	semaphore sem_ardc = new();


	function new(string name = "mstr_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(mstr_config)::get(this,"","mstr_config",m_cfg))
			`uvm_fatal("MON","FAILED")

		monitor_port = new("monitor_port",this);
		super.build_phase(phase);
	endfunction

	function void connect_phase(uvm_phase phase);
		vif = m_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever
			collect_data();
	endtask
	
	task collect_data();
		xtn = axi_xtn::type_id::create("xtn");
	//	xtn1 = axi_xtn::type_id::create("xtn1");

		fork
			/*begin
				sem_awc.get(1);
				collect_awaddr(xtn);
				sem_wdc.put(1);
				sem_awc.put(1);
			end

			begin
				sem_wdc.get(1);
				collect_wdata(q1.pop_front());
				sem_wrc.put(1);
			end

			begin
				sem_wrc.get(1);
				collect_bresp(q2.pop_front());
			end

			begin
				sem_arc.get(1);
				collect_raddr(xtn1);
				sem_rdc.put(1);
				sem_arc.put(1);
			end

			begin
				sem_rdc.get(1);
				collect_rdata(q3.pop_front());
			end*/

			begin
				sem_awc.get(1);
				collect_awaddr(xtn);
				sem_awdc.put(1);
				sem_awc.put(1);
			end

			begin
				sem_awdc.get(1);
				sem_wdc.get(1);
				collect_wdata(q1.pop_front());
				sem_wrdc.put(1);
				sem_wdc.put(1);
			end

			begin
				sem_wrdc.get(1);
				sem_wrc.get(1);
				collect_bresp(q2.pop_front());
				sem_wrc.put(1);
				
			end

			begin
				sem_arc.get(1);
				collect_raddr(xtn);
				sem_ardc.put(1);
				sem_arc.put(1);
			end

			begin
				sem_ardc.get(1);
				sem_rdc.get(1);
				collect_rdata(q3.pop_front());
				sem_rdc.put(1);
			end

				
		join_any
	//	`uvm_info(get_type_name(),$sformatf("priting from mon \n %s",xtn.sprint()),UVM_LOW)

	endtask

	task collect_awaddr(axi_xtn xtn);
		
		wait(vif.mstr_mon_cb.AWVALID && vif.mstr_mon_cb.AWREADY)

		xtn.AWID = vif.mstr_mon_cb.AWID;
		xtn.AWADDR = vif.mstr_mon_cb.AWADDR;
		xtn.AWSIZE = vif.mstr_mon_cb.AWSIZE;
		xtn.AWLEN = vif.mstr_mon_cb.AWLEN;
		xtn.AWBURST = vif.mstr_mon_cb.AWBURST;
		xtn.AWVALID = vif.mstr_mon_cb.AWVALID;

		xtn.AWREADY = vif.mstr_mon_cb.AWREADY;

		q1.push_back(xtn);
		q2.push_back(xtn);

		@(vif.mstr_mon_cb);
		

	endtask

	task collect_wdata(axi_xtn xtn);

		xtn.WDATA = new[xtn.AWLEN+1];
		xtn.WSTRB = new[xtn.AWLEN+1];
	
		for(int i=0;i<=xtn.AWLEN;i++)
			begin
			//	$display("MON ITERATION %0d",i);

			//	@(vif.mstr_mon_cb);
				wait(vif.mstr_mon_cb.WVALID && vif.mstr_mon_cb.WREADY)
			//	$display("MON ITERATION %0d",i);
				
				xtn.WID = vif.mstr_mon_cb.WID;
				if(vif.mstr_mon_cb.WSTRB == 15)
					xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[31:0];
				
				if(vif.mstr_mon_cb.WSTRB == 14)
			

					xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[31:8];

			//	if(vif.mstr_mon_cb.WSTRB == 7)
			//		xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[23:0];
		
				if(vif.mstr_mon_cb.WSTRB == 12)
					xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[31:16];

		//		if(vif.mstr_mon_cb.WSTRB == 6)
		//			xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[23:8];
	
				if(vif.mstr_mon_cb.WSTRB == 3)
					xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[15:0];

				if(vif.mstr_mon_cb.WSTRB == 8)
					xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[31:24];

				if(vif.mstr_mon_cb.WSTRB == 4)
					xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[23:16];
	
				if(vif.mstr_mon_cb.WSTRB == 2)
					xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[15:8];

				if(vif.mstr_mon_cb.WSTRB == 1)
					xtn.WDATA[i] = vif.mstr_mon_cb.WDATA[7:0];

			//	if(vif.mstr_mon_cb.WSTRB == 0)
				//	xtn.WDATA[i] = 0;
				xtn.WSTRB[i] = vif.mstr_mon_cb.WSTRB;

			//	xtn.WSTRB[i] = vif.mstr_mon_cb.WSTRB;
				xtn.WLAST = vif.mstr_mon_cb.WLAST;
				xtn.WVALID = vif.mstr_mon_cb.WVALID;
				xtn.WREADY = vif.mstr_mon_cb.WREADY;
			//	`uvm_info(get_type_name(),$sformatf("priting from driver \n %s",xtn.sprint()),UVM_LOW)

			//	$display("BEFORE WAIT %0d",i);
			//	wait(!vif.mstr_mon_cb.WVALID && !vif.mstr_mon_cb.WREADY)
			//	$display("AFTER WAIT %0d",i);
				monitor_port.write(xtn);
				
				@(vif.mstr_mon_cb);
			end
	endtask

	task collect_bresp(axi_xtn xtn);
		
		wait(vif.mstr_mon_cb.BVALID && vif.mstr_mon_cb.BREADY)

		xtn.BID = vif.mstr_mon_cb.BID;
		xtn.BRESP = vif.mstr_mon_cb.BRESP;
		
		xtn.BVALID = vif.mstr_mon_cb.BVALID;
		xtn.BREADY = vif.mstr_mon_cb.BREADY;
	endtask

	task collect_raddr(axi_xtn xtn);
		
		wait(vif.mstr_mon_cb.ARVALID && vif.mstr_mon_cb.ARREADY)

		xtn.ARID = vif.mstr_mon_cb.ARID;
		xtn.ARADDR = vif.mstr_mon_cb.ARADDR;
		xtn.ARLEN = vif.mstr_mon_cb.ARLEN;
		xtn.ARSIZE = vif.mstr_mon_cb.ARSIZE;
		xtn.ARBURST = vif.mstr_mon_cb.ARBURST;

		xtn.ARVALID = vif.mstr_mon_cb.ARVALID;
		xtn.ARREADY = vif.mstr_mon_cb.ARREADY;
		
		q3.push_back(xtn);

		@(vif.mstr_mon_cb);
		
	endtask

	task collect_rdata(axi_xtn xtn);
		xtn.RDATA = new[xtn.ARLEN+1];
		
		for(int i=0;i<=xtn.ARLEN;i++)
			begin	
				wait(vif.mstr_mon_cb.RVALID && vif.mstr_mon_cb.RREADY)
				
				xtn.RID = vif.mstr_mon_cb.RID;
				xtn.RDATA[i] = vif.mstr_mon_cb.RDATA;
				xtn.RRESP[i] = vif.mstr_mon_cb.RRESP;
				xtn.RLAST = vif.mstr_mon_cb.RLAST;
				
				xtn.RVALID = vif.mstr_mon_cb.RVALID;
				xtn.RREADY = vif.mstr_mon_cb.RREADY;
			//	`uvm_info(get_type_name(),$sformatf("priting from driver \n %s",xtn.sprint()),UVM_LOW)
	

				monitor_port.write(xtn);

				@(vif.mstr_mon_cb);
						
			end
	endtask			

endclass
