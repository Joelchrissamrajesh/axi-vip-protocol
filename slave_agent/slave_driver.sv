class slave_driver extends uvm_driver #(axi_xtn);
	`uvm_component_utils(slave_driver)

	axi_xtn xtn,xtn1;
	slave_config m_cfg;
	virtual axi_intf.SLAVE_DRV_MP vif;

	axi_xtn q1[$],q2[$],q3[$];

	semaphore sem_awc = new(1);
	semaphore sem_wdc = new(1);
	semaphore sem_wrc = new(1);
	semaphore sem_awdc = new();
	semaphore sem_wrdc = new();

	semaphore sem_arc = new(1);
	semaphore sem_rdc = new(1);
	semaphore sem_ardc = new();


	function new(string name = "slave_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(slave_config)::get(this,"","slave_config",m_cfg))
			`uvm_fatal("DRV","FAILED")

	//	xtn = axi_xtn::type_id::create("xtn");
	//	xtn1 = axi_xtn::type_id::create("xtn1");

			
		super.build_phase(phase);
	endfunction

	function void connect_phase(uvm_phase phase);
		vif = m_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever
			begin
				drive();
			end
//		`uvm_info(get_type_name(),$sformatf("priting from driver \n %s",xtn.sprint()),UVM_LOW)
		
	endtask

	task drive();
	//	xtn = axi_xtn::type_id::create("xtn");
	//	xtn1 = axi_xtn::type_id::create("xtn1");

	
		fork
		/*	begin
				sem_awc.get(1);
				drive_awaddr(xtn);
				sem_wdc.put(1);
				sem_awc.put(1);
			end

			begin
		//		sem_awdc.get(1);
				sem_wdc.get(1);
				drive_wdata(q1.pop_front());
				sem_wrc.put(1);
		//		sem_wdc.put(1);
			end

			begin
		//		sem_wrdc.get(1);
				sem_wrc.get(1);
				drive_bresp(q2.pop_front());
		//		sem_wrc.put(1);
			end

			begin
				sem_arc.get(1);
				drive_raddr(xtn);
		//		sem_ardc.put(1);
				sem_rdc.put(1);
				sem_arc.put(1);
			end

			begin
		//		sem_ardc.get(1);
				sem_rdc.get(1);
				drive_rdata(q3.pop_front());
		//		sem_rdc.put(1);
			end*/
			begin
				sem_awc.get(1);
				drive_awaddr(xtn);
				sem_awdc.put(1);
				sem_awc.put(1);
			end

			begin
				sem_wdc.get(1);
				sem_awdc.get(1);
				drive_wdata(q1.pop_front());
				sem_wrdc.put(1);			
				sem_wdc.put(1);
			end

			begin
				sem_wrc.get(1);
				sem_wrdc.get(1);
				drive_bresp(q2.pop_front());
				sem_wrc.put(1);
				
			end

			begin
				sem_arc.get(1);
				drive_raddr(xtn1);
				sem_ardc.put(1);
				sem_arc.put(1);
			end

			begin
				sem_ardc.get(1);
				sem_rdc.get(1);
				drive_rdata(q3.pop_front());
				sem_rdc.put(1);
			end

				
		join_any
//		`uvm_info(get_type_name(),$sformatf("priting from slv driver \n %s",xtn.sprint()),UVM_LOW)
		
	endtask

	task drive_awaddr(axi_xtn xtn);
			xtn = axi_xtn::type_id::create("xtn");
		
		vif.slave_drv_cb.AWREADY <= 1;
		@(vif.slave_drv_cb);
		wait(vif.slave_drv_cb.AWVALID)
		
		xtn.AWID = vif.slave_drv_cb.AWID;
		xtn.AWADDR = vif.slave_drv_cb.AWADDR;
		xtn.AWSIZE = vif.slave_drv_cb.AWSIZE;
		xtn.AWLEN = vif.slave_drv_cb.AWLEN;
		xtn.AWBURST = vif.slave_drv_cb.AWBURST;

		q1.push_back(xtn);
		q2.push_back(xtn);
		
		@(vif.slave_drv_cb);
		vif.slave_drv_cb.AWREADY <= 0;

		repeat($urandom_range(1,3))
			@(vif.slave_drv_cb);
	
	endtask 

	task drive_wdata(axi_xtn xtn);
		xtn.WDATA = new[xtn.AWLEN+1];
		xtn.WSTRB = new[xtn.AWLEN+1];
		for(int i = 0;i<=xtn.AWLEN;i++)
			begin
				vif.slave_drv_cb.WREADY <= 1;
				@(vif.slave_drv_cb);				
				wait(vif.slave_drv_cb.WVALID)
				xtn.WID = vif.slave_drv_cb.WID;

				xtn.WSTRB[i] = vif.slave_drv_cb.WSTRB;
				xtn.WLAST = vif.slave_drv_cb.WLAST;

						
				@(vif.slave_drv_cb);	
				vif.slave_drv_cb.WREADY <= 0;

			end

		repeat($urandom_range(1,3))
			@(vif.slave_drv_cb);
	endtask

	task drive_bresp(axi_xtn xtn);

		vif.slave_drv_cb.BVALID <= 1;
		vif.slave_drv_cb.BID <= xtn.AWID;
		vif.slave_drv_cb.BRESP <= 2'b00;

		@(vif.slave_drv_cb);
		wait(vif.slave_drv_cb.BREADY)
		vif.slave_drv_cb.BVALID <= 0;
		vif.slave_drv_cb.BRESP <= 2'bz;

		repeat($urandom_range(1,3))
			@(vif.slave_drv_cb);

	endtask

	task drive_raddr(axi_xtn xtn);
                xtn = axi_xtn::type_id::create("xtn");		
		vif.slave_drv_cb.ARREADY <= 1;
		@(vif.slave_drv_cb);
		wait(vif.slave_drv_cb.ARVALID)

		xtn.ARID = vif.slave_drv_cb.ARID;
		xtn.ARADDR = vif.slave_drv_cb.ARADDR;
		xtn.ARLEN = vif.slave_drv_cb.ARLEN;
		xtn.ARSIZE = vif.slave_drv_cb.ARSIZE;
		xtn.ARBURST = vif.slave_drv_cb.ARBURST;

		q3.push_back(xtn);

		@(vif.slave_drv_cb);
		vif.slave_drv_cb.ARREADY <= 0;

		repeat($urandom_range(1,3))
			@(vif.slave_drv_cb);
	endtask
		
	task drive_rdata(axi_xtn xtn);

		for(int i=0;i<=xtn.ARLEN;i++)
			begin
				@(vif.slave_drv_cb);
				vif.slave_drv_cb.RVALID <= 1;
				vif.slave_drv_cb.RID <= xtn.ARID;
				vif.slave_drv_cb.RDATA <= $urandom;
				vif.slave_drv_cb.RRESP <= 2'b00;
				
				if(i==xtn.ARLEN)
					vif.slave_drv_cb.RLAST <= 1;
				else
					vif.slave_drv_cb.RLAST <= 0;

				@(vif.slave_drv_cb);
				wait(vif.slave_drv_cb.RREADY)
				vif.slave_drv_cb.RVALID <= 0;
				vif.slave_drv_cb.RLAST <= 0;
				vif.slave_drv_cb.RRESP <= 2'bz;
			end

//	`uvm_info(get_type_name(),$sformatf("priting from driver \n %s",xtn.sprint()),UVM_LOW)
			

			repeat($urandom_range(1,3))
			@(vif.slave_drv_cb);
	endtask
		
endclass

