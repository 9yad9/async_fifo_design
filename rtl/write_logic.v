`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 18:41:53
// Design Name: 
// Module Name: write_logic
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


module write_logic#(parameter DATA_SIZE = 8,
                 parameter ADDR_SIZE = 4)
(
    input w_clk, w_inc ,w_reset_n,
    input [ADDR_SIZE :0] sync_r_ptr,
    output [ADDR_SIZE -1:0] w_addr,
    output reg [ADDR_SIZE:0] w_ptr,
    output reg w_full

    );
        reg [ADDR_SIZE:0] w_bin;
        reg [ADDR_SIZE:0] w_bnext;
        reg [ADDR_SIZE:0] w_gnext;
        reg w_msbnext;
        reg w_addrmsb;
        integer i;
        
        always @*
        begin
            for (i=0; i<=ADDR_SIZE; i=i+1)
            begin
            w_bin[i] = ^(w_ptr >> i);
            end
            if(!w_full)
                begin
                w_bnext = w_bin + (w_inc & !w_full);
                end 
            else
                begin
                w_bnext = w_bin;
                end
            w_gnext = (w_bnext >> 1) ^ w_bnext;
            w_msbnext = w_gnext[ADDR_SIZE] ^ w_gnext[ADDR_SIZE-1];
            
        end
        
        always@(posedge w_clk , negedge w_reset_n)
        begin
            if(!w_reset_n)
                begin
                w_ptr <= 0;
                w_addrmsb <= 0 ;
                end 
            else 
                begin 
                w_ptr <= w_gnext;
                w_addrmsb <= w_msbnext;
                end
        end
        
        assign w_addr = {w_addrmsb , w_ptr[ADDR_SIZE-2:0]};
        
    wire w_2ndmsb  = w_gnext[ADDR_SIZE] ^ w_gnext[ADDR_SIZE-1];
    wire r_2ndmsb = sync_r_ptr[ADDR_SIZE] ^ sync_r_ptr[ADDR_SIZE-1];

    always @(posedge w_clk or negedge w_reset_n) begin
        if (!w_reset_n)
         w_full <= 0;
        else        
         w_full <= ( (w_gnext[ADDR_SIZE]     != sync_r_ptr[ADDR_SIZE]    ) &&
                                (w_2ndmsb             == r_2ndmsb           ) &&
                                (w_gnext[ADDR_SIZE-2:0] == sync_r_ptr[ADDR_SIZE-2:0]) );
    end
       
    
    
endmodule
