//========================================================================
// File:         vending_machine_hybrid.v
// Author:       Ayush Verma
// Date:         22-September-2025
//
// Description:
// This module implements a Mealy Finite State Machine (FSM) to control
// a simple vending machine. It follows the two-process style with a
// sequential block for state registers and a combinational block for
// next-state and output logic.
//
// Design Rules / Specifications:
// 1. Item Price: 15 cents.
// 2. Accepted Coins: Nickel (5 cents) and Dime (10 cents).
// 3. Rejected Coins: Penny and Quarter are not supported.
// 4. Change: The machine provides correct change for overpayment.
// 5. Cancel: A transaction can be cancelled at any point to refund money.
//========================================================================

module vending_machine_mealy(
  input wire clk,
  input wire rst,           // Active-low asynchronous reset
  input wire nickel,
  input wire dime,
  input wire cancel,
  input wire [1:0] item_select, // 2'b01: 15c, 2'b10: 20c, 2'b11: 25c

  output reg vend,
  output reg change_5C,
  output reg change_10C
);

    // State definitions - Only 2 extra states for complex cases
    parameter S_IDLE       = 3'b000,
              S_0C         = 3'b001,
              S_5C         = 3'b010,
              S_10C        = 3'b011,
              S_15C        = 3'b100,
              S_20C        = 3'b101,
              S_CHANGE_15C = 3'b110,  // Multi-cycle: dispense 10c then 5c
              S_CHANGE_20C = 3'b111;  // Multi-cycle: dispense 10c then 10c

    // Item definitions  
    parameter ITEM_NONE = 2'b00,
              ITEM_15C  = 2'b01,
              ITEM_20C  = 2'b10,
              ITEM_25C  = 2'b11;

    // State registers
    reg [2:0] ps, ns;
    reg [1:0] selected_item, next_selected_item;
    reg first_coin_dispensed; // Track if we dispensed first coin of multi-coin change

    //===============================================================
    // Sequential Block
    //===============================================================
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            ps <= S_IDLE;
            selected_item <= ITEM_NONE;
            first_coin_dispensed <= 1'b0;
        end 
        else begin
            ps <= ns;
            selected_item <= next_selected_item;
            if (ps == S_CHANGE_15C || ps == S_CHANGE_20C) begin
                first_coin_dispensed <= 1'b1;
            end 
            else begin
                first_coin_dispensed <= 1'b0;
            end
        end
    end

    //================================================================
    // Combinational Block - Immediate outputs for simple cases
    //================================================================
    always @(*) begin
        // Default assignments
        ns = ps;
        next_selected_item = selected_item;
        vend = 1'b0;
        change_5C = 1'b0;
        change_10C = 1'b0;

        case(ps)
        S_IDLE: begin
            // Item selection
            if (item_select == ITEM_15C) begin
                ns = S_0C;
                next_selected_item = ITEM_15C;
            end 
            else if (item_select == ITEM_20C) begin
                ns = S_0C;
                next_selected_item = ITEM_20C;
            end 
            else if (item_select == ITEM_25C) begin
                ns = S_0C;
                next_selected_item = ITEM_25C;
            end
        end

        S_0C: begin
            if (cancel) begin
                ns = S_IDLE;
                next_selected_item = ITEM_NONE;
            end 
            else if (nickel) begin
                ns = S_5C;
            end 
            else if (dime) begin
                ns = S_10C;
            end
        end

        S_5C: begin
            if (cancel) begin
                // Simple case - immediate return like original
                ns = S_IDLE;
                next_selected_item = ITEM_NONE;
                change_5C = 1'b1;
            end 
            else if (nickel) begin
                ns = S_10C;
            end 
            else if (dime) begin
                if (selected_item == ITEM_15C) begin
                    // Exact payment - immediate like original
                    ns = S_IDLE;
                    next_selected_item = ITEM_NONE;
                    vend = 1'b1;
                end 
                else begin
                    ns = S_15C;
                end
            end
        end

        S_10C: begin
            if (cancel) begin
            // Simple case - immediate return like original
            ns = S_IDLE;
            next_selected_item = ITEM_NONE;
            change_10C = 1'b1;
            end 
            else if (nickel) begin
            if (selected_item == ITEM_15C) begin
                // Exact payment - immediate
                ns = S_IDLE;
                next_selected_item = ITEM_NONE;
                vend = 1'b1;
            end 
            else begin
                ns = S_15C;
            end
            end 
            else if (dime) begin
            if (selected_item == ITEM_15C) begin
                // Overpaid by 5c - immediate like original
                ns = S_IDLE;
                next_selected_item = ITEM_NONE;
                vend = 1'b1;
                change_5C = 1'b1;
            end 
            else if (selected_item == ITEM_20C) begin
                // Exact payment - immediate
                ns = S_IDLE;
                next_selected_item = ITEM_NONE;
                vend = 1'b1;
            end 
            else begin
                ns = S_20C;
            end
            end
        end

        S_15C: begin
            if (cancel) begin
                // Complex case - needs multi-cycle sequence
                ns = S_CHANGE_15C;
                next_selected_item = ITEM_NONE;
            end 
            else if (nickel) begin
                if (selected_item == ITEM_20C) begin
                    // Exact payment
                    ns = S_IDLE;
                    next_selected_item = ITEM_NONE;
                    vend = 1'b1;
                end 
                else begin
                    ns = S_20C;
                end
            end 
            else if (dime) begin
                if (selected_item == ITEM_20C) begin
                    // Overpaid by 5c - immediate
                    ns = S_IDLE;
                    next_selected_item = ITEM_NONE;
                    vend = 1'b1;
                    change_5C = 1'b1;
                end 
                else begin
                    // 25c item - exact payment
                    ns = S_IDLE;
                    next_selected_item = ITEM_NONE;
                    vend = 1'b1;
                end
            end
        end

        S_20C: begin
            if (cancel) begin
                // Complex case - needs multi-cycle sequence
                ns = S_CHANGE_20C;
                next_selected_item = ITEM_NONE;
            end 
            else if (nickel) begin
                // 25c item - exact payment
                ns = S_IDLE;
                next_selected_item = ITEM_NONE;
                vend = 1'b1;
            end 
            else if (dime) begin
                // 25c item - overpaid by 5c, immediate
                ns = S_IDLE;
                next_selected_item = ITEM_NONE;
                vend = 1'b1;
                change_5C = 1'b1;
            end
        end

        // Multi-cycle change states - only for complex cases
        S_CHANGE_15C: begin
            if (!first_coin_dispensed) begin
                // First cycle: dispense 10c
                change_10C = 1'b1;
                ns = S_CHANGE_15C; // Stay in same state
            end 
            else begin
                // Second cycle: dispense 5c and finish
                change_5C = 1'b1;
                ns = S_IDLE;
            end
        end

        S_CHANGE_20C: begin
            if (!first_coin_dispensed) begin
                // First cycle: dispense first 10c
                change_10C = 1'b1;
                ns = S_CHANGE_20C; // Stay in same state
            end 
            else begin
                // Second cycle: dispense second 10c and finish
                change_10C = 1'b1;
                ns = S_IDLE;
            end
        end

        default: begin
            ns = S_IDLE;
            next_selected_item = ITEM_NONE;
        end
        endcase
    end

endmodule