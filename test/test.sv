class test extends uvm_test;
	
	`uvm_component_utils(test)

	mstr_config m_mstr_cfg[];
	slave_config m_slave_cfg[];
	env_config m_cfg;

	bit has_mstr_agent =1;
	bit has_slave_agent = 1;
	bit has_scoreboard = 1;

	int no_of_mstr_agent = 1;
	int no_of_slave_agent = 1;

	env envh;

	function new(string name = "test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);

		m_cfg=env_config::type_id::create("m_cfg");
	
		m_cfg.has_mstr_agent = has_mstr_agent;
		m_cfg.has_slave_agent = has_slave_agent;
		m_cfg.has_scoreboard = has_scoreboard;
		m_cfg.no_of_mstr_agent = no_of_mstr_agent;
		m_cfg.no_of_slave_agent = no_of_slave_agent;

		uvm_config_db#(env_config)::set(this,"*","env_config",m_cfg);

		super.build_phase(phase);

		m_mstr_cfg = new[no_of_mstr_agent];
		foreach(m_mstr_cfg[i])
			begin
				m_mstr_cfg[i]=mstr_config::type_id::create($sformatf("m_mstr_cfg[%0d]",i));
				if(!uvm_config_db#(virtual axi_intf)::get(this,"","axi_intf",m_mstr_cfg[i].vif))
					`uvm_fatal(get_type_name(),"GETTING VIF FAILED")
				m_mstr_cfg[i].is_active = UVM_ACTIVE;
				m_cfg.m_mstr_cfg[i]=m_mstr_cfg[i];
				uvm_config_db#(mstr_config)::set(this,$sformatf("*.mstr_agnth[%0d]*",i),"mstr_config",m_mstr_cfg[i]);
			end

		m_slave_cfg = new[no_of_slave_agent];
		foreach(m_slave_cfg[i])
			begin
				m_slave_cfg[i]=slave_config::type_id::create($sformatf("m_slave_cfg[%0d]",i));
				if(!uvm_config_db#(virtual axi_intf)::get(this,"","axi_intf",m_slave_cfg[i].vif))
					`uvm_fatal(get_type_name(),"GETTING VIF FAILED")
				m_slave_cfg[i].is_active = UVM_ACTIVE;
				m_cfg.m_slave_cfg[i]=m_slave_cfg[i];
				uvm_config_db#(slave_config)::set(this,$sformatf("*.slave_agnth[%0d]*",i),"slave_config",m_slave_cfg[i]);
			end
	

		envh=env::type_id::create("envh",this);
	endfunction
endclass

class FIX_test extends test;
	`uvm_component_utils(FIX_test)

	FIX_seqs seqh;

	function new(string name = "FIX_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		seqh=FIX_seqs::type_id::create("seqh");

		phase.raise_objection(this);
		foreach(envh.m_agnth.mstr_agnth[i])
			seqh.start(envh.m_agnth.mstr_agnth[i].seqrh);
			#4000;
		phase.drop_objection(this);
	endtask
endclass

class INC_test extends test;
	`uvm_component_utils(INC_test)

	INC_seqs seqh;

	function new(string name = "INC_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		seqh=INC_seqs::type_id::create("seqh");

		phase.raise_objection(this);
		foreach(envh.m_agnth.mstr_agnth[i])
			seqh.start(envh.m_agnth.mstr_agnth[i].seqrh);
			#4000;
		phase.drop_objection(this);
	endtask
endclass

class WRAP_test extends test;
	`uvm_component_utils(WRAP_test)

	WRAP_seqs seqh;

	function new(string name = "WRAP_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		seqh=WRAP_seqs::type_id::create("seqh");

		phase.raise_objection(this);
		foreach(envh.m_agnth.mstr_agnth[i])
			seqh.start(envh.m_agnth.mstr_agnth[i].seqrh);
			#4000;
		phase.drop_objection(this);
	endtask
endclass



		
