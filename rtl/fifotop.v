`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 21:02:54
// Design Name: 
// Module Name: fifotop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifotop #(
    parameter DATA_SIZE = 8,
    parameter ADDR_SIZE = 4
) (

    input w_clk,
    input w_reset_n,
    input w_inc,
    input [DATA_SIZE-1:0] w_data,
    output w_full,
    input r_clk,
    input r_reset_n,
    input user_r_inc,
    output [DATA_SIZE-1:0] user_r_data,
    output user_empty
);


    wire [ADDR_SIZE:0] w_ptr;
    wire [ADDR_SIZE:0] r_ptr;
    wire [ADDR_SIZE:0] sync_w_ptr;
    wire [ADDR_SIZE:0] sync_r_ptr;

 
    wire [ADDR_SIZE-1:0] w_addr;
    wire [ADDR_SIZE-1:0] bram_r_addr;
    wire [DATA_SIZE-1:0] bram_r_data;
    wire                 bram_r_en;
    
    
    wire w_en = w_inc & ~w_full;


    fifomem #(
        .DATA_SIZE(DATA_SIZE),
        .ADDR_SIZE(ADDR_SIZE)
    ) mem_inst (
        .w_clk(w_clk),
        .r_clk(r_clk),
        .w_en(w_en),
        .r_en(bram_r_en),
        .w_data(w_data),
        .w_addr(w_addr),
        .r_addr(bram_r_addr),
        .r_data(bram_r_data)
    );

    
    write_logic #(
        .DATA_SIZE(DATA_SIZE),
        .ADDR_SIZE(ADDR_SIZE)
    ) w_logic_inst (
        .w_clk(w_clk),
        .w_reset_n(w_reset_n),
        .w_inc(w_inc),
        .sync_r_ptr(sync_r_ptr),
        .w_addr(w_addr),
        .w_ptr(w_ptr),
        .w_full(w_full)
    );

    
    read_logic #(
        .DATA_SIZE(DATA_SIZE),
        .ADDR_SIZE(ADDR_SIZE)
    ) r_logic_inst (
        .r_clk(r_clk),
        .r_reset_n(r_reset_n),
        .user_r_inc(user_r_inc),
        .user_r_data(user_r_data),
        .user_empty(user_empty),
        .sync_w_ptr(sync_w_ptr),
        .r_ptr(r_ptr),
        .bram_r_data(bram_r_data),
        .bram_r_addr(bram_r_addr),
        .bram_r_en(bram_r_en)
    );

    
    sync_write_2_read #(
        .ADDR_SIZE(ADDR_SIZE)
    ) sync_w2r_inst (
        .r_clk(r_clk),
        .r_reset_n(r_reset_n),
        .w_ptr(w_ptr),
        .sync_w_ptr(sync_w_ptr)
    );

    
    sync_read_2_write #(
        .ADDR_SIZE(ADDR_SIZE)
    ) sync_r2w_inst (
        .w_clk(w_clk),
        .w_reset_n(w_reset_n),
        .r_ptr(r_ptr),
        .sync_r_ptr(sync_r_ptr)
    );

endmodule