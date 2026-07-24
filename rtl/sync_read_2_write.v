`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 19:13:43
// Design Name: 
// Module Name: sync_read_2_write
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


module sync_read_2_write#(
                 parameter ADDR_SIZE = 4)(
        input w_clk,w_reset_n,
        input [ADDR_SIZE:0] r_ptr,
        output reg [ADDR_SIZE:0] sync_r_ptr
    );
    
    reg [ADDR_SIZE:0] w1_ptr;
    
    always@(posedge w_clk,negedge w_reset_n)
        begin
            if(!w_reset_n)
                begin
                w1_ptr <=0;
                sync_r_ptr <=0;
                end
            else
               begin
                w1_ptr <= r_ptr;
                sync_r_ptr <= w1_ptr;
                end
        end

endmodule
