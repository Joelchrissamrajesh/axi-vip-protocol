class slave_agent extends uvm_agent;
	`uvm_component_utils(slave_agent)

	slave_monitor monh;
	slave_driver drvh;
	slave_sequencer seqrh;

	slave_config m_cfg;

	function new(string name = "slave_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(slave_config)::get(this,"","slave_config",m_cfg))
			`uvm_fatal("slave_agent","FAILED")
		super.build_phase(phase);
		monh = slave_monitor::type_id::create("monh",this);
		if(m_cfg.is_active==UVM_ACTIVE)
		begin
			drvh = slave_driver::type_id::create("drvh",this);
			seqrh = slave_sequencer::type_id::create("seqrh",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		if(m_cfg.is_active == UVM_ACTIVE)
			drvh.seq_item_port.connect(seqrh.seq_item_export);
	endfunction
endclass

