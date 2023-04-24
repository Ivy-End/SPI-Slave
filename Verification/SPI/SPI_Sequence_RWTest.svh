`ifndef __SPI_SEQUENCE_RW_TEST__
`define __SPI_SEQUENCE_RW_TEST__

`include "uvm_macros.svh"
`include "SPI_Transaction.svh"
import uvm_pkg::*;

class SPI_Sequence_RWTest extends uvm_sequence #(SPI_Transaction);
    int transactionCount = 10;

    SPI_Transaction requestTransaction;
    SPI_Transaction responseTransaction;

    `uvm_object_utils(SPI_Sequence_RWTest);

    extern         function new(string name = "U_SPI_Sequence_RWTest");
    extern virtual task     body();
endclass

function SPI_Sequence_RWTest::new(string name = "U_SPI_Sequence_RWTest");
    super.new(name);
    `uvm_info(get_type_name(), "Function new() is called.", UVM_HIGH);
endfunction

task SPI_Sequence_RWTest::body();
    `uvm_do_pri_with(this.requestTransaction, -1, {});
    get_response(this.responseTransaction);
    `uvm_info(get_type_name(), $sformatf("requestTransaction: %s", this.requestTransaction.toString()),   UVM_HIGH);
    `uvm_info(get_type_name(), $sformatf("responseTransaction: %s", this.responseTransaction.toString()), UVM_HIGH);
endtask

`endif
