`ifndef __SPI_SEQUENCER__
`define __SPI_SEQUENCER__

`include "uvm_macros.svh"
`include "SPI_Transaction.svh"
import uvm_pkg::*;

class SPI_Sequencer extends uvm_sequencer #(SPI_Transaction);
    `uvm_component_utils(SPI_Sequencer)

    extern function new(string name = "U_SPI_Sequencer", uvm_component parent = null);
endclass

function SPI_Sequencer::new(string name = "U_SPI_Sequencer", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_full_name(), "Function new() is called.", UVM_LOW);
endfunction

`endif
