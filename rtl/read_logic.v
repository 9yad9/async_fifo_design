`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 19:26:58
// Design Name: 
// Module Name: read_logic
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


module read_logic #(
    parameter DATA_SIZE = 8,
    parameter ADDR_SIZE = 4
) (
    input r_clk, r_reset_n,
    
    
    input user_r_inc,                   
    output [DATA_SIZE-1:0] user_r_data, 
    output user_empty,                  
    
   
    input [ADDR_SIZE:0] sync_w_ptr,     
    output reg [ADDR_SIZE:0] r_ptr,     
    
   
    input [DATA_SIZE-1:0] bram_r_data,  
    output [ADDR_SIZE-1:0] bram_r_addr, 
    output bram_r_en                    
);

  
    reg [ADDR_SIZE:0] r_bin;
    reg [ADDR_SIZE:0] r_bnext;
    reg [ADDR_SIZE:0] r_gnext;
    reg r_msbnext;
    reg r_addrmsb;
    reg internal_empty;
    integer i;

   
    reg [DATA_SIZE-1:0] prefetch_data_reg;
    reg prefetch_valid_reg;


    assign user_r_data = prefetch_data_reg;
    assign user_empty  = ~prefetch_valid_reg;


    assign bram_r_en = !internal_empty && (!prefetch_valid_reg || user_r_inc);


    always @* begin
        
        for (i=0; i<=ADDR_SIZE; i=i+1) begin
            r_bin[i] = ^(r_ptr >> i);
        end

        
        if (bram_r_en) begin
            r_bnext = r_bin + 1'b1;
        end else begin
            r_bnext = r_bin;
        end

        
        r_gnext = (r_bnext >> 1) ^ r_bnext;

       
        r_msbnext = r_gnext[ADDR_SIZE] ^ r_gnext[ADDR_SIZE-1];
    end

    always @(posedge r_clk or negedge r_reset_n) begin
        if (!r_reset_n) begin
            r_ptr     <= 0;
            r_addrmsb <= 0;
        end else begin
            r_ptr     <= r_gnext;
            r_addrmsb <= r_msbnext;
        end
    end

   
    assign bram_r_addr = {r_addrmsb, r_ptr[ADDR_SIZE-2:0]};


    always @(posedge r_clk or negedge r_reset_n) begin
        if (!r_reset_n)
            internal_empty <= 1'b1;
        else
            
            internal_empty <= (r_gnext == sync_w_ptr);
    end


    always @(posedge r_clk or negedge r_reset_n) begin
        if (!r_reset_n) begin
            prefetch_valid_reg <= 1'b0;
            prefetch_data_reg  <= 0;
        end else begin
            if (bram_r_en) begin
               
                prefetch_valid_reg <= 1'b1;
                prefetch_data_reg  <= bram_r_data;
            end else if (user_r_inc) begin
            
                prefetch_valid_reg <= 1'b0;
            end
        end
    end

endmodule
