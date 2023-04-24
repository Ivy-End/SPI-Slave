`ifndef __SPI_ENVIRONMENT__
`define __SPI_ENVIRONMENT__

`include "uvm_macros.svh"
`include "SPI_Transaction.svh"
`include "SPI_Agent.svh"
`include "SPI_ReferenceModel.svh"
`include "SPI_ScoreBoard.svh"
import uvm_pkg::*;

class SPI_Environment extends uvm_env;
    SPI_Agent          inAgent;
    SPI_Agent          outAgent;
    SPI_ReferenceModel referencemodel;
    SPI_ScoreBoard     scoreBoard;

    uvm_tlm_analysis_fifo#(SPI_Transaction) agent2referenceModel_fifo;
    uvm_tlm_analysis_fifo#(SPI_Transaction) referenceModel2scoreBoard_fifo;
    uvm_tlm_analysis_fifo#(SPI_Transaction) agent2scoreBoard_fifo;

    `uvm_component_utils(SPI_Environment)

    extern         function      new(string name = "U_SPI_Environment", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function SPI_Environment::new(string name = "U_SPI_Environment", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_full_name(), "Function new() is called.", UVM_LOW)
endfunction

function void SPI_Environment::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "Function build_phase() is called.", UVM_LOW)

    inAgent        = SPI_Agent::type_id::create("inAgent", this);
    outAgent       = SPI_Agent::type_id::create("outAgent", this);
    referencemodel = SPI_ReferenceModel::type_id::create("referencemodel", this);
    scoreBoard     = SPI_ScoreBoard::type_id::create("scoreBoard", this);

    inAgent.is_active = UVM_ACTIVE;
    outAgent.is_active = UVM_PASSIVE;

    agent2referenceModel_fifo      = new("agent2referenceModel_fifo",      this);
    referenceModel2scoreBoard_fifo = new("referenceModel2scoreBoard_fifo", this);
    agent2scoreBoard_fifo          = new("agent2scoreBoard_fifo",          this);
endfunction

function void SPI_Environment::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_full_name(), "Function connect_phase() is called.", UVM_LOW)

    inAgent.       analysisPort.connect(agent2referenceModel_fifo.     analysis_export    );
    referencemodel.blockingPort.connect(agent2referenceModel_fifo.     blocking_get_export);

    referencemodel.analysisPort.connect(referenceModel2scoreBoard_fifo.analysis_export    );
    scoreBoard.    expectedPort.connect(referenceModel2scoreBoard_fifo.blocking_get_export);

    outAgent.      analysisPort.connect(agent2scoreBoard_fifo.         analysis_export    );
    scoreBoard.    actualPort.  connect(agent2scoreBoard_fifo.         blocking_get_export);
endfunction

`endif
