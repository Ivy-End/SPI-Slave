`ifndef __SPI_REFERENCE_MODEL__
`define __SPI_REFERENCE_MODEL__

`include "uvm_macros.svh"
`include "Parameters.svh"
`include "SPI_Transaction.svh"
`include "SPI_Interface.svh"
import uvm_pkg::*;

class SPI_ReferenceModel extends uvm_component;
    uvm_blocking_get_port#(SPI_Transaction) blockingPort;   // ReferenceModel <-- Monitor
    uvm_analysis_port#(SPI_Transaction) analysisPort;       // ReferenceModel --> Scoreboard

    bit [P_SPI_DATA_WIDTH - 1 : 0] RegBank [P_SPI_DATA_COUNT - 1 : 0];

    `uvm_component_utils(SPI_ReferenceModel)

    extern         function      new(string name = "U_SPI_Reference", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);
endclass

function SPI_ReferenceModel::new(string name = "U_SPI_Reference", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Function new() is called.", UVM_HIGH)
endfunction

function void SPI_ReferenceModel::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Function build_phase() is called.", UVM_HIGH)

    blockingPort = new("blockingPort", this);
    analysisPort = new("analysisPort", this);
endfunction

task SPI_ReferenceModel::main_phase(uvm_phase phase);
    SPI_Transaction acturalTransaction;
    SPI_Transaction expectedTransaction;
    `uvm_info(get_type_name(), "Task main_phase() is called.", UVM_HIGH)

    `uvm_info(get_type_name(), "Init RegBank.", UVM_LOW)
    for (int i = 0; i < P_SPI_DATA_COUNT; i++) begin
        RegBank[i] = 0;
    end
    
    forever begin
        expectedTransaction = new("expectedTransaction");
        blockingPort.get(acturalTransaction);        
        `uvm_info(get_type_name(), $sformatf("Transaction received: %s", acturalTransaction.toString()), UVM_HIGH)

        expectedTransaction.TXAddr = acturalTransaction.TXAddr;
        expectedTransaction.TXData = acturalTransaction.TXData;
        expectedTransaction.RWType = acturalTransaction.RWType;
        
        if (acturalTransaction.RWType == P_SPI_TYPE_WRITE) begin
            RegBank[acturalTransaction.TXAddr] = acturalTransaction.TXData;
        end else begin
            expectedTransaction.RXData = RegBank[acturalTransaction.TXAddr];
        end

        analysisPort.write(expectedTransaction);
    end
endtask

`endif