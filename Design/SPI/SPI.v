`timescale 1ns / 1ps

module SPI #(
    parameter DATA_WIDTH = 32,
              ADDR_WIDTH = 16
) (
    // To Internal
    input                       Clk,
    input                       aRst_n,

    input  [DATA_WIDTH - 1 : 0] TXData,      // SPI Data Transimit
    input                       TXDataValid, // SPI Data Transimit Valid

    output                      RWType,      // SPI Read or Write 1'b1 - RXD(Write) 1'b0 - TXD(Read)

    output [DATA_WIDTH - 1 : 0] RXData,      // SPI Data Receive                  (FPGA -> Chip)
    output                      RXDataValid, // SPI Data Receive Valid            (FPGA -> Chip)
 
    output [ADDR_WIDTH - 1 : 0] RXAddr,      // SPI Address Receive               (Chip -> FPGA)
    output                      RXAddrValid, // SPI Address Receive Valid         (Chip -> FPGA)

    // To External
    input                       CS,          // SPI Chip Select, Active Low        (FPGA -> Chip)
    input                       SCK,        // SPI Sync Clock                     (FPGA -> Chip)
    input                       MOSI,       // Master output -> Slave input       (FPGA -> Chip)
    output                      MISO,       // Slave output -> Master input       (Chip -> FPGA)
    output                      RXAck       // SPI Receive Acknowledge
);

    localparam  LP_SPI_STATE_IDLE     = 7'b0000001,
                LP_SPI_STATE_RW       = 7'b0000010,
                LP_SPI_STATE_ADDR     = 7'b0000100,
                LP_SPI_STATE_ADDR_ACK = 7'b0001000,
                LP_SPI_STATE_RX       = 7'b0010000,
                LP_SPI_STATE_TX       = 7'b0100000,
                LP_SPI_STATE_RX_ACK   = 7'b1000000;

    // CS / SCK Filter
    wire                          wCSPosedge;
    wire                          wCSNegedge;
    wire                          wSCKPosedge;
    wire                          wSCKNegedge;
    reg     [              1 : 0] rCS_f;
    reg     [              1 : 0] rSCK_f;

    // FSM
    reg     [              6 : 0] rCurState;
    reg     [              6 : 0] rNxtState;
    reg     [              4 : 0] rCounter;
    reg                           rCounterDone;

    // Internal RXD
    reg                           rRWType;        // RXD(Write) - 1     TXD(Read) - 0
    reg                           rRXDataValid;
    reg                           rRXAddrValid;
    reg     [ADDR_WIDTH  - 1 : 0] rRXAddr;
    reg     [DATA_WIDTH  - 1 : 0] rRXData;

    // Internal TXD
    reg     [DATA_WIDTH  - 1 : 0] rTXData;

    // External Output
    reg                           rMISO;
    reg                           rRXAck;


//------------------------ CS / SCK ----------------------//
    always @ (posedge Clk or negedge aRst_n) begin
        if (!aRst_n) begin
            rCS_f <= 2'b11;
            rSCK_f <= 2'b00;
        end else begin
            rCS_f <= {rCS_f[0],CS};
            rSCK_f <= {rSCK_f[0],SCK};
        end
    end

    assign  wCSPosedge  = ~rCS_f[1] &  rCS_f[0];
    assign  wCSNegedge  =  rCS_f[1] & ~rCS_f[0];

    assign  wSCKPosedge = ~rSCK_f[1] &  rSCK_f[0];
    assign  wSCKNegedge =  rSCK_f[1] & ~rSCK_f[0];


//------------------------ TXData Fetch ----------------------//
    always @ (posedge Clk or negedge aRst_n) begin
        if (!aRst_n) begin
            rTXData <= 0;
        end else if (wCSPosedge) begin
            rTXData <= 0;
        end else if (TXDataValid) begin
            rTXData <= TXData;
        end
    end

       
//------------------------ SPI FSM Stage 1 ----------------------//
    always @ (posedge Clk or negedge aRst_n) begin
        if (!aRst_n) begin
            rCurState <= LP_SPI_STATE_IDLE;
        end else begin
            rCurState <= rNxtState;
        end
    end  


//------------------------ SPI FSM Stage 2 ----------------------//
    always @ (*) begin
        rNxtState  =   rCurState;  
        case (rCurState)
        LP_SPI_STATE_IDLE : begin
                if (wCSNegedge) begin
                    rNxtState = LP_SPI_STATE_RW;
                end else begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end
            end
        LP_SPI_STATE_RW : begin
                if (wCSPosedge) begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end else if (rCounterDone) begin
                    rNxtState = LP_SPI_STATE_ADDR;
                end
            end
        LP_SPI_STATE_ADDR : begin
                if (wCSPosedge) begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end else if (rCounterDone) begin
                    rNxtState = LP_SPI_STATE_ADDR_ACK;
                end
            end
        LP_SPI_STATE_ADDR_ACK : begin
                if (wCSPosedge) begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end else if (rCounterDone) begin
                    if (rRWType) begin   // RXD - 1     TXD - 0
                        rNxtState = LP_SPI_STATE_RX;
                    end else begin
                        rNxtState = LP_SPI_STATE_TX;
                    end
                end
            end
        LP_SPI_STATE_RX : begin
                if (wCSPosedge) begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end else if (rCounterDone) begin
                    rNxtState = LP_SPI_STATE_RX_ACK;
                end
            end
        LP_SPI_STATE_TX : begin
                if (wCSPosedge) begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end else if (rCounterDone) begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end
            end
        LP_SPI_STATE_RX_ACK : begin
                if (wCSPosedge) begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end else if (rCounterDone) begin
                    rNxtState = LP_SPI_STATE_IDLE;
                end
            end
        default : begin end
        endcase
    end


//------------------------ SPI FSM Stage 3 ----------------------//
    always @ (posedge Clk or negedge aRst_n) begin
        if (!aRst_n) begin
            rCounter  <= 0;
            rRWType   <= 0;
            rRXAddr   <= 0;
            rRXData   <= 0;
            rMISO     <= 0;
        end else if (wCSPosedge)begin
            rCounter  <= 0;
            rRWType   <= 0;
            rRXAddr   <= 0;
            rRXData   <= 0;
            rMISO     <= 0;
        end else begin
            case (rCurState)
            LP_SPI_STATE_IDLE : begin
                    rCounter <= 0;
                end
            LP_SPI_STATE_RW : begin
                    if (rCounterDone) begin
                        rCounter <= 0;
                    end else if (wSCKPosedge) begin
                        rCounter <= rCounter + 1;
                        rRWType  <= MOSI;
                    end
                end
            LP_SPI_STATE_ADDR : begin
                    if (rCounterDone) begin
                        rCounter <= 0;
                    end else if (wSCKPosedge) begin
                        rCounter <= rCounter + 1;
                        rRXAddr  <= {MOSI,rRXAddr[ADDR_WIDTH - 1 : 1]};
                    end
                end
            LP_SPI_STATE_ADDR_ACK : begin
                    if (rCounterDone) begin
                        rCounter <= 0;
                    end else if (wSCKPosedge) begin
                        rCounter <= rCounter + 1;
                    end
                end
            LP_SPI_STATE_RX : begin
                    if (rCounterDone) begin
                        rCounter <= 0;
                    end else if (wSCKPosedge) begin
                        rCounter <= rCounter + 1;
                        rRXData  <= {MOSI,rRXData[DATA_WIDTH - 1 : 1]};
                    end
                end
            LP_SPI_STATE_TX : begin
                    if (rCounterDone) begin
                        rCounter <= 0;
                    end else if (wSCKNegedge) begin
                        rCounter <= rCounter + 1;
                        rMISO    <= rTXData[rCounter];  
                    end
                end
            LP_SPI_STATE_RX_ACK : begin
                    if (rCounterDone) begin
                        rCounter <= 0;
                    end else if (wSCKPosedge) begin
                        rCounter <= rCounter + 1;  
                    end
                end
            default : begin end
            endcase
        end
    end 


    always @ (posedge Clk or negedge aRst_n) begin
        if (!aRst_n) begin
            rCounterDone <= 0;
            rRXDataValid <= 0;
            rRXAddrValid <= 0;
        end else if (wCSPosedge) begin
            rCounterDone <= 0;
            rRXDataValid <= 0;
            rRXAddrValid <= 0;
        end else begin
            case (rNxtState)
            LP_SPI_STATE_IDLE : begin
                    rCounterDone <= 0;
                    rRXDataValid <= 0;
                    rRXAddrValid <= 0;
                end
            LP_SPI_STATE_RW : begin
                    if (rCounter == 0 && wSCKPosedge) begin
                        rCounterDone <= 1;
                    end else begin
                        rCounterDone <= 0;
                    end
                end
            LP_SPI_STATE_ADDR : begin
                    if (rCounter + 1 == ADDR_WIDTH && wSCKPosedge) begin
                        rCounterDone <= 1;
                        rRXAddrValid <= 1;
                    end else begin
                        rCounterDone <= 0;
                        rRXAddrValid <= 0;
                    end
                end
            LP_SPI_STATE_ADDR_ACK : begin
                    rRXAddrValid <= 0;
                    if (rCounter == 0 && wSCKPosedge) begin
                        rCounterDone <= 1;
                    end else begin
                        rCounterDone <= 0;
                    end
                end
            LP_SPI_STATE_RX : begin
                    if (rCounter + 1 == DATA_WIDTH && wSCKPosedge) begin
                        rCounterDone <= 1;
                        rRXDataValid <= 1;
                    end else begin
                        rCounterDone <= 0;
                        rRXDataValid <= 0;
                    end
                end
            LP_SPI_STATE_TX : begin
                    if (rCounter + 1 == DATA_WIDTH && wSCKNegedge) begin
                        rCounterDone <= 1;
                    end else begin
                        rCounterDone <= 0;
                    end
                end
            LP_SPI_STATE_RX_ACK : begin
                    if (rCounter == 0 && wSCKPosedge) begin
                        rCounterDone <= 1;
                    end else begin
                        rCounterDone <= 0;
                    end
                end
            default : begin end
            endcase
        end 
    end


//------------------------ Ack ----------------------//
    always @ (posedge Clk or negedge aRst_n) begin
        if(!aRst_n) begin
            rRXAck <= 0;
        end else if (wCSPosedge) begin
            rRXAck <= 0;
        end else begin
            rRXAck <= ((rNxtState == LP_SPI_STATE_ADDR_ACK) || (rNxtState == LP_SPI_STATE_RX_ACK)) ? 1 : 0;
        end
    end


//------------------------ Output Assignment ----------------------//
    assign  RWType          =   rRWType;
    assign  RXAddr          =   rRXAddr;
    assign  RXAddrValid     =   rRXAddrValid;
    
    assign  RXData          =   rRXData;
    assign  RXDataValid     =   rRXDataValid;

    assign  MISO            =   rMISO;
    assign  RXAck           =   rRXAck;


endmodule
