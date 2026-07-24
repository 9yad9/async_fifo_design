`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 22:02:48
// Design Name: 
// Module Name: bram_design
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


module bram_design(
 input clka,    // input wire clka
  input ena,      // input wire ena
  input wea,      // input wire [0 : 0] wea
  input [3:0] addra,  // input wire [3 : 0] addra
  input [7:0] dina,    // input wire [7 : 0] dina
  output [7:0] douta
    );
    
    blk_mem_gen_0 u_blk_mem_gen_0 (
  .clka(clka),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [3 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .douta(douta)  // output wire [7 : 0] douta
);

endmodule
