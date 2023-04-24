`ifndef __SPI_MONITOR__
`define __SPI_MONITOR__

`include "uvm_macros.svh"
`include "SPI_Transaction.svh"
`include "SPI_Interface.svh"
import uvm_pkg::*;

class SPI_Monitor extends uvm_monitor;
    SPI_Transaction transaction;

    virtual SPI_Interface virtualInterface;
    uvm_analysis_port #(SPI_Transaction) analysisPort;  // Monoitor -> Scoreboard / ReferenceModel

    `uvm_component_utils(SPI_Monitor)
    
    extern         function      new(string name = "U_SPI_Monitor", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);

    extern virtual task          doCollect();
    extern virtual task          doCollectInput();
    extern virtual task          doCollectOutput();
endclass

function SPI_Monitor::new(string name = "U_SPI_Monitor", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Function new() is called.", UVM_HIGH);

    this.analysisPort = new("analysisPort", this);
endfunction

function void SPI_Monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Function build_phase() is called.", UVM_HIGH);

    if(!uvm_config_db #(virtual SPI_Interface)::get(this, "", "virtualInterface", this.virtualInterface)) begin
        `uvm_fatal(get_type_name(), "virtualInterface not found!");
    end
endfunction

task SPI_Monitor::main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Function main_phase() is called.", UVM_HIGH);

    forever begin
        this.transaction = SPI_Transaction::type_id::create("transaction", this);
        this.doCollect();
        this.analysisPort.write(this.transaction);
        
        `uvm_info(get_type_name(), $sformatf("Transaction is collected. (TXAddr = %h, TXData = %h, RXData = %h, RWType = %b)", this.transaction.TXAddr, this.transaction.TXData, this.transaction.RXData, this.transaction.RWType), UVM_HIGH);
    end
endtask

task SPI_Monitor::doCollect();
    `uvm_info(get_type_name(), "Function doCollect() is called.", UVM_HIGH);
    
    fork
        this.doCollectInput();
        this.doCollectOutput();
    join_any
    
    disable fork;
endtask

task SPI_Monitor::doCollectInput();
    `uvm_info(get_type_name(), "Function doCollectInput() is called.", UVM_HIGH);

    // Monitoring RWType
    @ (negedge this.virtualInterface.monitoring.CS);
    @ (posedge this.virtualInterface.SCK);
    this.transaction.RWType = this.virtualInterface.monitoring.MOSI;
    
    // Monitoring Address
    @ (posedge this.virtualInterface.SCK);
    for (int i = 0; i < P_SPI_ADDR_WIDTH; i++) begin
        this.transaction.TXAddr[P_SPI_ADDR_WIDTH - 1 - i] = this.virtualInterface.monitoring.MOSI;
        @ (posedge this.virtualInterface.SCK);
    end

    // Waiting for 1 clock already done by the last state of previous for loop

    // Monitoring Data
    @ (posedge this.virtualInterface.SCK);
    for (int i = 0; i < P_SPI_DATA_WIDTH; i++) begin
        if (this.transaction.RWType == P_SPI_TYPE_WRITE) begin
            this.transaction.TXData[P_SPI_DATA_WIDTH - 1 - i] = this.virtualInterface.monitoring.MOSI;
        end
        @ (posedge this.virtualInterface.SCK);
    end
endtask

task SPI_Monitor::doCollectOutput();
    `uvm_info(get_type_name(), "Function doCollectOutput() is called.", UVM_HIGH);

    // Monitoring RWType
    @ (negedge this.virtualInterface.monitoring.CS);
    @ (posedge this.virtualInterface.SCK);
    
    // Monitoring Address
    @ (posedge this.virtualInterface.SCK);
    for (int i = 0; i < P_SPI_ADDR_WIDTH; i++) begin
        @ (posedge this.virtualInterface.SCK);
    end

    // Waiting for 1 clock already done by the last state of previous for loop

    // Monitoring Data
    @ (posedge this.virtualInterface.SCK);
    for (int i = 0; i < P_SPI_DATA_WIDTH; i++) begin
        this.transaction.RXData[P_SPI_DATA_WIDTH - 1 - i] = this.virtualInterface.monitoring.MISO;
        // `uvm_info(get_type_name(), $sformatf("RXData[%d] = %b", P_SPI_DATA_WIDTH - 1 - i, this.transaction.RXData[P_SPI_DATA_WIDTH - 1 - i]), UVM_LOW);
        @ (posedge this.virtualInterface.SCK);
    end
endtask

`endif
