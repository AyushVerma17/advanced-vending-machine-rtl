`timescale 1ns/1ps

module vending_machine_mealy_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg nickel;
    reg dime; 
    reg cancel;
    reg [1:0] item_select;
    
    wire vend;
    wire change_5C;
    wire change_10C;
    
    // Instantiate the hybrid vending machine
    vending_machine_mealy uut (
        .clk(clk),
        .rst(rst),
        .nickel(nickel),
        .dime(dime),
        .cancel(cancel),
        .item_select(item_select),
        .vend(vend),
        .change_5C(change_5C),
        .change_10C(change_10C)
    );
    
    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Generate VCD file for waveform viewing
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, vending_machine_mealy_tb);
        
        // Initialize inputs
        rst = 0;
        nickel = 0;
        dime = 0;
        cancel = 0;
        item_select = 2'b00; // No selection initially
        
        // reset goes high after 2 clk cycles
        @(posedge clk);
        @(posedge clk);
        rst = 1;
        @(posedge clk);
        
        $display("\n=== Vending Machine Test Started ===");
        $display("Items: 15c (01), 20c (10), 25c (11)");
        
        //========== 15 CENT ITEM TESTS ==========
        $display("\n--- Testing 15 Cent Item ---");
        
        // Test 1: 15c item - exact amount (N+D)
        $display("\nTest 1: 15c Item - Nickel + Dime = Exact Amount");
        select_15c_item();
        insert_nickel();
        insert_dime();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 2: 15c item - exact amount (D+N)
        $display("\nTest 2: 15c Item - Dime + Nickel = Exact Amount");
        select_15c_item();
        insert_dime();
        insert_nickel();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();

        // Test 3: 15c item - exact amount (N+N+N)
        $display("\nTest 3: 15c Item - Nickel + Nickel + Nickel = Exact Amount");
        select_15c_item();
        insert_nickel();
        insert_nickel();
        insert_nickel();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 4: 15c item - overpayment (D+D = 20c, expect 5c change)
        $display("\nTest 4: 15c Item - Dime + Dime = 20c (expect 5c change)");
        select_15c_item();
        insert_dime();
        insert_dime();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        
        //========== 20 CENT ITEM TESTS ==========
        $display("\n--- Testing 20 Cent Item ---");
        
        // Test 5: 20c item - exact amount (D+D)
        $display("\nTest 5: 20c Item - Dime + Dime = Exact Amount");
        select_20c_item();
        insert_dime();
        insert_dime();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 6: 20c item - exact amount (D+N+N)
        $display("\nTest 6: 20c Item - Dime + 2 Nickels = Exact Amount");
        select_20c_item();
        insert_dime();
        insert_nickel();
        insert_nickel();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 7: 20c item - overpayment (D+N+D = 25c, expect 5c change)
        $display("\nTest 7: 20c Item - 2 Dimes + Nickel = 25c (expect 5c change)");
        select_20c_item();
        insert_dime();
        insert_nickel();
        insert_dime();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        //========== 25 CENT ITEM TESTS ==========
        $display("\n--- Testing 25 Cent Item ---");
        
        // Test 8: 25c item - exact amount (D+D+N)
        $display("\nTest 8: 25c Item - 2 Dimes + Nickel = Exact Amount");
        select_25c_item();
        insert_dime();
        insert_dime();
        insert_nickel();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 9: 25c item - exact amount (D+N+N+N)
        $display("\nTest 9: 25c Item - Dime + Nickel + Nickel + Nickel = Exact Amount");
        select_25c_item();
        insert_dime();
        insert_nickel();
        insert_nickel();
        insert_nickel();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 10: 25c item - overpayment (D+D+D = 30c, expect 5c change)
        $display("\nTest 10: 25c Item - Dime + Dime + Dime = 30c (expect 5c change)");
        select_25c_item();
        insert_dime();
        insert_dime();
        insert_dime();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        //========== CANCEL TESTS ==========
        $display("\n--- Testing Cancel Feature ---");
        
        // Test 11: Cancel after selecting item (no money)
        $display("\nTest 11: Select 20c Item then Cancel (no refund)");
        select_20c_item();
        press_cancel();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 12: Cancel after nickel (5c refund)
        $display("\nTest 12: Select 15c Item, Insert Nickel, then Cancel");
        select_15c_item();
        insert_nickel();
        press_cancel();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 13: Cancel after dime (10c refund)
        $display("\nTest 13: Select 25c Item, Insert Dime, then Cancel");
        select_25c_item();
        insert_dime();
        press_cancel();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 14: Cancel after D+N (15c refund - will be multi-cycle)
        $display("\nTest 14: Select 25c Item, Insert Dime + Nickel, then Cancel");
        select_25c_item();
        insert_dime();
        insert_nickel();
        press_cancel();
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk); // Extra cycles for multi-cycle change

        // Reset for next test
        apply_reset();
        
        // Test 15: Cancel after 2D (20c refund - will be multi-cycle)
        $display("\nTest 15: Select 25c Item, Insert 2 Dimes, then Cancel");
        select_25c_item();
        insert_dime();
        insert_dime();
        press_cancel();
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk); // Extra cycles for multi-cycle change

        // Reset for next test
        apply_reset();
        
        //========== EDGE CASE TESTS ==========
        $display("\n--- Testing Edge Cases ---");
        
        // Test 16: No item selection, try to insert money
        $display("\nTest 16: Insert coins without selecting item (should stay in IDLE)");
        insert_nickel();
        insert_dime();
        @(posedge clk);
        @(posedge clk);

        // Reset for next test
        apply_reset();
        
        // Test 17: Change item selection mid-transaction (should require cancel first)
        $display("\nTest 17: Select 15c, insert nickel, try to select 20c (should not change)");
        select_15c_item();
        insert_nickel();
        select_20c_item();
        @(posedge clk);
        insert_dime(); // Complete original 15c transaction
        @(posedge clk);
        @(posedge clk);
        
        $display("\n=== All Tests Completed ===");
        #50;
        $finish;
    end
    
    // Task to select 15c item
    task select_15c_item();
        begin
            $display(" <>Selecting 15 cent item...");
            @(posedge clk);
            item_select = 2'b01;
            @(posedge clk);
            item_select = 2'b00; // Clear selection signal
        end
    endtask
    
    // Task to select 20c item
    task select_20c_item();
        begin
            $display(" <>Selecting 20 cent item...");
            @(posedge clk);
            item_select = 2'b10;
            @(posedge clk);
            item_select = 2'b00; // Clear selection signal
        end
    endtask
    
    // Task to select 25c item
    task select_25c_item();
        begin
            $display(" <>Selecting 25 cent item...");
            @(posedge clk);
            item_select = 2'b11;
            @(posedge clk);
            item_select = 2'b00; // Clear selection signal
        end
    endtask
    
    // Task to insert nickel
    task insert_nickel();
        begin
            $display(" <>Inserting Nickel (5c)...");
            @(posedge clk);
            nickel = 1;
            @(posedge clk);
            nickel = 0;
        end
    endtask
    
    // Task to insert dime
    task insert_dime();
        begin
            $display(" <>Inserting Dime (10c)...");
            @(posedge clk);
            dime = 1;
            @(posedge clk);
            dime = 0;
        end
    endtask
    
    // Task to press cancel
    task press_cancel();
        begin
            $display(" <>Pressing Cancel...");
            @(posedge clk);
            cancel = 1;
            @(posedge clk);
            cancel = 0;
        end
    endtask
    
    // Task to apply reset
    task apply_reset();
        begin
            @(posedge clk);
            rst = 0;
            @(posedge clk);
            rst = 1;
            @(posedge clk);
        end
    endtask
    
    // Monitor outputs - simplified like original
    always @(posedge clk) begin
        $display("Time=%0t | State=%b | Item=%b | vend=%b change_5C=%b change_10C=%b", 
                 $time, uut.ps, uut.selected_item, vend, change_5C, change_10C);
        
        if (vend) begin
            if (change_5C)
                $display("  >>> Item dispensed with 5c change");
            else if (change_10C)
                $display("  >>> Item dispensed with 10c change");
            else
                $display("  >>> Item dispensed (exact amount)");
        end
        
        if (!vend && (change_5C || change_10C)) begin
            if (change_5C)
                $display("  >>> 5c returned (cancelled)");
            if (change_10C)
                $display("  >>> 10c returned (cancelled)");
        end
    end
    
endmodule