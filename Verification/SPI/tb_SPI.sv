`timescale 1ns / 1ps

`include "uvm_macros.svh"
`include "Parameters.svh"
`include "SPI_Interface.svh"
`include "SPI_Test.svh"
import uvm_pkg::*;

module tb_SPI;
    // ==================== Reg / Wire Definition ====================
    reg  [P_SPI_DATA_WIDTH - 1 : 0] RegBank [P_SPI_DATA_COUNT - 1 : 0];

    reg                             Clk;
    reg                             aRst_n;
    reg  [P_SPI_DATA_WIDTH - 1 : 0] TXData;
    reg                             TXDataValid;
    wire                            RWType;
    wire [P_SPI_DATA_WIDTH - 1 : 0] RXData;
    wire                            RXDataValid;
    wire [P_SPI_ADDR_WIDTH - 1 : 0] RXAddr;
    wire                            RXAddrValid;

    wire                            CS;
    reg                             SCK;
    

    // ==================== Interface Definition ====================
    SPI_Interface inputInferface(Clk, aRst_n, SCK);
    SPI_Interface outputInferface(Clk, aRst_n, SCK);

    // ==================== Instantiate DUT ====================
    SPI #(
        .DATA_WIDTH(P_SPI_DATA_WIDTH),
        .ADDR_WIDTH(P_SPI_ADDR_WIDTH)
    ) U_SPI (
        .Clk        (                Clk        ),
        .aRst_n     (                aRst_n     ),

        .TXData     (                TXData     ),
        .TXDataValid(                TXDataValid),

        .RWType     (                RWType     ),

        .RXData     (                RXData     ),
        .RXDataValid(                RXDataValid),

        .RXAddr     (                RXAddr     ),
        .RXAddrValid(                RXAddrValid),

        .CS         (                CS         ),
        .SCK        (                SCK        ),
        .MOSI       (inputInferface. MOSI       ),
        .MISO       (outputInferface.MISO       ),
        .RXAck      (outputInferface.RXAck      )
    );

    assign                 CS = inputInferface.CS;
    assign outputInferface.CS =                CS;
    
    // ==================== Read from RegBank ====================
    always @ (posedge Clk or negedge aRst_n) begin
        if (!aRst_n) begin
            TXData      <= {P_SPI_DATA_WIDTH{1'b0}}; 
            TXDataValid <= 1'b0;
        end else if (RXAddrValid) begin
            if (!RWType) begin
                TXData <= RegBank[RXAddr];
                TXDataValid <= 1'b1;
            end
        end else begin
            TXData      <= {P_SPI_DATA_WIDTH{1'b0}}; 
            TXDataValid <= 1'b0;
        end
    end
    
    // ==================== Write to RegBank ====================
    always @ (posedge Clk or negedge aRst_n) begin
        if (!aRst_n) begin
            for (int i = 0; i < P_SPI_DATA_COUNT; i++) begin
                RegBank[i] = {P_SPI_DATA_WIDTH{1'b0}};
            end 
        end else if (RXDataValid) begin
            RegBank[RXAddr] <= RXData;
        end
    end

    // ==================== Dump Waveform ====================
    initial begin
        $fsdbDumpfile($sformatf("%m.fsdb"));
        $fsdbDumpvars("+all");
    end

    // ==================== Run Test ====================
    initial begin
        run_test("SPI_Test");
    end

    // ==================== Connect Interface ====================
    initial begin
        uvm_config_db#(virtual SPI_Interface)::set(null, "uvm_test_top.testEnvironment.inAgent.driver",   "virtualInterface",  inputInferface);
        uvm_config_db#(virtual SPI_Interface)::set(null, "uvm_test_top.testEnvironment.inAgent.monitor",  "virtualInterface",  inputInferface);
        uvm_config_db#(virtual SPI_Interface)::set(null, "uvm_test_top.testEnvironment.outAgent.monitor", "virtualInterface", outputInferface);
    end

    // ==================== Generate Clock ====================
    initial begin
        Clk = 1'b0;
        forever #(P_SYSTEM_CLK_PERIOD / 2) Clk = ~Clk;
    end
    initial begin
        SCK = 1'b0;
        forever #(P_SPI_CLK_PERIOD / 2) SCK = ~SCK;
    end

    // ==================== Generate Reset ====================
    initial begin
        aRst_n = 1'b0;
        #(P_SYSTEM_CLK_PERIOD * P_SYSTEM_RST_CLK_COUNT) aRst_n = 1'b1;
    end

endmodule
