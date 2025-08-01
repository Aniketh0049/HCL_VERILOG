`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2025 03:33:07 PM
// Design Name: 
// Module Name: bitbalancer
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


module bitbalancer(in,out);
   input [0:7]in;
   output reg [0:7]out;
   integer i;
   always@(*) begin
     out=0;
     for(i=0;i<8;i=i+1)begin
        out=out+in[i];
        end
     end
        
        
endmodule
