`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025 12:13:50 PM
// Design Name: 
// Module Name: gray
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


module gray(B,G);
input [3:0]B;
output [3:0]G;
assign G[3]=B[3];
assign G[2]=B[2];
assign G[1]=B[1];
assign G[0]=B[0];
endmodule
