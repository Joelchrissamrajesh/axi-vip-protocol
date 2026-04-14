class slave_seqs extends uvm_sequence #(axi_xtn);
	`uvm_object_utils(slave_seqs)
	
	function new(string name = "slave_seqs");
		super.new(name);
	endfunction
endclass
