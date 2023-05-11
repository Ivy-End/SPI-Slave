# SPI-Slave

## Introduction

SPI-Slave is a Verilog-based project that implements the SPI communication protocol for a slave device. This repository contains the design files, synthesis scripts, and verification testbenches for the SPI-Slave project. 

## Directory Structure

The SPI-Slave repository has the following directory structure:

- `Design`: Contains the Verilog source file for the SPI slave module.
- `Synthesis`: Contains the synthesis scripts, design constraints, and synthesis reports for the SPI slave module.
  - `SPI`: Contains the synthesis output files for the SPI slave module.
    - `dc`: Contains the Design Compiler output files, such as design constraints (`ddc/SPI.ddc`), the netlist (`netlist/SPI.cg.gv`), and the synthesis report (`report/SPI.*`).
    - `sdc`: Contains the Synopsys Design Constraints (SDC) file for the SPI slave module (sdc/SPI.sdc).
   - `SPI_dc.tcl`: Contains the Design Compiler synthesis script for the SPI slave module.
- `Verification`: Contains the UVM testbench and simulation files for the SPI slave module.
  - `SPI`: Contains the SPI testbench and simulation files.
    - `UVM`: Contains the UVM testbench files for the SPI slave module, including the agent (`SPI_Agent.svh`), driver (`SPI_Driver.svh`), monitor (`SPI_Monitor.svh`), scoreboard (`SPI_ScoreBoard.svh`), reference model (`SPI_ReferenceModel.svh`), sequence (`SPI_Sequence.svh`), sequence generator (`SPI_SequenceRandRWTest.svh`), and the transaction (`SPI_Transaction.svh`).
    - `sim`: Contains the simulation output files for the SPI slave module.
      - `dc`: Contains the Design Compiler simulation output files, such as the list of input files (list.f), the simulation log (simv.log), and the waveform dump (tb_SPI.fsdb).
      - `rtl`: Contains the RTL simulation output files, such as the list of input files (list.f), the simulation log (simv.log), and the waveform dump (tb_SPI.fsdb).
    - `Parameters.svh`: Contains the configuration parameters for the SPI slave module.
    - `makefile`: Contains the makefile to build the SPI slave testbench.
    - `tb_SPI.rc`: Contains the Cadence simulation runtime configuration file.
    - `tb_SPI.sv`: Contains the top-level testbench file for the SPI slave module.
- `LICENSE`: Contains the MIT License for the SPI-Slave project.
- `README.md`: Contains the project's README file.

## Getting Started

To get started, make sure you have installed all necessary tools and libraries. Once you have done that, follow these steps:

1. Clone this repository to your local machine:

```
git clone https://github.com/your-username/SPI-Slave.git
```

2. Change directory to the `Verification/SPI` folder:

```
cd Verification/SPI
```

3. Open the Makefile and update the variables at the beginning of the file as needed. The variables are:
  - `DESIGN_NAME`: The name of the design under test.
  - `LOG_VCS`: The name of the log file for VCS.
  - `LOG_SIMV`: The name of the log file for the simulation.
  - `FILE_LIST`: The path to the file list for RTL simulation.
  - `FILE_LIST_DC`: The path to the file list for DC simulation.
  - `UVM_HOME`: The path to the UVM installation directory.
 
Run the following command to compile the design and generate an executable:

```
make simv
```

This will compile the design and generate the executable simv in the tb_SPI directory.

4. Run the following command to simulate the design:

```
make sim
```

This will run the simulation and generate waveforms in the sim directory.

5. If you want to run a DC simulation, run the following command:

```
make dcsimv
```

This will compile the design for DC simulation and generate the executable simv in the tb_SPI directory.

6. Run the following command to simulate the design using DC:

```
make dcsim
```

This will run the simulation and generate waveforms in the dc directory.

7. Use the following command to clean up the generated files:

```
make cleanall
```

This will remove all generated files and directories except the repository itself.

## Timing

This SPI slave module is designed in Verilog with 1-bit read/write flag bits, 16-bit address bits and 32-bit data bits, and is verified using UVM.

The timing diagram for **writing data** is shown in the following figure.

![image](https://user-images.githubusercontent.com/3644544/234032498-664857c9-2ead-4948-84c5-a715c665e1fd.png)

The timing diagram for **reading data** is shown in the following figure.

![image](https://user-images.githubusercontent.com/3644544/234032563-a6d8164d-6ff4-40ed-acf7-2965b4f6f3ff.png)
