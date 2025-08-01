`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2025 03:04:05 PM
// Design Name: 
// Module Name: pulsetracer
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


module pulsetracer(clk,noise, y);
  input  clk,noise;
  output reg y;
  reg u,v,w;
  always@( posedge clk) begin
     u<=noise;
     v<=u;
     w<=v;
     y<=v&~w;
     end
     
  
endmodule
