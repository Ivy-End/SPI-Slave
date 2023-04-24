`ifndef __SPI_AGENT__
`define __SPI_AGENT__

`include "uvm_macros.svh"
`include "SPI_Sequencer.svh"
`include "SPI_Driver.svh"
`include "SPI_Monitor.svh"
import uvm_pkg::*;

class SPI_Agent extends uvm_agent;
    SPI_Sequencer inSequencer;
    SPI_Driver    driver;
    SPI_Monitor   monitor;
    uvm_analysis_port#(SPI_Transaction) analysisPort;  // Monoitor -> Scoreboard / ReferenceModel

    `uvm_component_utils(SPI_Agent)

    extern         function      new(string name = "U_SPI_Agent", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function SPI_Agent::new(string name = "U_SPI_Agent", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_full_name(), "Function new() is called.", UVM_LOW);
endfunction

function void SPI_Agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "Function build_phase() is called.", UVM_LOW);

    if (is_active == UVM_ACTIVE) begin
        this.inSequencer = SPI_Sequencer::type_id::create("inSequencer", this);
        this.driver    = SPI_Driver::type_id::create("driver", this);
    end
    
    this.monitor   = SPI_Monitor::type_id::create("monitor", this);
endfunction

function void SPI_Agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_full_name(), "Function connect_phase() is called.", UVM_LOW);

    if (is_active == UVM_ACTIVE) begin
        this.driver.seq_item_port.connect(inSequencer.seq_item_export);
    end

    this.analysisPort = monitor.analysisPort;
endfunction

`endif
