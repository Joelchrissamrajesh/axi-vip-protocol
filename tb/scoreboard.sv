class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)

	uvm_tlm_analysis_fifo #(axi_xtn) m_fifoh[];
	uvm_tlm_analysis_fifo #(axi_xtn) s_fifoh[];

	env_config m_cfg;

	axi_xtn m_xtn,m_xtn1;
	axi_xtn s_xtn,s_xtn1;

	covergroup w_cg1;
		option.per_instance=1;
		AWADDR_cp: coverpoint m_xtn1.AWADDR{ bins awaddr_bin={[0:'hffffffff]};}
		AWBURST_cp: coverpoint m_xtn1.AWBURST{ bins awburst_bin={[0:2]};}
		AWSIZE_cp: coverpoint m_xtn1.AWSIZE{ bins awsize_bin={[0:2]};}
		AWLEN_cp: coverpoint m_xtn1.AWLEN{ bins awlen_bin={[1:15]};}
	//	WRITE_addr: cross AWBURST_cp,AWSIZE_cp,AWLEN_cp;
	endgroup : w_cg1

	covergroup w_cg2 with function sample(int i);
		option.per_instance=1;
		WDATA_cp: coverpoint m_xtn1.WDATA[i]{ bins wdata_bin = {[0:'hffffffff]};}
		WSTRB_cp: coverpoint m_xtn1.WSTRB[i]{ bins strb_size_1 = {8,4,2,1};
							bins strb_size_2 = {12,3};
							bins strb_size_4 = {15,14};}
	endgroup :w_cg2

	covergroup r_cg1;
		option.per_instance=1;
		ARADDR_cp: coverpoint s_xtn1.ARADDR{bins araddr_bin = {[0:'hffffffff]};}
		ARBURST_cp: coverpoint s_xtn1.ARBURST{bins arburst_bin = {[0:2]};}
		ARSIZE_cp: coverpoint s_xtn1.ARSIZE{bins arsize_bin = {[0:2]};}
		ARLEN_cp: coverpoint s_xtn1.ARLEN{bins arlen_bin = {[1:15]};}
	//	READ_addr: cross ARBURST_cp,ARSIZE_cp,ARLEN_cp;
	endgroup : r_cg1

	covergroup r_cg2 with function sample(int i);
		option.per_instance=1;
		RDATA_cp: coverpoint s_xtn1.RDATA[i]{bins rdata_bin = {[0:'hffffffff]};}
		rresp_cp: coverpoint s_xtn1.RRESP[i]{bins resp={00};}
	endgroup : r_cg2
		
		
	

	function new(string name = "scoreboard",uvm_component parent);
		super.new(name,parent);
		w_cg1 = new();
		w_cg2 = new();
		r_cg1 = new();
		r_cg2 = new();
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
			`uvm_fatal("Sb","FAILED")
		
		m_fifoh=new[m_cfg.no_of_mstr_agent];
		foreach(m_fifoh[i])
			m_fifoh[i]=new($sformatf("m_fifoh[%0d]",i),this);
		
		s_fifoh=new[m_cfg.no_of_slave_agent];
		foreach(s_fifoh[i])
			s_fifoh[i]=new($sformatf("s_fifoh[%0d]",i),this);

		super.build_phase(phase);
	endfunction 

	task run_phase(uvm_phase phase);
		
		forever
			fork
				begin
					foreach(m_fifoh[i])
					begin
						m_fifoh[0].get(m_xtn);
						m_xtn1 = m_xtn;
						w_cg1.sample();
						foreach(m_xtn1.WDATA[i])
						begin
							w_cg2.sample(i);
						end
					end
					
				end
		
				begin
					foreach(s_fifoh[i])
					begin
						s_fifoh[0].get(s_xtn);
						s_xtn1 = s_xtn;
						r_cg1.sample();
						foreach(s_xtn1.RDATA[i])
						begin
							r_cg2.sample(i);
						end
						if(m_xtn.compare(s_xtn))
							$display("============ COMPARISION SUCCESS ==========");
						else
							$display("========== COMPARISION FAILED ==========");
					end
				end
			join
		//	m_xtn.print();
	endtask

/*	function void report_phase(uvm_phase phase);
	//	real total_cov;
		m_xtn.print();
		s_xtn.print();
	/*	total_cov = (w_cg1.get_coverage()+
				w_cg2.get_coverage()+
				r_cg1.get_coverage()+
				r_cg2.get_coverage())/4.0;

		`uvm_info("cov",$sformatf("TOTAL COVERAGE = %0.2f%%",total_cov),UVM_LOW)

	endfunction*/


endclass
