`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.05.2026 18:56:52
// Design Name: 
// Module Name: sensor_smoother
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

module sensor_smoother(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] sample_in,
    input  logic       valid_in,
    output logic [7:0] filt_out,
    output logic       valid_out
);
    localparam OUT_VALID = 4;

    logic [7:0] r1, r2, r3, r4;
    logic [2:0] count;
    logic [9:0] accumulator;
    logic       k;
    logic [8:0] sum1, sum2;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            r1 <= 0; r2 <= 0; r3 <= 0; r4 <= 0;
        end
        else if (valid_in) begin
            r4 <= r3;
            r3 <= r2;
            r2 <= r1;
            r1 <= sample_in;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            count     <= 0;
            k         <= 1'b0;
            valid_out <= 1'b0;       // ? ADDED reset
        end
        else if (valid_in) begin
            count <= count + 1;
            if (count == OUT_VALID && !k) begin
                valid_out <= 1'b1;
                k         <= 1'b1;
            end
       
end
end
    always_comb begin
        sum1        = {1'b0, r1} + {1'b0, r2};
        sum2        = {1'b0, r3} + {1'b0, r4};
        accumulator = {1'b0, sum1} + {1'b0, sum2};
    end

    assign filt_out = accumulator[9:2];

endmodule

