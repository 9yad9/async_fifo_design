`timescale 1ns / 1ps

module tb_async_fifo;

    // Parameters matching fifotop
    parameter DATA_SIZE = 8;
    parameter ADDR_SIZE = 4;
    parameter FIFO_DEPTH = 1 << ADDR_SIZE;

    // Write Domain Signals
    reg                   w_clk;
    reg                   w_reset_n;
    reg                   w_inc;
    reg  [DATA_SIZE-1:0]  w_data;
    wire                  w_full;

    // Read Domain Signals
    reg                   r_clk;
    reg                   r_reset_n;
    reg                   user_r_inc;
    wire [DATA_SIZE-1:0]  user_r_data;
    wire                  user_empty;

    // Golden Model Memory Buffer for Data Verification
    reg  [DATA_SIZE-1:0]  expected_mem [0:511];
    integer w_ptr_check;
    integer r_ptr_check;

    // Instantiate Unit Under Test (UUT)
    fifotop #(
        .DATA_SIZE(DATA_SIZE),
        .ADDR_SIZE(ADDR_SIZE)
    ) uut (
        .w_clk       (w_clk),
        .w_reset_n   (w_reset_n),
        .w_inc       (w_inc),
        .w_data      (w_data),
        .w_full      (w_full),
        .r_clk       (r_clk),
        .r_reset_n   (r_reset_n),
        .user_r_inc  (user_r_inc),
        .user_r_data (user_r_data),
        .user_empty  (user_empty)
    );

    // -------------------------------------------------------------
    // 1. Independent Asynchronous Clocks (CDC Setup)
    // -------------------------------------------------------------
    // Write Clock = 100 MHz (10ns period)
    initial w_clk = 0;
    always #5 w_clk = ~w_clk;

    // Read Clock = 37.03 MHz (27ns period - non-integer ratio)
    initial r_clk = 0;
    always #13.5 r_clk = ~r_clk;

    // -------------------------------------------------------------
    // 2. Automated Self-Checking Logic
    // -------------------------------------------------------------
    // Record written data into golden model
    always @(posedge w_clk) begin
        if (w_reset_n && w_inc && !w_full) begin
            expected_mem[w_ptr_check] <= w_data;
            w_ptr_check <= w_ptr_check + 1;
        end
    end

    // Direct check on valid read operation
    always @(posedge r_clk) begin
        if (r_reset_n && user_r_inc && !user_empty) begin
            #1; // Small delta delay to let user_r_data settle
            if (user_r_data !== expected_mem[r_ptr_check]) begin
                $display("[ERROR] Data Mismatch! Read: 0x%h | Expected: 0x%h at time %0t", 
                         user_r_data, expected_mem[r_ptr_check], $time);
            end else begin
                $display("[PASS] Read: 0x%h matched Expected Data", user_r_data);
            end
            r_ptr_check <= r_ptr_check + 1;
        end
    end

    // -------------------------------------------------------------
    // 3. Main Stimulus Process
    // -------------------------------------------------------------
    initial begin
        // Initialize Signals
        w_reset_n   = 0;
        r_reset_n   = 0;
        w_inc       = 0;
        user_r_inc  = 0;
        w_data      = 0;
        w_ptr_check = 0;
        r_ptr_check = 0;

        // Apply Reset
        #40;
        w_reset_n   = 1;
        r_reset_n   = 1;
        #20;

        $display("\n==================================================");
        $display("   STARTING PURE VERILOG ASYNC FIFO TESTBENCH     ");
        $display("==================================================");

        // --- TASK 1: Fill FIFO until FULL ---
        $display("\n[TASK 1] Writing until FIFO is FULL...");
        while (!w_full) begin
            @(posedge w_clk);
            w_inc  <= 1;
            w_data <= ($random % 255) + 1;
        end
        @(posedge w_clk);
        w_inc <= 0;
        $display("[SUCCESS] FIFO FULL flag (w_full = %b) asserted!", w_full);

        #100;

        // --- TASK 2: Read FIFO until EMPTY (Guarded for CDC Sync) ---
        $display("\n[TASK 2] Reading until FIFO is EMPTY...");
        while (!user_empty) begin
            @(posedge r_clk);
            if (!user_empty) begin
                user_r_inc <= 1;
            end else begin
                user_r_inc <= 0;
            end
        end
        @(posedge r_clk);
        user_r_inc <= 0;
        
        $display("[SUCCESS] FIFO EMPTY flag (user_empty = %b) asserted!", user_empty);

        #100;

        // --- TASK 3: Concurrent Read/Write Stress Test ---
        $display("\n[TASK 3] Starting Concurrent Read/Write Stress Test...");
        
        // Write burst
        repeat (12) begin
            @(posedge w_clk);
            if (!w_full) begin
                w_inc  <= 1;
                w_data <= ($random % 255) + 1;
            end
        end
        @(posedge w_clk);
        w_inc <= 0;

        // Read burst
        repeat (12) begin
            @(posedge r_clk);
            if (!user_empty) begin
                user_r_inc <= 1;
            end
        end
        @(posedge r_clk);
        user_r_inc <= 0;

        // Drain remaining entries
        #100;
        while (!user_empty) begin
            @(posedge r_clk);
            if (!user_empty) begin
                user_r_inc <= 1;
            end
        end
        @(posedge r_clk);
        user_r_inc <= 0;

        #200;
        $display("\n==================================================");
        $display("   TESTBENCH COMPLETED SUCCESSFULLY!              ");
        $display("==================================================\n");
        $finish;
    end

endmodule