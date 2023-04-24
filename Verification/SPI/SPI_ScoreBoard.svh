`ifndef __SPI_SCORE_BOARD__
`define __SPI_SCORE_BOARD__

`include "uvm_macros.svh"
`include "Parameters.svh"
`include "SPI_Transaction.svh"
import uvm_pkg::*;

class SPI_ScoreBoard extends uvm_scoreboard;
    int totalPassCount        = 0;
    int totalReadCount        = 0;
    int totalWriteCount       = 0;
    int totalTransactionCount = 0;

    SPI_Transaction expectedTransactionQueue[$];
    SPI_Transaction actualTransactionQueue[$];

    uvm_blocking_get_port#(SPI_Transaction) expectedPort;   // ScoreBoard <-- ReferenceModel
    uvm_blocking_get_port#(SPI_Transaction) actualPort;     // ScoreBoard <-- Monitor

    `uvm_component_utils(SPI_ScoreBoard)

    extern         function      new(string name = "U_SPI_ScoreBoard", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);
endclass

function SPI_ScoreBoard::new(string name = "U_SPI_ScoreBoard", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "Function new() is called.", UVM_HIGH)

    expectedPort = new("expectedPort", this);
    actualPort = new("actualPort", this);
endfunction

function void SPI_ScoreBoard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Function build_phase() is called.", UVM_HIGH)
endfunction

task SPI_ScoreBoard::main_phase(uvm_phase phase);
    SPI_Transaction expectedTransactionComp;
    SPI_Transaction expectedTransactionTemp;
    SPI_Transaction acturalTransactionComp;
    SPI_Transaction acturalTransactionTemp;
    `uvm_info(get_type_name(), "Task main_phase() is called.", UVM_LOW)

    fork
        forever begin
            this.expectedPort.get(expectedTransactionTemp);
            this.expectedTransactionQueue.push_back(expectedTransactionTemp);            
            `uvm_info(get_type_name(), $sformatf("Expected transaction [%0h] is pushed into expectedTransactionQueue.", expectedTransactionTemp.toString()), UVM_HIGH)
            
            // Compare
            if (this.expectedTransactionQueue.size() > 0 && this.actualTransactionQueue.size() > 0) begin
                expectedTransactionComp = expectedTransactionQueue.pop_front();
                acturalTransactionComp = actualTransactionQueue.pop_front();

                totalTransactionCount++;
                if (expectedTransactionComp.RWType == P_SPI_TYPE_WRITE) begin
                    totalWriteCount++;
                end else begin
                    totalReadCount++;
                end
                
                if (expectedTransactionComp.RXData == acturalTransactionComp.RXData) begin//.compare(acturalTransactionComp)) begin
                    totalPassCount++;
                    `uvm_info(get_type_name(), $sformatf("[Passed] ACT/EXP = [%0h/%0h], R/W = [%0d/%0d], Pass = [%0d / %0d = %.2f%%].", acturalTransactionComp.RXData, expectedTransactionComp.RXData, totalReadCount, totalWriteCount, totalPassCount, totalTransactionCount, (totalPassCount * 100.0) / (totalTransactionCount)), UVM_LOW)
                end else begin
                    `uvm_fatal(get_type_name(), $sformatf("[Failed] ACT/EXP = [%0h/%0h], R/W = [%0d/%0d], Pass = [%0d / %0d = %.2f%%].", acturalTransactionComp.RXData, expectedTransactionComp.RXData, totalReadCount, totalWriteCount, totalPassCount, totalTransactionCount, (totalPassCount * 100.0) / (totalTransactionCount)))
                end
            end
        end

        forever begin
            this.actualPort.get(acturalTransactionTemp);
            this.actualTransactionQueue.push_back(acturalTransactionTemp);            
            `uvm_info(get_type_name(), $sformatf("Actual transaction [%0h] is pushed into actualTransactionQueue.", acturalTransactionTemp.toString()), UVM_HIGH)
        end
    join_none
endtask

`endif
