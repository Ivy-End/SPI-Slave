`ifndef PARAMETER_SVH
`define PARAMETER_SVH

// System Parameters
parameter P_SYSTEM_CLK_PERIOD    = 10;
parameter P_SYSTEM_RST_CLK_COUNT = 10;

// SPI Parameters
parameter P_SPI_DATA_WIDTH       = 32;
parameter P_SPI_ADDR_WIDTH       = 16;
parameter P_SPI_DATA_COUNT       = (2 ** P_SPI_ADDR_WIDTH);
parameter P_SPI_CLK_PERIOD       = 100;

`endif