class env_config extends uvm_object;
	`uvm_object_utils(env_config)

	mstr_config m_mstr_cfg[];
	slave_config m_slave_cfg[];

	bit has_mstr_agent = 1;
	bit has_slave_agent = 1;
	bit has_scoreboard= 1;

	int no_of_mstr_agent = 1;
	int no_of_slave_agent = 1;

	function new(string name = "env_config");
		super.new(name);
	endfunction
endclass
