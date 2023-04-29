`ifndef __SPI_SEQUENCE_RAND_RW_TEST__
`define __SPI_SEQUENCE_RAND_RW_TEST__

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "./UVM/SPI_Transaction.svh"

class SPI_SequenceRandRWTest extends uvm_sequence #(SPI_Transaction);
    `uvm_object_utils(SPI_SequenceRandRWTest);

    extern         function new(string name = "SPI_SequenceRandRWTest");
    extern virtual task     body();

    int             transactionCount = 0;
    SPI_Transaction requestTransaction;
    SPI_Transaction responseTransaction;
endclass

function SPI_SequenceRandRWTest::new(string name = "SPI_SequenceRandRWTest");
    super.new(name);
endfunction

task SPI_SequenceRandRWTest::body();
    `uvm_do_pri_with(this.requestTransaction, -1, {});
    get_response(this.responseTransaction);
endtask

`endif
