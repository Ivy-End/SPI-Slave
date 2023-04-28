`ifndef __SPI_SCORE_BOARD__
`define __SPI_SCORE_BOARD__

`include "uvm_macros.svh"
`include "Parameters.svh"
`include "./UVM/SPI_Transaction.svh"
import uvm_pkg::*;

class SPI_ScoreBoard extends uvm_scoreboard;
    `uvm_component_utils(SPI_ScoreBoard)

    // Public Functions
    extern         function      new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task          main_phase(uvm_phase phase);

    // Private Members
    int totalReadCount, totalWriteCount;
    int totalPassCount, totalTransactionCount;

    SPI_Transaction expectedTransactionQueue[$];
    SPI_Transaction actualTransactionQueue[$];

    uvm_blocking_get_port#(SPI_Transaction) expectedPort;   // ScoreBoard <-- ReferenceModel
    uvm_blocking_get_port#(SPI_Transaction) actualPort;     // ScoreBoard <-- Monitor

endclass

function SPI_ScoreBoard::new(string name, uvm_component parent = null);
    super.new(name, parent);

    this.expectedPort = new("expectedPort", this);
    this.actualPort   = new("actualPort", this);

    this.totalReadCount        = 0;
    this.totalWriteCount       = 0;
    this.totalPassCount        = 0;
    this.totalTransactionCount = 0;
endfunction

function void SPI_ScoreBoard::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

task SPI_ScoreBoard::main_phase(uvm_phase phase);
    SPI_Transaction acturalTransactionComp, expectedTransactionComp;
    SPI_Transaction acturalTransactionTemp, expectedTransactionTemp;

    fork
        forever begin
            this.expectedPort.get(expectedTransactionTemp);
            this.expectedTransactionQueue.push_back(expectedTransactionTemp);
            
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
        end
    join_none
endtask

`endif
