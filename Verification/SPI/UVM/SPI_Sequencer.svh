`ifndef __SPI_SEQUENCER__
`define __SPI_SEQUENCER__

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "./UVM/SPI_Transaction.svh"

class SPI_Sequencer extends uvm_sequencer #(SPI_Transaction);
    `uvm_component_utils(SPI_Sequencer)

    extern function new(string name, uvm_component parent = null);
endclass

function SPI_Sequencer::new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction

`endif
