`ifndef __SPI_REFERENCE_MODEL__
`define __SPI_REFERENCE_MODEL__

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Parameters.svh"

`include "./UVM/SPI_Interface.svh"
`include "./UVM/SPI_Transaction.svh"

class SPI_ReferenceModel extends uvm_component;
    `uvm_component_utils(SPI_ReferenceModel)

    // Public Functions
    extern         function      new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);
    
    // Private Members
    uvm_blocking_get_port#(SPI_Transaction) blockingPort;   // ReferenceModel <-- Monitor
    uvm_analysis_port    #(SPI_Transaction) analysisPort;   // ReferenceModel --> Scoreboard

    bit [P_SPI_DATA_WIDTH - 1 : 0] RegBank [P_SPI_DATA_COUNT - 1 : 0];
endclass

function SPI_ReferenceModel::new(string name, uvm_component parent = null);
    super.new(name, parent);

    `uvm_info(get_type_name(), "Init RegBank.", UVM_LOW)
    for (int i = 0; i < P_SPI_DATA_COUNT; i++) begin
        this.RegBank[i] = 0;
    end
endfunction

function void SPI_ReferenceModel::build_phase(uvm_phase phase);
    super.build_phase(phase);

    this.blockingPort = new("blockingPort", this);
    this.analysisPort = new("analysisPort", this);
endfunction

task SPI_ReferenceModel::main_phase(uvm_phase phase);
    SPI_Transaction acturalTransaction;
    SPI_Transaction expectedTransaction;

    forever begin
        expectedTransaction = new("expectedTransaction");
        this.blockingPort.get(acturalTransaction);

        expectedTransaction.TXAddr = acturalTransaction.TXAddr;
        expectedTransaction.TXData = acturalTransaction.TXData;
        expectedTransaction.RWType = acturalTransaction.RWType;
        
        if (acturalTransaction.RWType == P_SPI_TYPE_WRITE) begin
            this.RegBank[acturalTransaction.TXAddr] = acturalTransaction.TXData;
        end else begin
            expectedTransaction.RXData = this.RegBank[acturalTransaction.TXAddr];
        end

        this.analysisPort.write(expectedTransaction);
    end
endtask

`endif