class mstr_driver extends uvm_driver #(axi_xtn);
	`uvm_component_utils(mstr_driver)

	mstr_config m_cfg;
	virtual axi_intf.MSTR_DRV_MP vif;

	axi_xtn xtn;
	axi_xtn q1[$],q2[$],q3[$],q4[$],q5[$];

	semaphore sem_awc = new(1);
	semaphore sem_wdc = new(1);
	semaphore sem_wrc = new(1);
	semaphore sem_awdc = new();
	semaphore sem_wrdc = new();

	semaphore sem_arc = new(1);
	semaphore sem_rdc = new(1);
	semaphore sem_ardc = new();

	function new(string name = "mstr_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(mstr_config)::get(this,"","mstr_config",m_cfg))
			`uvm_fatal("DRV","FAILED")
		super.build_phase(phase);
	endfunction

	function void connect_phase(uvm_phase phase);
		vif = m_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever
			begin
				seq_item_port.get_next_item(req);
				drive(req);
				seq_item_port.item_done();
				`uvm_info(get_type_name(),$sformatf("priting from driver \n %s",req.sprint()),UVM_LOW)

			end
	endtask

	task drive(axi_xtn xtn);
		q1.push_back(xtn);
		q2.push_back(xtn);
		q3.push_back(xtn);
		q4.push_back(xtn);
		q5.push_back(xtn);

		fork
			begin
				sem_awc.get(1);
				drive_awaddr(q1.pop_front());
				sem_awdc.put(1);
				sem_awc.put(1);
			end

			begin
				sem_wdc.get(1);
				sem_awdc.get(1);
				drive_wdata(q2.pop_front());
				sem_wrdc.put(1);
				sem_wdc.put(1);
			end

			begin
				sem_wrc.get(1);
				sem_wrdc.get(1);
				drive_bresp(q3.pop_front());
				sem_wrc.put(1);
			end

			begin
				sem_arc.get(1);
				drive_raddr(q4.pop_front());
				sem_arc.put(1);				
				sem_ardc.put(1);
			end

			begin
				sem_ardc.get(1);
				sem_rdc.get(1);
				drive_rresp(q5.pop_front());
				sem_rdc.put(1);
			end
				
		join_any

		

	endtask

	task drive_awaddr(axi_xtn xtn);

		@(vif.mstr_drv_cb);	
		vif.mstr_drv_cb.AWVALID <= 1;
		vif.mstr_drv_cb.AWID <= xtn.AWID;
		vif.mstr_drv_cb.AWADDR <= xtn.AWADDR;
		vif.mstr_drv_cb.AWSIZE <= xtn.AWSIZE;
		vif.mstr_drv_cb.AWLEN <= xtn.AWLEN;
		vif.mstr_drv_cb.AWBURST <= xtn.AWBURST;

		@(vif.mstr_drv_cb);
		wait(vif.mstr_drv_cb.AWREADY)
		vif.mstr_drv_cb.AWVALID <= 0;

		repeat($urandom_range(1,3))
			@(vif.mstr_drv_cb);
	endtask

	task drive_wdata(axi_xtn xtn);

	//	@(vif.mstr_drv_cb);
		for(int i = 0;i<=xtn.AWLEN;i++)
                	begin
			//	$display("ITERATION %0d",i);
				@(vif.mstr_drv_cb);	
				vif.mstr_drv_cb.WVALID <= 1;
				vif.mstr_drv_cb.WID <= xtn.WID;
				vif.mstr_drv_cb.WDATA <= xtn.WDATA[i];
				vif.mstr_drv_cb.WSTRB <= xtn.WSTRB[i];
				
				if(i == xtn.AWLEN)
					vif.mstr_drv_cb.WLAST <= 1;
				else
					vif.mstr_drv_cb.WLAST <= 0;

			

				@(vif.mstr_drv_cb);
				wait(vif.mstr_drv_cb.WREADY)
//				@(vif.mstr_drv_cb);				
				vif.mstr_drv_cb.WVALID <= 0;
				vif.mstr_drv_cb.WLAST <= 0;
			end
		
		repeat($urandom_range(1,3))
			@(vif.mstr_drv_cb);
	endtask

	task drive_bresp(axi_xtn xtn);
		
		vif.mstr_drv_cb.BREADY <= 1;
		wait(vif.mstr_drv_cb.BVALID)
//		xtn.BID = vif.mstr_drv_cb.BID;
//		xtn.BRESP = vif.mstr_drv_cb.BRESP;

		
		@(vif.mstr_drv_cb);
		vif.mstr_drv_cb.BREADY <= 0;

		repeat($urandom_range(1,3))
			@(vif.mstr_drv_cb);

	endtask

	task drive_raddr(axi_xtn xtn);

		vif.mstr_drv_cb.ARVALID <= 1;
		vif.mstr_drv_cb.ARID <= xtn.ARID;
		vif.mstr_drv_cb.ARADDR <= xtn.ARADDR;
		vif.mstr_drv_cb.ARLEN <= xtn.ARLEN;
		vif.mstr_drv_cb.ARSIZE <= xtn.ARSIZE;
		vif.mstr_drv_cb.ARBURST <= xtn.ARBURST;

		@(vif.mstr_drv_cb);
		wait(vif.mstr_drv_cb.ARREADY)
		vif.mstr_drv_cb.ARVALID <= 0;

		repeat($urandom_range(1,3))
			@(vif.mstr_drv_cb);
	endtask


	task drive_rresp(axi_xtn xtn);

		for(int i=0;i<=xtn.ARLEN;i++)
			begin
				vif.mstr_drv_cb.RREADY <= 1;
				@(vif.mstr_drv_cb);			
				wait(vif.mstr_drv_cb.RVALID)
				xtn.RID = vif.mstr_drv_cb.RID;
				xtn.RDATA[i] = vif.mstr_drv_cb.RDATA;
				xtn.RRESP[i] = vif.mstr_drv_cb.RRESP;
				xtn.RLAST = vif.mstr_drv_cb.RLAST;
				
				@(vif.mstr_drv_cb);
				vif.mstr_drv_cb.RREADY <= 0;
			end
	
		repeat($urandom_range(1,3))
			@(vif.mstr_drv_cb);
	endtask

endclass

