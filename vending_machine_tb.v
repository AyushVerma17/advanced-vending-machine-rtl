// Testbench for Advanced Vending Machine Module
`timescale 1ns/1ps

module vending_machine_tb;
    // Testbench signals
    reg [1:0] item_number;
    reg nickel_in, dime_in, clock, reset;
    wire nickel_out, dispense;
    
    // Variables for tracking money
    integer total_inserted;
    integer change_expected;
    
    // Instantiate the vending machine module
    vending_machine uut (
        .item_number(item_number),
        .nickel_in(nickel_in),
        .dime_in(dime_in),
        .clock(clock),
        .reset(reset),
        .nickel_out(nickel_out),
        .dispense(dispense)
    );
    
    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 10ns clock period
    end
    
    // Monitoring and tracking
    always @(posedge clock) begin
        if (nickel_in) begin
            total_inserted = total_inserted + 5;
            $display("Time %t: Inserted nickel, total now: %0d cents", $time, total_inserted);
        end
        if (dime_in) begin
            total_inserted = total_inserted + 10;
            $display("Time %t: Inserted dime, total now: %0d cents", $time, total_inserted);
        end
        if (dispense) begin
            $display("Time %t: Item dispensed!", $time);
        end
        if (nickel_out) begin
            $display("Time %t: Nickel returned as change", $time);
        end
    end
    
    // Task to insert coins and test functionality
    task insert_money;
        input integer nickels;
        input integer dimes;
        integer i;
        begin
            // Insert nickels
            for (i = 0; i < nickels; i = i + 1) begin
                nickel_in = 1;
                #10 nickel_in = 0;
                #10; // Wait for a cycle
            end
            
            // Insert dimes
            for (i = 0; i < dimes; i = i + 1) begin
                dime_in = 1;
                #10 dime_in = 0;
                #10; // Wait for a cycle
            end
        end
    endtask
    
    // Testing procedure
    initial begin
        // Initialize waveform dump for visualization
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_tb);
        
        // Initialize signals
        reset = 1;
        nickel_in = 0;
        dime_in = 0;
        item_number = 2'b00;
        total_inserted = 0;
        
        // Reset the machine
        #20 reset = 0;
        #10;
        
        // =====================================================
        // Test Case 1: Item 1 (15¢) with exact change
        // =====================================================
        $display("\n===== Test Case 1: Item 1 (15¢) with exact change =====");
        item_number = 2'b00; // Select item 1
        total_inserted = 0;
        
        // Insert 3 nickels (15¢)
        insert_money(3, 0);
        
        // Check if item is dispensed
        #10;
        if (dispense && !nickel_out)
            $display("PASS: Item 1 dispensed with exact change");
        else
            $display("FAIL: Item 1 not dispensed properly");
        
        // Reset for next test
        #20 reset = 1;
        #20 reset = 0;
        #10;
        
        // =====================================================
        // Test Case 2: Item 1 (15¢) with extra change
        // =====================================================
        $display("\n===== Test Case 2: Item 1 (15¢) with extra change =====");
        item_number = 2'b00; // Select item 1
        total_inserted = 0;
        
        // Insert 2 dimes (20¢)
        insert_money(0, 2);
        
        // Check if item is dispensed and change given
        #10;
        if (dispense && nickel_out)
            $display("PASS: Item 1 dispensed with 5¢ change");
        else
            $display("FAIL: Item 1 not dispensed with change properly");
        
        // Reset for next test
        #20 reset = 1;
        #20 reset = 0;
        #10;
        
        // =====================================================
        // Test Case 3: Item 2 (20¢) with exact change
        // =====================================================
        $display("\n===== Test Case 3: Item 2 (20¢) with exact change =====");
        item_number = 2'b01; // Select item 2
        total_inserted = 0;
        
        // Insert 2 dimes (20¢)
        insert_money(0, 2);
        
        // Check if item is dispensed
        #10;
        if (dispense && !nickel_out)
            $display("PASS: Item 2 dispensed with exact change");
        else
            $display("FAIL: Item 2 not dispensed properly");
        
        // Reset for next test
        #20 reset = 1;
        #20 reset = 0;
        #10;
        
        // =====================================================
        // Test Case 4: Item 2 (20¢) with extra change
        // =====================================================
        $display("\n===== Test Case 4: Item 2 (20¢) with extra change =====");
        item_number = 2'b01; // Select item 2
        total_inserted = 0;
        
        // Insert 1 dime and 3 nickels (25¢)
        insert_money(3, 1);
        
        // Check if item is dispensed and change given
        #10;
        if (dispense && nickel_out)
            $display("PASS: Item 2 dispensed with 5¢ change");
        else
            $display("FAIL: Item 2 not dispensed with change properly");
        
        // Reset for next test
        #20 reset = 1;
        #20 reset = 0;
        #10;
        
        // =====================================================
        // Test Case 5: Item 3 (25¢) with exact change
        // =====================================================
        $display("\n===== Test Case 5: Item 3 (25¢) with exact change =====");
        item_number = 2'b10; // Select item 3
        total_inserted = 0;
        
        // Insert 1 dime and 3 nickels (25¢)
        insert_money(3, 1);
        
        // Check if item is dispensed
        #10;
        if (dispense && !nickel_out)
            $display("PASS: Item 3 dispensed with exact change");
        else
            $display("FAIL: Item 3 not dispensed properly");
        
        // Reset for next test
        #20 reset = 1;
        #20 reset = 0;
        #10;
        
        // =====================================================
        // Test Case 6: Item 3 (25¢) with extra change
        // =====================================================
        $display("\n===== Test Case 6: Item 3 (25¢) with extra change =====");
        item_number = 2'b10; // Select item 3
        total_inserted = 0;
        
        // Insert 3 dimes (30¢)
        insert_money(0, 3);
        
        // Check if item is dispensed and change given
        #10;
        if (dispense && nickel_out)
            $display("PASS: Item 3 dispensed with 5¢ change");
        else
            $display("FAIL: Item 3 not dispensed with change properly");
        
        // End simulation
        #20;
        $display("\nSimulation complete!");
        $finish;
    end
endmodule