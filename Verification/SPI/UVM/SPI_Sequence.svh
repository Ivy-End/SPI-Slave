`ifndef __SPI_SEQUENCE__
`define __SPI_SEQUENCE__

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "./UVM/SPI_SequenceRandRWTest.svh"
`include "./UVM/SPI_Transaction.svh"

class SPI_Sequence extends uvm_sequence #(SPI_Transaction);
    `uvm_object_utils(SPI_Sequence)

    // Private Functions
    extern         function new(string name = "SPI_Sequence");
    extern virtual function setTransactionCount(int count);
    extern virtual task     body();
    extern virtual task     doSequence();

    // Public Members
    int transactionCount = 0;
    
    SPI_Transaction requestTransaction;
    SPI_SequenceRandRWTest sequenceRWTest;
    
endclass

function SPI_Sequence::new(string name = "SPI_Sequence");
    super.new(name);
endfunction

function SPI_Sequence::setTransactionCount(int count);
    this.transactionCount = count;
    `uvm_info(get_type_name(), $sformatf("Function setTransactionCount() is called. transactionCount = %0d", this.transactionCount), UVM_LOW);
endfunction

task SPI_Sequence::body();
    if (starting_phase != null) begin
        starting_phase.raise_objection(this);
        `uvm_info(get_type_name(), "raise_objection().", UVM_LOW);
    end else begin
        `uvm_fatal(get_type_name(), "starting_phase is null.")
    end

    lock();
    for (int i = 0; i < this.transactionCount; i++) begin
        `uvm_info(get_type_name(), $sformatf("Transaction %0d is started.", i + 1), UVM_LOW);
        this.doSequence();
    end
    unlock();

    if (starting_phase != null) begin
        starting_phase.drop_objection(this);
        `uvm_info(get_type_name(), "drop_objection().", UVM_LOW);
    end else begin
        `uvm_fatal(get_type_name(), "starting_phase is null.")
    end
endtask

task SPI_Sequence::doSequence();
    `uvm_do(this.sequenceRWTest);
endtask

`endif