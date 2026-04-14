class mstr_sequencer extends uvm_sequencer #(axi_xtn);
	`uvm_component_utils(mstr_sequencer)

	function new(string name = "mstr_sequencer",uvm_component parent);
		super.new(name,parent);
	endfunction
endclass
