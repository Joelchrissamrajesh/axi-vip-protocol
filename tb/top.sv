module top;
	import uvm_pkg::*;

	import test_pkg::*;

	bit clock;
	
	always
		#10 clock = ~clock;

	axi_intf intf(clock);

	initial
		begin
			uvm_config_db#(virtual axi_intf)::set(null,"*","axi_intf",intf);
			run_test();
		end
endmodule
