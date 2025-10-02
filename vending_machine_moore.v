//========================================================================
// File:         vending_machine_moore.v
// Author:       Ayush Verma
// Date:         30-September-2025
//
// Description:
// This module implements a Moore Finite State Machine (FSM) to control
// a vending machine. In Moore FSM, outputs depend only on current state.
// It follows the two-process style with a sequential block for state
// registers and a combinational block for next-state logic.
// This version uses separate "state tracks" for each item price.
//
// Design Rules / Specifications:
// 1. Item Prices: 15 cents, 20 cents, 25 cents
// 2. Accepted Coins: Nickel (5 cents) and Dime (10 cents)
// 3. Rejected Coins: Penny and Quarter are not supported
// 4. Change: The machine provides correct change for overpayment
// 5. Cancel: A transaction can be cancelled at any point to refund money
// 6. Moore Machine: Outputs depend only on current state
//========================================================================


module vending_machine_moore(
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
parameter S_IDLE = 5'b00000,
        //--15 Cent Item Track--
          S_0C_15C = 5'b00001,
          S_5C_15C = 5'b00010,
          S_10C_15C = 5'b00011,
          S_15C_15C = 5'b00100,            // OUTPUT STATE: Vend
          S_CHANGE_5C_15C = 5'b00101,      // OUTPUT STATE: Refund 5¢
          S_CHANGE_10C_15C = 5'b00110,     // OUTPUT STATE: Refund 10¢
          S_CHANGE_5C_VEND_15C = 5'b00111, // OUTPUT STATE: Vend + 5¢ change

        //--20 Cent Item Track--
          S_0C_20C = 5'b01000,
          S_5C_20C = 5'b01001,
          S_10C_20C = 5'b01010,
          S_15C_20C = 5'b01011,
          S_20C_20C = 5'b01100,            // OUTPUT STATE: Vend
          S_CHANGE_5C_20C = 5'b01101,      // OUTPUT STATE: Refund 5¢
          S_CHANGE_10C_20C = 5'b01110,     // OUTPUT STATE: Refund 10¢
          S_CHANGE_15C_20C = 5'b01111,     // MULTI-CYCLE: Refund 15¢ (10¢→5¢)
          S_CHANGE_5C_VEND_20C = 5'b10000, // OUTPUT STATE: Vend + 5¢ change
          
        //--25 Cent Item Track--
          S_0C_25C = 5'b10001,
          S_5C_25C = 5'b10010,
          S_10C_25C = 5'b10011,
          S_15C_25C = 5'b10100,
          S_20C_25C = 5'b10101,
          S_25C_25C = 5'b10110,            // OUTPUT STATE: Vend
          S_CHANGE_5C_25C = 5'b10111,      // OUTPUT STATE: Refund 5¢
          S_CHANGE_10C_25C = 5'b11000,     // OUTPUT STATE: Refund 10¢
          S_CHANGE_15C_25C = 5'b11001,     // MULTI-CYCLE: Refund 15¢ (10¢→5¢)
          S_CHANGE_20C_25C = 5'b11010,     // MULTI-CYCLE: Refund 20¢ (10¢→10¢)
          S_CHANGE_5C_VEND_25C = 5'b11011; // OUTPUT STATE: Vend + 5¢ change

parameter ITEM_15C = 2'b01,
          ITEM_20C = 2'b10,
          ITEM_25C = 2'b11;

reg [4:0] ps, ns; // Present state, Next state (5 bits for 28 states)

//===============================================================
// Sequential Logic - State Register
// Updates state on clock edge, asynchronous reset to IDLE
//===============================================================
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        ps <= S_IDLE;
    end
    else begin
        ps <= ns;
    end
end

//================================================================
// Combinational Logic - Next State and Output Decode
// Outputs depend only on present state (Moore characteristic)
//================================================================
always @(*) begin
    // Default assignments prevent latches
    ns = ps;
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

        // --- 15 Cent Item Track ---
        S_0C_15C: begin
            if(nickel) ns = S_5C_15C;
            else if(dime) ns = S_10C_15C;
            else if(cancel) ns = S_IDLE;
        end
        S_5C_15C: begin
            if(nickel) ns = S_10C_15C;
            else if(dime) ns = S_15C_15C; // Exact: 5¢+10¢=15¢
            else if(cancel) ns = S_CHANGE_5C_15C;
        end
        S_10C_15C: begin
            if(nickel) ns = S_15C_15C; // Exact: 10¢+5¢=15¢
            else if(dime) ns = S_CHANGE_5C_VEND_15C; // Overpay: 10¢+10¢=20¢
            else if(cancel) ns = S_CHANGE_10C_15C;
        end
        S_15C_15C: begin
            ns = S_IDLE;
            vend = 1'b1;
        end
        S_CHANGE_5C_15C: begin
            ns = S_IDLE;
            change_5C = 1'b1;
        end
        S_CHANGE_10C_15C: begin
            ns = S_IDLE;
            change_10C = 1'b1;
        end
        S_CHANGE_5C_VEND_15C: begin
            ns = S_IDLE;
            vend = 1'b1;
            change_5C = 1'b1;
        end

        // --- 20 Cent Item Track ---
        S_0C_20C: begin
            if(nickel) ns = S_5C_20C;
            else if(dime) ns = S_10C_20C;
            else if(cancel) ns = S_IDLE;
        end
        S_5C_20C: begin
            if(nickel) ns = S_10C_20C;
            else if(dime) ns = S_15C_20C;
            else if(cancel) ns = S_CHANGE_5C_20C;
        end
        S_10C_20C: begin
            if(nickel) ns = S_15C_20C;
            else if(dime) ns = S_20C_20C; // Exact: 10¢+10¢=20¢
            else if(cancel) ns = S_CHANGE_10C_20C;
        end
        S_15C_20C: begin
            if(nickel) ns = S_20C_20C; // Exact: 15¢+5¢=20¢
            else if(dime) ns = S_CHANGE_5C_VEND_20C; // Overpay: 15¢+10¢=25¢
            else if(cancel) ns = S_CHANGE_15C_20C;
        end
        S_20C_20C: begin
            ns = S_IDLE;
            vend = 1'b1;
        end
        S_CHANGE_5C_20C: begin
            ns = S_IDLE;
            change_5C = 1'b1;
        end
        S_CHANGE_10C_20C: begin
            ns = S_IDLE;
            change_10C = 1'b1;
        end
        S_CHANGE_15C_20C: begin // Multi-cycle: dispense 10¢ now, 5¢ next
            ns = S_CHANGE_5C_20C;
            change_10C = 1'b1;
        end
        S_CHANGE_5C_VEND_20C: begin
            ns = S_IDLE;
            vend = 1'b1;
            change_5C = 1'b1;
        end

        // --- 25 Cent Item Track ---
        S_0C_25C: begin
            if(nickel) ns = S_5C_25C;
            else if(dime) ns = S_10C_25C;
            else if(cancel) ns = S_IDLE;
        end
        S_5C_25C: begin
            if(nickel) ns = S_10C_25C;
            else if(dime) ns = S_15C_25C;
            else if(cancel) ns = S_CHANGE_5C_25C;
        end
        S_10C_25C: begin
            if(nickel) ns = S_15C_25C;
            else if(dime) ns = S_20C_25C;
            else if(cancel) ns = S_CHANGE_10C_25C;
        end
        S_15C_25C: begin
            if(nickel) ns = S_20C_25C;
            else if(dime) ns = S_25C_25C; // Exact: 15¢+10¢=25¢
            else if(cancel) ns = S_CHANGE_15C_25C;
        end
        S_20C_25C: begin
            if(nickel) ns = S_25C_25C; // Exact: 20¢+5¢=25¢
            else if(dime) ns = S_CHANGE_5C_VEND_25C; // Overpay: 20¢+10¢=30¢
            else if(cancel) ns = S_CHANGE_20C_25C;
        end
        S_25C_25C: begin
            ns = S_IDLE;
            vend = 1'b1;
        end
        S_CHANGE_5C_25C: begin
            ns = S_IDLE;
            change_5C = 1'b1;
        end
        S_CHANGE_10C_25C: begin
            ns = S_IDLE;
            change_10C = 1'b1;
        end
        S_CHANGE_15C_25C: begin // Multi-cycle: dispense 10¢ now, 5¢ next
            ns = S_CHANGE_5C_25C;
            change_10C = 1'b1;
        end
        S_CHANGE_20C_25C: begin // Multi-cycle: dispense 10¢ now, 10¢ next
            ns = S_CHANGE_10C_25C;
            change_10C = 1'b1;
        end
        S_CHANGE_5C_VEND_25C: begin
            ns = S_IDLE;
            vend = 1'b1;
            change_5C = 1'b1;
        end

        default: begin
            ns = S_IDLE;
        end
    endcase
end

endmodule