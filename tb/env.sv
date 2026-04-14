class env extends uvm_env;
	`uvm_component_utils(env)
	
	mstr_agent_top m_agnth;
	slave_agent_top s_agnth;
	scoreboard sbh;

	env_config m_cfg;
	
	function new(string name = "env",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
			`uvm_fatal("ENV","FAILED")
		
		if(m_cfg.has_mstr_agent == 1)
			m_agnth=mstr_agent_top::type_id::create("m_agnth",this);
		
		if(m_cfg.has_slave_agent == 1)
			s_agnth=slave_agent_top::type_id::create("s_agnth",this);

		if(m_cfg.has_scoreboard == 1)
			sbh=scoreboard::type_id::create("sbh",this);

		super.build_phase(phase);
	endfunction

	function void connect_phase(uvm_phase phase);
		if(m_cfg.has_mstr_agent == 1)
			for(int i=0;i<m_cfg.no_of_mstr_agent;i++)
				m_agnth.mstr_agnth[i].monh.monitor_port.connect(sbh.m_fifoh[i].analysis_export);

		if(m_cfg.has_slave_agent == 1)
			for(int i=0;i<m_cfg.no_of_slave_agent;i++)
				s_agnth.slave_agnth[i].monh.monitor_port.connect(sbh.s_fifoh[i].analysis_export);
	endfunction


	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction

endclass
