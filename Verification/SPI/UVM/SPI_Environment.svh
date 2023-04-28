`ifndef __SPI_ENVIRONMENT__
`define __SPI_ENVIRONMENT__

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "./UVM/SPI_Agent.svh"
`include "./UVM/SPI_ReferenceModel.svh"
`include "./UVM/SPI_ScoreBoard.svh"
`include "./UVM/SPI_Transaction.svh"

class SPI_Environment extends uvm_env;
    `uvm_component_utils(SPI_Environment)

    // Private Functions
    extern         function      new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    // Public Members
    SPI_Agent                               inAgent;
    SPI_Agent                               outAgent;
    SPI_ReferenceModel                      referencemodel;
    SPI_ScoreBoard                          scoreBoard;

    uvm_tlm_analysis_fifo#(SPI_Transaction) agent2referenceModel_fifo;
    uvm_tlm_analysis_fifo#(SPI_Transaction) referenceModel2scoreBoard_fifo;
    uvm_tlm_analysis_fifo#(SPI_Transaction) agent2scoreBoard_fifo;
endclass

function SPI_Environment::new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction

function void SPI_Environment::build_phase(uvm_phase phase);
    super.build_phase(phase);

    this.inAgent        = SPI_Agent::type_id::create("inAgent",                 this);
    this.outAgent       = SPI_Agent::type_id::create("outAgent",                this);
    this.referencemodel = SPI_ReferenceModel::type_id::create("referencemodel", this);
    this.scoreBoard     = SPI_ScoreBoard::type_id::create("scoreBoard",         this);

    this.inAgent.is_active              = UVM_ACTIVE;
    this.outAgent.is_active             = UVM_PASSIVE;

    this.agent2referenceModel_fifo      = new("agent2referenceModel_fifo",      this);
    this.referenceModel2scoreBoard_fifo = new("referenceModel2scoreBoard_fifo", this);
    this.agent2scoreBoard_fifo          = new("agent2scoreBoard_fifo",          this);
endfunction

function void SPI_Environment::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    this.inAgent.       analysisPort.connect(this.agent2referenceModel_fifo.     analysis_export    );
    this.referencemodel.blockingPort.connect(this.agent2referenceModel_fifo.     blocking_get_export);

    this.referencemodel.analysisPort.connect(this.referenceModel2scoreBoard_fifo.analysis_export    );
    this.scoreBoard.    expectedPort.connect(this.referenceModel2scoreBoard_fifo.blocking_get_export);

    this.outAgent.      analysisPort.connect(this.agent2scoreBoard_fifo.         analysis_export    );
    this.scoreBoard.    actualPort.  connect(this.agent2scoreBoard_fifo.         blocking_get_export);
endfunction

`endif
