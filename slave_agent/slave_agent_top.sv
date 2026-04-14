class slave_agent_top extends uvm_agent;
	`uvm_component_utils(slave_agent_top)

	slave_agent slave_agnth[];
	
	env_config m_cfg;
	
	function new(string name = "slave_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
			`uvm_fatal("agt_top","FAILED")
	
		slave_agnth = new[m_cfg.no_of_slave_agent];

		foreach(slave_agnth[i])
			slave_agnth[i]=slave_agent::type_id::create($sformatf("slave_agnth[%0d]",i),this);
	
		super.build_phase(phase);
	endfunction

endclass
