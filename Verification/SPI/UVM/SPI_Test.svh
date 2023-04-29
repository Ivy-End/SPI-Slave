`ifndef __SPI_TEST__
`define __SPI_TEST__

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Parameters.svh"

`include "./UVM/SPI_Sequence.svh"
`include "./UVM/SPI_Environment.svh"

class SPI_Test extends uvm_test;
    `uvm_component_utils(SPI_Test)

    extern         function      new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    
    SPI_Sequence    testSequence;
    SPI_Environment environment;
endclass

function SPI_Test::new(string name, uvm_component parent = null);
    super.new(name, parent);
endfunction

function void SPI_Test::build_phase(uvm_phase phase);
    super.build_phase(phase);

    this.environment = SPI_Environment::type_id::create("environment", this);
    
    // Other settings
    set_report_max_quit_count(5);   // Set the maximum number of errors to 5
    uvm_default_table_printer.knobs.default_radix = UVM_HEX; // Set the default radix to hex
endfunction

function void SPI_Test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Other settings
    this.environment.inAgent.               set_report_verbosity_level_hier(UVM_LOW);
    this.environment.outAgent.      monitor.set_report_verbosity_level(UVM_LOW);
    this.environment.referencemodel.        set_report_verbosity_level(UVM_LOW);
    this.environment.scoreBoard.            set_report_verbosity_level(UVM_LOW);
endfunction

task SPI_Test::main_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 100us); // Set the drain time to 100us
    
    this.testSequence = new("sequence");
    this.testSequence.setTransactionCount(P_SPI_RAND_TEST_COUNT);
    this.testSequence.starting_phase = phase;
    this.environment.inAgent.sequencer.set_arbitration(SEQ_ARB_STRICT_FIFO);
    
    fork
        this.testSequence.start(this.environment.inAgent.sequencer, null, -1);
    join
endtask

function void SPI_Test::report_phase(uvm_phase phase);
    int errorCount;
    uvm_report_server reportServer;

    super.report_phase(phase);

    reportServer = get_report_server();
    errorCount = reportServer.get_severity_count(UVM_ERROR);

    if (errorCount > 0) begin
        `uvm_fatal(get_type_name(), $sformatf("There are %0d errors, verification [FAILED].", errorCount));
    end else begin
        `uvm_info(get_type_name(), "There are no errors, verification [PASSED].", UVM_LOW);
    end
endfunction

`endif