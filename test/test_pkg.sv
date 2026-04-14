package test_pkg;
	
	import uvm_pkg::*;

	`include "uvm_macros.svh"

	`include "mstr_config.sv"
	`include "slave_config.sv"
	`include "env_config.sv"
	`include "axi_xtn.sv"
	`include "mstr_seqs.sv"
	`include "mstr_driver.sv"
	`include "mstr_monitor.sv"
	`include "mstr_sequencer.sv"
	`include "mstr_agent.sv"
	`include "mstr_agent_top.sv"
	
	`include "slave_driver.sv"
	`include "slave_monitor.sv"
	`include "slave_sequencer.sv"
	`include "slave_agent.sv"
	`include "slave_agent_top.sv"
	
	`include "scoreboard.sv"
	`include "env.sv"
	`include "test.sv"
endpackage
	
