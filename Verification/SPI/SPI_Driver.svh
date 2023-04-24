`ifndef __SPI_DRIVER__
`define __SPI_DRIVER__

`include "uvm_macros.svh"
`include "Parameters.svh"
`include "SPI_Transaction.svh"
`include "SPI_Interface.svh"
import uvm_pkg::*;

class SPI_Driver extends uvm_driver #(SPI_Transaction);
    SPI_Transaction requestTransaction;
    SPI_Transaction responseTransaction;

    virtual SPI_Interface virtualInterface;

    `uvm_component_utils(SPI_Driver)

    extern         function      new(string name = "SPI_Driver", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);

    extern virtual task          doReset();
    extern virtual task          doDrive(SPI_Transaction transaction);
endclass

function SPI_Driver::new(string name = "SPI_Driver", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Function new() is called.", UVM_HIGH);
endfunction

function void SPI_Driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Function build_phase() is called.", UVM_HIGH);

    if(!uvm_config_db#(virtual SPI_Interface)::get(this, "", "virtualInterface", this.virtualInterface)) begin
        `uvm_fatal(get_type_name(), "virtualInterface not found")
    end 
endfunction

task SPI_Driver::main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Task main_phase() is called.", UVM_HIGH);

    forever begin
        if (!this.virtualInterface.aRst_n) begin
            this.doReset();
            @ (posedge this.virtualInterface.Clk);
        end else begin
            seq_item_port.try_next_item(this.requestTransaction);
            if (this.requestTransaction == null) begin
                `uvm_info(get_type_name(), "No transaction received.", UVM_LOW);
                @ (posedge this.virtualInterface.SCK);
            end else begin
                `uvm_info(get_type_name(), $sformatf("Transaction received: %s", this.requestTransaction.toString()), UVM_LOW);
                this.doDrive(this.requestTransaction);
                $cast(this.responseTransaction, this.requestTransaction.clone());
                this.responseTransaction.set_sequence_id(this.requestTransaction.get_sequence_id());
                seq_item_port.put_response(this.responseTransaction);
                seq_item_port.item_done();
            end
        end
    end
endtask

task SPI_Driver::doReset();
    `uvm_info(get_type_name(), "Function doReset() is called.", UVM_HIGH);
    this.virtualInterface.driving.CS   <= 1'b1;
    this.virtualInterface.driving.MOSI <= 1'b0;
endtask

task SPI_Driver::doDrive(SPI_Transaction transaction);
    `uvm_info(get_type_name(), "Function doDrive() is called.", UVM_HIGH);
    
    // Start transmission & Set MOSI to write mode
    @ (negedge this.virtualInterface.SCK);
    this.virtualInterface.driving.CS   <= 1'b0;
    this.virtualInterface.driving.MOSI <= transaction.RWType;

    // Send address
    @ (negedge this.virtualInterface.SCK);
    for (int i = 0; i < P_SPI_ADDR_WIDTH; i++) begin
        this.virtualInterface.driving.MOSI <= transaction.TXAddr[P_SPI_ADDR_WIDTH - 1 - i];
        @ (negedge this.virtualInterface.SCK);
    end

    // Reset MOSI
    this.virtualInterface.driving.MOSI <= 1'b0;

    @ (negedge this.virtualInterface.SCK);
    for (int i = 0; i < P_SPI_DATA_WIDTH; i++) begin
        if (transaction.RWType == P_SPI_TYPE_WRITE) begin
            this.virtualInterface.driving.MOSI <= transaction.TXData[P_SPI_DATA_WIDTH - 1 - i];
        end
        @ (negedge this.virtualInterface.SCK);
    end

    // Reset MOSI
    this.virtualInterface.driving.MOSI <= 1'b0;

    // Stop transmission
    @ (negedge this.virtualInterface.SCK);
    @ (negedge this.virtualInterface.SCK);
    this.virtualInterface.driving.CS   <= 1'b1;
endtask

`endif
