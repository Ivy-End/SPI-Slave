`ifndef __PARAMETERS__
`define __PARAMETERS__

// System Parameters
parameter P_SYSTEM_CLK_PERIOD    = 10;
parameter P_SYSTEM_RST_CLK_COUNT = 3;

// SPI Parameters
parameter P_SPI_TYPE_READ        = 0;
parameter P_SPI_TYPE_WRITE       = 1;
parameter P_SPI_ADDR_WIDTH       = 16;
parameter P_SPI_DATA_WIDTH       = 32;
parameter P_SPI_DATA_COUNT       = (2 ** P_SPI_ADDR_WIDTH);
parameter P_SPI_CLK_PERIOD       = 1000;
parameter P_SPI_RAND_TEST_COUNT  = P_SPI_DATA_COUNT * 2;

`endif