class mstr_agent_top extends uvm_agent;
	`uvm_component_utils(mstr_agent_top)

	mstr_agent mstr_agnth[];
	
	env_config m_cfg;
	
	function new(string name = "mstr_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
			`uvm_fatal("mstr_agt_top","FAILED")
	
		mstr_agnth = new[m_cfg.no_of_mstr_agent];

		foreach(mstr_agnth[i])
			mstr_agnth[i]=mstr_agent::type_id::create($sformatf("mstr_agnth[%0d]",i),this);
	
		super.build_phase(phase);
	endfunction

endclass
