`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 18:29:48
// Design Name: 
// Module Name: fifomem
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


module fifomem #(parameter DATA_SIZE = 8,
                 parameter ADDR_SIZE = 4)
(
    input w_clk,r_clk,
    input w_en , r_en,
    input [DATA_SIZE-1:0] w_data,
    input [ADDR_SIZE-1:0] w_addr,
    input [ADDR_SIZE-1:0] r_addr,
    output reg [DATA_SIZE-1:0] r_data
    );
    
    reg [DATA_SIZE-1:0] MEM [0 : (1<<ADDR_SIZE)-1];
    always @(posedge w_clk)
        begin
            if(w_en)
                MEM[w_addr] <= w_data;
        end
    always @(posedge r_clk)
        begin
            if(r_en)
                r_data <= MEM[r_addr];
        end

endmodule
