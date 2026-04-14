class mstr_seqs extends uvm_sequence #(axi_xtn);
	`uvm_object_utils(mstr_seqs)
	
	function new(string name = "mstr_seqs");
		super.new(name);
	endfunction

endclass

class FIX_seqs extends mstr_seqs;
	`uvm_object_utils(FIX_seqs)
	
	function new(string name = "FIX_seqs");
		super.new(name);
	endfunction


	task body();

		repeat(1)
			begin
				req=axi_xtn::type_id::create("req");
				start_item(req);
				assert(req.randomize() with {AWBURST == 2'b00; AWSIZE == 3'b001;});
				finish_item(req);

			end
	endtask
endclass

class INC_seqs extends mstr_seqs;
	`uvm_object_utils(INC_seqs)
	
	function new(string name = "INC_seqs");
		super.new(name);
	endfunction


	task body();

		repeat(1)
			begin
				req=axi_xtn::type_id::create("req");				
				start_item(req);
				assert(req.randomize() with {AWBURST == 2'b01; AWSIZE == 3'b010; AWADDR%2==1;});
				finish_item(req);

			end
	endtask
endclass

class WRAP_seqs extends mstr_seqs;
	`uvm_object_utils(WRAP_seqs)
	
	function new(string name = "WRAP_seqs");
		super.new(name);
	endfunction


	task body();

		repeat(1)
			begin
				req=axi_xtn::type_id::create("req");	
				start_item(req);
				assert(req.randomize() with {AWBURST == 2; AWSIZE == 3'b000;});
				finish_item(req);

			end
	endtask
endclass


	
	
