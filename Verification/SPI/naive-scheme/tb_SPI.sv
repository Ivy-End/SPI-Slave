`timescale 1ns / 1ps

`include "Parameter.svh"
`include "Utils.svh"

module tb_SPI;

    // ========================= Local Params =========================
    localparam LP_WAVEFORM_NAME = "tb_SPI.fsdb";

    Utils utils = new();

    // ======================== Testbench Reg/Wire ========================
    localparam LP_SPI_SIMU_COUNT = P_SPI_DATA_COUNT;

    integer                          goldenRegBank [P_SPI_DATA_COUNT - 1 : 0];
    integer                          fileHandleGolden;
    integer                          fileHandleDUT;
    
    reg  [P_SPI_ADDR_WIDTH - 1 : 0] writeAddress  [LP_SPI_SIMU_COUNT - 1 : 0];
    reg  [P_SPI_DATA_WIDTH - 1 : 0] writeData     [LP_SPI_SIMU_COUNT - 1 : 0];
    reg  [P_SPI_DATA_WIDTH - 1 : 0] readData      [LP_SPI_SIMU_COUNT - 1 : 0];

    reg                              Clk;
    reg                              aRst_n;

    reg  [P_SPI_DATA_WIDTH - 1 : 0] TXData;
    reg                              TXDataValid;

    wire                             RWType;

    wire [P_SPI_DATA_WIDTH - 1 : 0] RXData;
    wire                             RXDataValid;

    wire [P_SPI_ADDR_WIDTH - 1 : 0] RXAddr;
    wire                             RXAddrValid;

    reg                              CS;
    reg                              SCK;
    reg                              MOSI;
    wire                             MISO;
    wire                             RXAck;

    reg  [P_SPI_DATA_WIDTH - 1 : 0] RegBank [P_SPI_DATA_COUNT - 1 : 0];

    // ======================== Instantiate DUT ========================
    SPI #(
            .DATA_WIDTH(P_SPI_DATA_WIDTH),
            .ADDR_WIDTH(P_SPI_ADDR_WIDTH)
    ) U_SPI (
            .Clk(Clk),
            .aRst_n(aRst_n),

            .TXData(TXData),
            .TXDataValid(TXDataValid),

            .RWType(RWType),

            .RXData(RXData),
            .RXDataValid(RXDataValid),

            .RXAddr(RXAddr),
            .RXAddrValid(RXAddrValid),

            .CS(CS),
            .SCK(SCK),
            .MOSI(MOSI),
            .MISO(MISO),
            .RXAck(RXAck)
        );
    
    // ======================== DUT Specified Task =========================
    task CreateGoldenModel();
        for (int i = 0; i < LP_SPI_SIMU_COUNT; i++) begin
            writeAddress[i] = {$random} % (2 ** 16);
            writeData[i]    = {$random} % (2 ** 32 - 1);
            readData[i]     = 0;

            goldenRegBank[writeAddress[i]] = writeData[i];
        end

        for (int i = 0; i < LP_SPI_SIMU_COUNT; i++) begin
            $fwrite(fileHandleGolden, "%h %h\n", writeAddress[i], goldenRegBank[writeAddress[i]]);
        end
    endtask

    // ======================== Testbench Body ========================
    initial begin
        utils.WaveformDump($sformatf("%m.fsdb"));

        // Initialize Random Seed
        $srandom(1);

        // File I/O
            fileHandleGolden = $fopen("SPI_Golden.txt", "w");
            fileHandleDUT    = $fopen("SPI_DUT.txt"   , "w");

        // Signal Initialization
            Clk         = 1'b1;
            aRst_n      = 1'b0;
            TXData      = 32'h00000000;
            TXDataValid = 1'b0;
            CS          = 1'b1;
            SCK         = 1'b1;
            MOSI        = 1'b0;

        // Initialize Random Data
            CreateGoldenModel();

        // Reset & Clock Alignment
            repeat (1) #P_SYSTEM_CLK_PERIOD
                aRst_n = 1'b1;
            repeat (1) #(P_SPI_CLK_PERIOD - P_SYSTEM_CLK_PERIOD)

        // Write to RegBank (Total LP_SPI_SIMU_COUNT x 4 Bytes)
            for (int i = 0; i < LP_SPI_SIMU_COUNT; i++) begin
                repeat (1) #P_SPI_CLK_PERIOD
                    CS   = 1'b1;
                #(P_SPI_CLK_PERIOD / 2)
                    CS   = 1'b0;
                    MOSI = 1'b1;
                
                for (int j = 0; j < P_SPI_ADDR_WIDTH; j++) begin
                    repeat (1) #P_SPI_CLK_PERIOD
                        MOSI = writeAddress[i][j];
                end

                // Wait for a SCK
                repeat (1) #P_SPI_CLK_PERIOD
                
                for (int j = 0; j < P_SPI_DATA_WIDTH; j++) begin
                    repeat (1) #P_SPI_CLK_PERIOD
                        MOSI = writeData[i][j];
                end

                // Finish Write
                #(P_SPI_CLK_PERIOD * 3 / 2)
                    CS   = 1'b1;
                    MOSI = 1'b0;
            end
        
        // Read from RegBank (Total LP_SPI_DATA_COUNT x 4 Bytes)
            for (int i = 0; i < LP_SPI_SIMU_COUNT; i++) begin
                repeat (1) #P_SPI_CLK_PERIOD
                    CS   = 1'b1;
                #(P_SPI_CLK_PERIOD / 2)
                    CS   = 1'b0;
                    MOSI = 1'b0;
                
                for (int j = 0; j < P_SPI_ADDR_WIDTH; j++) begin
                    repeat (1) #P_SPI_CLK_PERIOD
                        MOSI = writeAddress[i][j];
                end

                // Wait for a SCK
                repeat (1) #P_SPI_CLK_PERIOD
                #(P_SPI_CLK_PERIOD / 2)
                
                for (int j = 0; j < P_SPI_DATA_WIDTH; j++) begin
                    repeat (1) #P_SPI_CLK_PERIOD
                        readData[i][j] = MISO;
                end

                // Finish Read
                #(P_SPI_CLK_PERIOD * 3 / 2)
                    CS   = 1'b1;
                    MOSI = 1'b0;

                $fwrite(fileHandleDUT, "%h %h\n", writeAddress[i], readData[i]);
            end
        
        // Stop Simulation
            repeat (1) #P_SPI_CLK_PERIOD
                $fclose(fileHandleGolden);
                $fclose(fileHandleDUT);
                $finish;
    end

    // Clock Generation
    always begin
        #(P_SPI_CLK_PERIOD / 2) SCK = ~SCK;
    end

    always begin
        #(P_SYSTEM_CLK_PERIOD / 2) Clk = ~Clk;
    end

    
    // ======================== Assistant Blocks ========================

    // Read from RegBank
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
    
    // Write to RegBank
    always @ (posedge Clk or negedge aRst_n) begin
        if (!aRst_n) begin
            for (int i = 0; i < P_SPI_DATA_COUNT; i++) begin
                RegBank[i] = 32'h00000000;
            end 
        end else if (RXDataValid) begin
                RegBank[RXAddr] <= RXData;
            end
    end

endmodule
