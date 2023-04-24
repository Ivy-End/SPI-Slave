`ifndef __SPI_TEST__
`define __SPI_TEST__

`include "uvm_macros.svh"
`include "Parameters.svh"
`include "SPI_Sequence.svh"
`include "SPI_Environment.svh"
import uvm_pkg::*;

class SPI_Test extends uvm_test;
    SPI_Sequence    testSequence;
    SPI_Environment testEnvironment;

    `uvm_component_utils(SPI_Test)

    extern         function      new(string name = "U_SPI_Test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    extern virtual function void final_phase(uvm_phase phase);
endclass

function SPI_Test::new(string name = "U_SPI_Test", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Function new() is called.", UVM_HIGH);
endfunction

function void SPI_Test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Function build_phase() is called.", UVM_HIGH);
    
    this.testEnvironment = SPI_Environment::type_id::create("testEnvironment", this);
    
    // Other settings
    set_report_max_quit_count(5);   // Set the maximum number of errors to 5
    //uvm_top.set_timeout(100us, 0); // Set the timeout to 100us
    uvm_default_table_printer.knobs.default_radix = UVM_HEX; // Set the default radix to hex
endfunction

function void SPI_Test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Function connect_phase() is called.", UVM_HIGH);
    
    // Other settings
    this.testEnvironment.inAgent.               set_report_verbosity_level_hier(UVM_LOW);
    this.testEnvironment.outAgent.      monitor.set_report_verbosity_level(UVM_LOW);
    this.testEnvironment.referencemodel.        set_report_verbosity_level(UVM_LOW);
    this.testEnvironment.scoreBoard.            set_report_verbosity_level(UVM_LOW);
endfunction

task SPI_Test::main_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 100us); // Set the drain time to 100us

    `uvm_info(get_type_name(), "Function main_phase() is called.", UVM_HIGH);
    
    this.testSequence = new("U_SPI_Sequence");
    this.testSequence.setTransactionCount(P_SPI_RAND_TEST_COUNT);
    this.testSequence.starting_phase = phase;
    this.testEnvironment.inAgent.inSequencer.set_arbitration(SEQ_ARB_STRICT_FIFO);
    
    fork
        this.testSequence.start(this.testEnvironment.inAgent.inSequencer, null, -1);
    join
endtask

function void SPI_Test::report_phase(uvm_phase phase);
    int errorCount;
    uvm_report_server reportServer;

    super.report_phase(phase);
    `uvm_info(get_type_name(), "Function report_phase() is called.", UVM_HIGH);

    reportServer = get_report_server();
    errorCount = reportServer.get_severity_count(UVM_ERROR);

    if (errorCount > 0) begin
        `uvm_fatal(get_type_name(), $sformatf("There are %0d errors, verification [FAILED].", errorCount));
    end else begin
        `uvm_info(get_type_name(), "There are no errors, verification [PASSED].", UVM_LOW);
    end
endfunction

function void SPI_Test::final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info(get_type_name(), "Function final_phase() is called.", UVM_HIGH);

    // uvm_top.print_topology();       // Print the topology
endfunction

`endif