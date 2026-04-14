# AXI VIP Protocol – UVM Verification Environment

## Overview
This project implements a UVM-based Verification IP (VIP) for the AMBA AXI protocol. It is designed to verify AXI-based DUTs using a modular, reusable, and scalable verification environment.

The VIP supports configurable master and slave agents, enabling protocol-compliant stimulus generation, monitoring, and checking.

## Key Features
- UVM-based AXI Verification IP
- Supports AXI4 / AXI4-Lite protocol transactions
- Master and Slave agent architecture
- Configurable address, data, and ID widths
- Transaction-level modeling and stimulus generation
- Protocol compliance checking
- Reusable and scalable verification components

## AXI VIP Architecture
The verification environment consists of:

- AXI Master Agent (Driver, Monitor, Sequencer)
- AXI Slave Agent (Driver, Monitor, Sequencer)
- Environment (env)
- Scoreboard
- Virtual Sequencer
- Test Layer

The VIP generates AXI transactions and drives them to the DUT while monitoring responses and checking correctness.

## Verification Methodology
- Built using Universal Verification Methodology (UVM)
- Sequence-driven stimulus generation
- Driver controls AXI interface signals
- Monitor captures transactions for analysis
- Scoreboard validates expected vs actual behavior

AXI VIP enables:
- Read/Write transaction verification
- Burst transfer validation
- Protocol timing and handshake checking

AXI VIP is widely used for simulating AXI interfaces and validating protocol correctness in RTL designs :contentReference[oaicite:0]{index=0}.

## Test Scenarios
- Single read/write transactions
- Burst transactions
- Back-to-back transfers
- Randomized transaction sequences (optional enhancement)

## Tools & Technologies
- SystemVerilog
- UVM (Universal Verification Methodology)
- AXI Protocol
- Synopsys VCS / QuestaSim (recommended)

## Repository Structure
axi-vip-protocol/
│
├── rtl/ # DUT / Interface files
│
├── agents/ # AXI Agents
│ ├── master_agent/
│ ├── slave_agent/
│
├── tb/ # Testbench Environment
│ ├── env.sv
│ ├── scoreboard.sv
│ ├── virtual_sequencer.sv
│ ├── top.sv
│
├── tests/ # Testcases
│ ├── base_test.sv
│ ├── test_pkg.sv
│
├── sim/ # Simulation scripts / Makefile
│
└── README.md


## How to Run
cd sim
make run

##Results
AXI transactions successfully generated and verified
Protocol checks passed without violations
Functional behavior validated using scoreboard
Future Enhancements
Functional and code coverage integration
Error injection scenarios
Out-of-order transaction handling
AXI interconnect verification support

##Author
Joel Chris Sam Rajesh S
VLSI Design & Verification Engineer (Fresher)
