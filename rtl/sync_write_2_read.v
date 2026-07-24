`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 19:13:27
// Design Name: 
// Module Name: sync_write_2_read
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


module sync_write_2_read #(
                 parameter ADDR_SIZE = 4)
(
    input r_clk , r_reset_n,
    input [ADDR_SIZE:0] w_ptr,
    output reg [ADDR_SIZE:0] sync_w_ptr

    );
    
     reg [ADDR_SIZE:0] r1_ptr;
    
    always@(posedge r_clk,negedge r_reset_n)
        begin
            if(!r_reset_n)
                begin
                r1_ptr <=0;
                sync_w_ptr <=0;
                end
            else
               begin
                r1_ptr <= w_ptr;
                sync_w_ptr <= r1_ptr;
                end
        end


endmodule
