`ifndef __SPI_DRIVER__
`define __SPI_DRIVER__

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Parameters.svh"

`include "./UVM/SPI_Interface.svh"
`include "./UVM/SPI_Transaction.svh"

class SPI_Driver extends uvm_driver #(SPI_Transaction);
    `uvm_component_utils(SPI_Driver)

    extern         function      new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);

    extern virtual task          doReset();
    extern virtual task          doDrive(SPI_Transaction transaction);
    
            SPI_Transaction requestTransaction;
            SPI_Transaction responseTransaction;
    virtual SPI_Interface   virtualInterface;
endclass

function SPI_Driver::new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction

function void SPI_Driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual SPI_Interface)::get(this, "", "virtualInterface", this.virtualInterface)) begin
        `uvm_fatal(get_type_name(), "virtualInterface not found")
    end 
endfunction

task SPI_Driver::main_phase(uvm_phase phase);
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
                `uvm_info(get_type_name(), $sformatf("Transaction received: %s", this.requestTransaction.toString()), UVM_HIGH);

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
    this.virtualInterface.driving.CS   <= 1'b1;
    this.virtualInterface.driving.MOSI <= 1'b0;
endtask

task SPI_Driver::doDrive(SPI_Transaction transaction);
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
