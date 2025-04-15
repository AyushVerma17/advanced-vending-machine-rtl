# Advanced Vending Machine RTL Design

## Overview

This project implements a multi-item vending machine using Verilog HDL. The vending machine supports three different items with different prices (15¢, 20¢, and 25¢). It accepts nickels (5¢) and dimes (10¢) as inputs and provides change when necessary.

## Author

**Ayush Verma**

## Table of Contents

- [Project Description](#project-description)
- [Files in the Repository](#files-in-the-repository)
- [System Architecture](#system-architecture)
- [Finite State Machine Design](#finite-state-machine-design)
- [How to Run](#how-to-run)
- [Simulation Results](#simulation-results)

## Project Description

This vending machine is designed with three separate modules for items with different prices:

- **Item One**: Costs 15¢
- **Item Two**: Costs 20¢
- **Item Three**: Costs 25¢

Each module is implemented as a Finite State Machine (FSM) that tracks the amount of money inserted and determines when to dispense the item and whether to provide change.

Features of the vending machine:

- Accepts nickels (5¢) and dimes (10¢)
- Provides exact change (5¢) when overpayment occurs
- Returns to initial state after dispensing
- Item selection via a 2-bit input

## Files in the Repository

1. `vending_machine.v` - Main module implementing the vending machine logic
2. `vending_machine_tb.v` - Testbench to validate the functionality of the design
3. `rtl_view.png` - RTL schematic view of the synthesized design
4. `README.md` - This documentation file

## System Architecture

The vending machine consists of four main modules:

1. **Top-Level Module**: Handles item selection and routes signals to the appropriate item module
2. **Item_One Module**: FSM for the 15¢ item
3. **Item_Two Module**: FSM for the 20¢ item
4. **Item_Three Module**: FSM for the 25¢ item

### Input/Output Signals

- **Inputs**:

  - `item_number[1:0]`: 2-bit selector for choosing the item (00 = Item One, 01 = Item Two, 10 = Item Three)
  - `nickel_in`: Signal indicating a nickel is inserted
  - `dime_in`: Signal indicating a dime is inserted
  - `clock`: System clock
  - `reset`: System reset signal

- **Outputs**:
  - `dispense`: Signal to dispense the selected item
  - `nickel_out`: Signal to return a nickel as change

## Finite State Machine Design

Each item module is implemented as a separate FSM with states representing the accumulated amount. The number of states varies based on the item price:

### Item One (15¢)

- `S0`: Initial state ($0)
- `S5`: $5 inserted
- `S10`: $10 inserted
- `S15`: $15 inserted (dispense item)
- `S20`: $20 inserted (dispense item and return change)

### Item Two (20¢)

- `S0`: Initial state ($0)
- `S5`: $5 inserted
- `S10`: $10 inserted
- `S15`: $15 inserted
- `S20`: $20 inserted (dispense item)
- `S25`: $25 inserted (dispense item and return change)

### Item Three (25¢)

- `S0`: Initial state ($0)
- `S5`: $5 inserted
- `S10`: $10 inserted
- `S15`: $15 inserted
- `S20`: $20 inserted
- `S25`: $25 inserted (dispense item)
- `S30`: $30 inserted (dispense item and return change)

Each state transition handles the insertion of either a nickel or a dime, updating the accumulated amount accordingly. When the required amount is reached or exceeded, the item is dispensed and change is provided if necessary.

## How to Run

To simulate this design, you'll need a Verilog simulator like ModelSim, Icarus Verilog, or VCS.

### Using Icarus Verilog:

```bash
# Compile the design and testbench
iverilog -o vending_machine_sim vending_machine.v vending_machine_tb.v

# Run the simulation
vvp vending_machine_sim

# View waveforms (if you have GTKWave installed)
gtkwave vending_machine.vcd
```

### Using ModelSim:

```tcl
# Compile the design
vlog vending_machine.v vending_machine_tb.v

# Start simulation
vsim -novopt work.vending_machine_tb

# Add signals to waveform
add wave /vending_machine_tb/*

# Run the simulation
run -all
```

## Simulation Results

The testbench validates the following scenarios:

1. **Item One (15¢)**:

   - Inserting exact change (3 nickels = 15¢)
   - Inserting extra money (2 dimes = 20¢) and verifying change is returned

2. **Item Two (20¢)**:

   - Inserting exact change (2 dimes = 20¢)
   - Inserting extra money (1 dime + 3 nickels = 25¢) and verifying change is returned

3. **Item Three (25¢)**:
   - Inserting exact change (1 dime + 3 nickels = 25¢)
   - Inserting extra money (3 dimes = 30¢) and verifying change is returned

In all test cases, the vending machine should correctly dispense the selected item and return the appropriate change when necessary.

---

© 2025 Ayush Verma
