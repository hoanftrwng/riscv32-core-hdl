# riscv32-core-hdl
RTL design and simulation of a custom 32-bit RISC-V processor core (RV32I ISA) including ALU, Register File, and Datapath verified via ModelSim
Project Overview
This project focuses on the hardware architecture design at the Register Transfer Level (RTL). It involves the development of a custom 32-bit processor core based on the open-source RISC-V instruction set architecture (RV32I base ISA).

The objective is to implement a functional Datapath and Control Unit, enabling the processor to decode and execute fundamental instructions. The hardware design is fully described using HDL (Hardware Description Language) and verified for logic and timing correctness through comprehensive testbenches simulated in ModelSim.

Key Hardware Components
ALU (Arithmetic Logic Unit): Executes fundamental arithmetic (addition, subtraction) and logical operations (AND, OR, XOR, shifts).

Register File: A 32-bit, 32-entry general-purpose register array designed to support simultaneous read/write operations within a single clock cycle.

Datapath & Control Unit: Interconnects control signals for instruction flow management, including Instruction Fetch (IF), Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB) stages.

Testbench (Verification): A robust verification environment that generates stimulus signals to validate register states and architectural behavior, visualized through waveform analysis in ModelSim.
