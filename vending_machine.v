// Module for the first item (15¢ price)
module Item_One(nickel_in, dime_in, clock, reset, nickel_out, dispense);
    input nickel_in, dime_in, clock, reset;
    output reg nickel_out, dispense;
    reg [4:0] current_state, next_state;

    localparam  S0  = 5'b00001,  // $0
                S5  = 5'b00010,  // $5
                S10 = 5'b00100,  // $10
                S15 = 5'b01000,  // $15 (dispense here)
                S20 = 5'b10000;  // $20 (dispense + change)

    always @(posedge clock or posedge reset) begin
        if (reset) current_state <= S0;
        else current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            S0: 
                if (nickel_in)      begin next_state = S5;  {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S10; {nickel_out, dispense} = 2'b00; end
                else                begin next_state = S0;  {nickel_out, dispense} = 2'b00; end
            
            S5: 
                if (nickel_in)      begin next_state = S10; {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S15; {nickel_out, dispense} = 2'b01; end  // Dispense at $15
                else                begin next_state = S5;  {nickel_out, dispense} = 2'b00; end
            
            S10:
                if (nickel_in)      begin next_state = S15; {nickel_out, dispense} = 2'b01; end  // Dispense at $15
                else if (dime_in)   begin next_state = S20; {nickel_out, dispense} = 2'b11; end  // Dispense + change at $20
                else                begin next_state = S10; {nickel_out, dispense} = 2'b00; end
            
            S15: 
                begin next_state = S0; {nickel_out, dispense} = 2'b01; end  // Maintain dispense signal
            
            S20: 
                begin next_state = S0; {nickel_out, dispense} = 2'b11; end  // Maintain dispense + change signals

            default: 
                begin next_state = S0; {nickel_out, dispense} = 2'b00; end
        endcase
    end
endmodule

// Module for the second item (20¢ price)
module Item_Two(nickel_in, dime_in, clock, reset, nickel_out, dispense);
    input nickel_in, dime_in, clock, reset;
    output reg nickel_out, dispense;
    reg [5:0] current_state, next_state;

    localparam  S0  = 6'b000001,  // $0
                S5  = 6'b000010,  // $5
                S10 = 6'b000100,  // $10
                S15 = 6'b001000,  // $15
                S20 = 6'b010000,  // $20 (dispense here)
                S25 = 6'b100000;  // $25 (dispense + change)

    always @(posedge clock or posedge reset) begin
        if (reset) current_state <= S0;
        else current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            S0: 
                if (nickel_in)      begin next_state = S5;  {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S10; {nickel_out, dispense} = 2'b00; end
                else                begin next_state = S0;  {nickel_out, dispense} = 2'b00; end
            
            S5: 
                if (nickel_in)      begin next_state = S10; {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S15; {nickel_out, dispense} = 2'b00; end
                else                begin next_state = S5;  {nickel_out, dispense} = 2'b00; end
            
            S10:
                if (nickel_in)      begin next_state = S15; {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S20; {nickel_out, dispense} = 2'b01; end  // Dispense at $20
                else                begin next_state = S10; {nickel_out, dispense} = 2'b00; end
            
            S15:
                if (nickel_in)      begin next_state = S20; {nickel_out, dispense} = 2'b01; end  // Dispense at $20
                else if (dime_in)   begin next_state = S25; {nickel_out, dispense} = 2'b11; end  // Dispense + change at $25
                else                begin next_state = S15; {nickel_out, dispense} = 2'b00; end
            
            S20: 
                begin next_state = S0; {nickel_out, dispense} = 2'b01; end  // Maintain dispense signal
            
            S25: 
                begin next_state = S0; {nickel_out, dispense} = 2'b11; end  // Maintain dispense + change signals

            default: 
                begin next_state = S0; {nickel_out, dispense} = 2'b00; end
        endcase
    end
endmodule

// Module for the third item (25¢ price)
module Item_Three(nickel_in, dime_in, clock, reset, nickel_out, dispense);
    input nickel_in, dime_in, clock, reset;
    output reg nickel_out, dispense;
    reg [6:0] current_state, next_state;

    localparam  S0   = 7'b0000001,  // $0
                S5   = 7'b0000010,  // $5
                S10  = 7'b0000100,  // $10
                S15  = 7'b0001000,  // $15
                S20  = 7'b0010000,  // $20
                S25  = 7'b0100000,  // $25 (dispense here)
                S30  = 7'b1000000;  // $30 (dispense + change)

    always @(posedge clock or posedge reset) begin
        if (reset) current_state <= S0;
        else current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            S0: 
                if (nickel_in)      begin next_state = S5;  {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S10; {nickel_out, dispense} = 2'b00; end
                else                begin next_state = S0;  {nickel_out, dispense} = 2'b00; end
            
            S5: 
                if (nickel_in)      begin next_state = S10; {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S15; {nickel_out, dispense} = 2'b00; end
                else                begin next_state = S5;  {nickel_out, dispense} = 2'b00; end
            
            S10:
                if (nickel_in)      begin next_state = S15; {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S20; {nickel_out, dispense} = 2'b00; end
                else                begin next_state = S10; {nickel_out, dispense} = 2'b00; end
            
            S15:
                if (nickel_in)      begin next_state = S20; {nickel_out, dispense} = 2'b00; end
                else if (dime_in)   begin next_state = S25; {nickel_out, dispense} = 2'b01; end  // Dispense at $25
                else                begin next_state = S15; {nickel_out, dispense} = 2'b00; end
            
            S20:
                if (nickel_in)      begin next_state = S25; {nickel_out, dispense} = 2'b01; end  // Dispense at $25
                else if (dime_in)   begin next_state = S30; {nickel_out, dispense} = 2'b11; end  // Dispense + change at $30
                else                begin next_state = S20; {nickel_out, dispense} = 2'b00; end
            
            S25: 
                begin next_state = S0; {nickel_out, dispense} = 2'b01; end  // Maintain dispense signal
            
            S30: 
                begin next_state = S0; {nickel_out, dispense} = 2'b11; end  // Maintain dispense + change signals

            default: 
                begin next_state = S0; {nickel_out, dispense} = 2'b00; end
        endcase
    end
endmodule

// Top-level module for three items
module vending_machine(
    input [1:0] item_number,  // 2-bit input for three items
    input nickel_in, dime_in, clock, reset,
    output reg nickel_out, dispense
);
    // Internal signals for item modules
    wire No1, No2, No3;
    wire D1, D2, D3;

    // Instantiate all three item modules
    Item_One IO(.nickel_in(nickel_in), .dime_in(dime_in), .clock(clock), .reset(reset), .nickel_out(No1), .dispense(D1));
    Item_Two ITW(.nickel_in(nickel_in), .dime_in(dime_in), .clock(clock), .reset(reset), .nickel_out(No2), .dispense(D2));
    Item_Three ITH(.nickel_in(nickel_in), .dime_in(dime_in), .clock(clock), .reset(reset), .nickel_out(No3), .dispense(D3));

    // Output selection logic
    always @(*) begin
        case (item_number)
            2'b00: begin nickel_out = No1; dispense = D1; end  // Item 1
            2'b01: begin nickel_out = No2; dispense = D2; end  // Item 2
            2'b10: begin nickel_out = No3; dispense = D3; end  // Item 3
            default: begin nickel_out = 0; dispense = 0; end   // Invalid selection
        endcase
    end
endmodule