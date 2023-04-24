`ifndef __SPI_SEQUENCE__
`define __SPI_SEQUENCE__

`include "uvm_macros.svh"
`include "SPI_Transaction.svh"
`include "SPI_Sequence_RWTest.svh"
import uvm_pkg::*;

class SPI_Sequence extends uvm_sequence #(SPI_Transaction);
    int transactionCount = 10;
    
    SPI_Transaction requestTransaction;

    SPI_Sequence_RWTest sequenceRWTest;

    `uvm_object_utils(SPI_Sequence)

    extern         function new(string name = "U_SPI_Sequence");
    extern virtual function setTransactionCount(int count);
    extern virtual task     body();
    extern virtual task     doSequence();
    
endclass

function SPI_Sequence::new(string name = "U_SPI_Sequence");
    super.new(name);
    `uvm_info(get_type_name(), "Function new() is called.", UVM_HIGH);
endfunction

function SPI_Sequence::setTransactionCount(int count);
    this.transactionCount = count;
    `uvm_info(get_type_name(), $sformatf("Function setTransactionCount() is called. transactionCount = %0d", this.transactionCount), UVM_LOW);
endfunction

task SPI_Sequence::body();
    if (starting_phase != null) begin
        starting_phase.raise_objection(this);
        `uvm_info(get_type_name(), "raise_objection().", UVM_HIGH);
    end else begin
        `uvm_fatal(get_type_name(), "starting_phase is null.")
    end
    
    `uvm_info(get_type_name(), "Function body() is called.", UVM_HIGH);

    lock();
    for (int i = 0; i < this.transactionCount; i++) begin
        `uvm_info(get_type_name(), $sformatf("Transaction %0d is started.", i + 1), UVM_LOW);
        this.doSequence();
    end
    unlock();

    if (starting_phase != null) begin
        starting_phase.drop_objection(this);
        `uvm_info(get_type_name(), "drop_objection().", UVM_HIGH);
    end else begin
        `uvm_fatal(get_type_name(), "starting_phase is null.")
    end
endtask

task SPI_Sequence::doSequence();
    `uvm_info(get_type_name(), "Function runSequence() is called.", UVM_HIGH);

    `uvm_do(this.sequenceRWTest);
endtask

`endif