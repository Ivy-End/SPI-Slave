`ifndef __SPI_INTERFACE__
`define __SPI_INTERFACE__

`include "Parameters.svh"

interface SPI_Interface (
    input Clk,
    input aRst_n,
    input SCK
);

    logic CS;
    logic MOSI;
    logic MISO;
    logic RXAck;

    clocking driving @ (posedge Clk);
        default input #0ns output #0ns;

        output CS, MOSI;
        input  MISO, RXAck;
    endclocking

    clocking monitoring @ (posedge Clk);
        default input #0ns output #0ns;

        input CS, MOSI, MISO, RXAck;
    endclocking

endinterface

`endif
