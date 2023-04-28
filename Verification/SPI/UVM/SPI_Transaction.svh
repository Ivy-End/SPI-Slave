`ifndef __SPI_TRANSACTION__
`define __SPI_TRANSACTION__

`include "uvm_macros.svh"
import uvm_pkg::*;

class SPI_Transaction extends uvm_sequence_item;
    
    randc bit [P_SPI_ADDR_WIDTH] TXAddr;
    rand  bit [P_SPI_DATA_WIDTH] TXData;
          bit [P_SPI_DATA_WIDTH] RXData;
    rand  bit                    RWType;

    constraint cstr_TXData { RWType == 0 -> TXData == 0; }
    constraint cstr_RWType { solve RWType before TXData; }

    `uvm_object_utils_begin(SPI_Transaction)
        `uvm_field_sarray_int(TXAddr, UVM_ALL_ON);
        `uvm_field_sarray_int(TXData, UVM_ALL_ON);
        `uvm_field_int       (RWType, UVM_ALL_ON);
    `uvm_object_utils_end

    extern function        new(string name = "U_SPI_Transaction");
    extern function string toString();
endclass

function SPI_Transaction::new(string name = "U_SPI_Transaction");
    super.new(name);
    `uvm_info(get_type_name(), "Function new() is called.", UVM_HIGH);
endfunction

function string SPI_Transaction::toString();
    return $sformatf("TXAddr = %h, TXData = %h, RXData = %h, RWType = %b", TXAddr, TXData, RXData, RWType);
endfunction

`endif