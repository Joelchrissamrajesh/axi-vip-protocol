class mstr_agent extends uvm_agent;
	`uvm_component_utils(mstr_agent)

	mstr_monitor monh;
	mstr_driver drvh;
	mstr_sequencer seqrh;

	mstr_config m_cfg;

	function new(string name = "mstr_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(mstr_config)::get(this,"","mstr_config",m_cfg))
			`uvm_fatal("mstr_agent","FAILED")
		super.build_phase(phase);
		monh = mstr_monitor::type_id::create("monh",this);
		if(m_cfg.is_active==UVM_ACTIVE)
		begin
			drvh = mstr_driver::type_id::create("drvh",this);
			seqrh = mstr_sequencer::type_id::create("seqrh",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		if(m_cfg.is_active == UVM_ACTIVE)
			drvh.seq_item_port.connect(seqrh.seq_item_export);
	endfunction
endclass

