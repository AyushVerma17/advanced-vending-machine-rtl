//========================================================================
// File:         vending_machine_mealy.v
// Author:       Ayush Verma
// Date:         22-September-2025
//
// Description:
// This module implements a Mealy Finite State Machine (FSM) to control
// a simple vending machine. In Mealy FSM, outputs depend both on current 
// state as well as input. It follows the two-process style with a sequential block for 
// state registers and a combinational block for next-state and output logic.
//
// Design Rules / Specifications:
// 1. Item Prices: 15 cents, 20 cents, 25 cents
// 2. Accepted Coins: Nickel (5 cents) and Dime (10 cents)
// 3. Rejected Coins: Penny and Quarter are not supported
// 4. Change: The machine provides correct change for overpayment
// 5. Cancel: A transaction can be cancelled at any point to refund money
// 6. Mealy Machine: Outputs depend on both current state and input
//========================================================================


module vending_machine_mealy(
    input clk,
    input rst,
    input nickel,
    input dime,
    input cancel,
    input [1:0] item_select,

    output reg vend,
    output reg change_5C,
    output reg change_10C
);

// State definitions - organized by item price tracks
parameter S_IDLE = 4'b0000,

        //--15 Cent Item Track--
          S_0C_15C = 4'b0001,
          S_5C_15C = 4'b0010,
          S_10C_15C = 4'b0011,

        //--20 Cent Item Track--
          S_0C_20C = 4'b0100,
          S_5C_20C = 4'b0101,
          S_10C_20C = 4'b0110,
          S_15C_20C = 4'b0111,
          S_CHANGE_15C_20C = 4'b1000,   // MULTI-CYCLE: Refund 15¢ (10¢→5¢)
          
        //--25 Cent Item Track--
          S_0C_25C = 4'b1001,
          S_5C_25C = 4'b1010,
          S_10C_25C = 4'b1011,
          S_15C_25C = 4'b1100,
          S_20C_25C = 4'b1101,
          S_CHANGE_15C_25C = 4'b1110,   // MULTI-CYCLE: Refund 15¢ (10¢→5¢)
          S_CHANGE_20C_25C = 4'b1111;   // MULTI-CYCLE: Refund 20¢ (10¢→10¢)

parameter ITEM_15C = 2'b01,
          ITEM_20C = 2'b10,
          ITEM_25C = 2'b11;

reg first_coin_dispensed, next_coin_dispensed; // Multi-cycle refund tracking
reg [3:0] ps, ns; // Present state, Next state (4 bits for 16 states)

//===============================================================
// Sequential Logic - State Register and Multi-cycle Tracker
// Updates state on clock edge, asynchronous reset to IDLE
//===============================================================
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        ps <= S_IDLE;
        first_coin_dispensed <= 1'b0;
    end
    else begin
        ps <= ns;
        first_coin_dispensed <= next_coin_dispensed;
    end
end

//================================================================
// Combinational Logic - Next State and Output Decode
// Outputs depend on present state AND inputs (Mealy characteristic)
//================================================================
always @(*) begin
    // Default assignments prevent latches
    ns = ps;
    next_coin_dispensed = first_coin_dispensed;
    vend = 1'b0;
    change_5C = 1'b0;
    change_10C = 1'b0;

    case(ps)
        S_IDLE: begin
            if(item_select == ITEM_15C)
                ns = S_0C_15C;
            else if(item_select == ITEM_20C)
                ns = S_0C_20C;
            else if(item_select == ITEM_25C)
                ns = S_0C_25C;
        end

        // --- 15 Cent Track ---
        S_0C_15C: begin
            if(nickel) ns = S_5C_15C;
            else if(dime) ns = S_10C_15C;
            else if(cancel) ns = S_IDLE;
        end
        S_5C_15C: begin
            if(nickel) ns = S_10C_15C;
            else if(dime) begin // Exact: 5¢+10¢=15¢
                ns = S_IDLE;
                vend = 1'b1;
            end
            else if(cancel) begin
                ns = S_IDLE;
                change_5C = 1'b1;
            end
        end
        S_10C_15C: begin
            if(nickel) begin // Exact: 10¢+5¢=15¢
                ns = S_IDLE;
                vend = 1'b1;
            end
            else if(dime) begin // Overpay: 10¢+10¢=20¢
                ns = S_IDLE;
                vend = 1'b1;
                change_5C = 1'b1;
            end
            else if(cancel) begin
                ns = S_IDLE;
                change_10C = 1'b1;
            end
        end

        // --- 20 Cent Track ---
        S_0C_20C: begin
            if(nickel) ns = S_5C_20C;
            else if(dime) ns = S_10C_20C;
            else if(cancel) ns = S_IDLE;
        end
        S_5C_20C: begin
            if(nickel) ns = S_10C_20C;
            else if(dime) ns = S_15C_20C;
            else if(cancel) begin
                ns = S_IDLE;
                change_5C = 1'b1;
            end
        end
        S_10C_20C: begin
            if(nickel) ns = S_15C_20C;
            else if(dime) begin // Exact: 10¢+10¢=20¢
                ns = S_IDLE;
                vend = 1'b1;
            end
            else if(cancel) begin
                ns = S_IDLE;
                change_10C = 1'b1;
            end
        end
        S_15C_20C: begin
            if(nickel) begin // Exact: 15¢+5¢=20¢
                ns = S_IDLE;
                vend = 1'b1;
            end
            else if(dime) begin // Overpay: 15¢+10¢=25¢
                ns = S_IDLE;
                vend = 1'b1;
                change_5C = 1'b1;
            end
            else if(cancel) begin
                ns = S_CHANGE_15C_20C;
            end
        end

        // --- 25 Cent Track ---
        S_0C_25C: begin
            if(nickel) ns = S_5C_25C;
            else if(dime) ns = S_10C_25C;
            else if(cancel) ns = S_IDLE;
        end
        S_5C_25C: begin
            if(nickel) ns = S_10C_25C;
            else if(dime) ns = S_15C_25C;
            else if(cancel) begin
                ns = S_IDLE;
                change_5C = 1'b1;
            end
        end
        S_10C_25C: begin
            if(nickel) ns = S_15C_25C;
            else if(dime) ns = S_20C_25C;
            else if(cancel) begin
                ns = S_IDLE;
                change_10C = 1'b1;
            end
        end
        S_15C_25C: begin
            if(nickel) ns = S_20C_25C;
            else if(dime) begin // Exact: 15¢+10¢=25¢
                ns = S_IDLE;
                vend = 1'b1;
            end
            else if(cancel) begin
                ns = S_CHANGE_15C_25C;             
            end
        end
        S_20C_25C: begin
            if(nickel) begin // Exact: 20¢+5¢=25¢
                ns = S_IDLE;
                vend = 1'b1;
            end
            else if(dime) begin // Overpay: 20¢+10¢=30¢
                ns = S_IDLE;
                vend = 1'b1;
                change_5C = 1'b1;
            end
            else if(cancel) begin
                ns = S_CHANGE_20C_25C;
            end
        end

        // --- Multi-Cycle Change States ---
        S_CHANGE_15C_20C: begin // Multi-cycle: dispense 10¢ first, then 5¢
            if(!first_coin_dispensed) begin
                change_10C = 1'b1;
                next_coin_dispensed = 1'b1;
                ns = S_CHANGE_15C_20C;
            end
            else begin
                change_5C = 1'b1;
                next_coin_dispensed = 1'b0;
                ns = S_IDLE;
            end
        end         
        S_CHANGE_15C_25C: begin // Multi-cycle: dispense 10¢ first, then 5¢
            if(!first_coin_dispensed) begin
                change_10C = 1'b1;
                next_coin_dispensed = 1'b1;
                ns = S_CHANGE_15C_25C;
            end
            else begin
                change_5C = 1'b1;
                next_coin_dispensed = 1'b0;
                ns = S_IDLE;
            end
        end        
        S_CHANGE_20C_25C: begin // Multi-cycle: dispense 10¢ first, then 10¢
            if(!first_coin_dispensed) begin
                change_10C = 1'b1;
                next_coin_dispensed = 1'b1;
                ns = S_CHANGE_20C_25C;
            end
            else begin
                change_10C = 1'b1;
                next_coin_dispensed = 1'b0;
                ns = S_IDLE;
            end
        end

        default: begin
            ns = S_IDLE;
        end
    endcase
end
endmodule