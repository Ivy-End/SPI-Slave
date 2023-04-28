`ifndef __SPI_AGENT__
`define __SPI_AGENT__

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "./UVM/SPI_Driver.svh"
`include "./UVM/SPI_Monitor.svh"
`include "./UVM/SPI_Sequencer.svh"

class SPI_Agent extends uvm_agent;
    `uvm_component_utils(SPI_Agent)

    extern         function      new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    SPI_Driver                          driver;
    SPI_Monitor                         monitor;
    SPI_Sequencer                       sequencer;
    uvm_analysis_port#(SPI_Transaction) analysisPort;  // Monoitor -> Scoreboard / ReferenceModel
endclass

function SPI_Agent::new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction

function void SPI_Agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (is_active == UVM_ACTIVE) begin
        this.driver    = SPI_Driver::type_id::create("driver", this);
        this.sequencer = SPI_Sequencer::type_id::create("sequencer", this);
    end
    
    this.monitor   = SPI_Monitor::type_id::create("monitor", this);
endfunction

function void SPI_Agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin
        this.driver.seq_item_port.connect(sequencer.seq_item_export);
    end

    this.analysisPort = monitor.analysisPort;
endfunction

`endif
