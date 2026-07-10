`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 11:21:52
// Design Name: 
// Module Name: round_robin
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

`timescale 1ns/1ps

module round_robin #(
    parameter int WIDTH = 16
)(
    input  logic             clk,
    input  logic             rst_n,            // active-low synchronous reset
    input  logic [WIDTH-1:0] req,
    output logic [WIDTH-1:0] grant,
    output logic             grant_valid
);

    // --------------------------------------------------------
    // Internal elements (Section 3.1)
    // pointer: binary index 0..WIDTH-1
    // --------------------------------------------------------
    localparam int PTR_W = $clog2(WIDTH);

    logic [PTR_W-1:0]  pointer;               // binary pointer register
    logic [PTR_W-1:0]  next_pointer;
    logic [WIDTH-1:0]  req_rot;               // rotated request vector
    logic [WIDTH-1:0]  grant_rot;             // priority-encoded rotated grant
    logic [WIDTH-1:0]  next_grant;            // un-rotated grant (original order)
    logic              any_req;

    // --------------------------------------------------------
    // Step 1 - Rotate req so that pointer maps to position 0
    //   req_rot[i] = req[(i + pointer) % WIDTH]
    // --------------------------------------------------------
    always_comb begin : gen_rotate
        for (int i = 0; i < WIDTH; i++)
            req_rot[i] = req[(i + int'(pointer)) % WIDTH];
    end

    // --------------------------------------------------------
    // Step 2 - Priority-encode the rotated vector (first-one)
    //   grant_rot is one-hot on the lowest set bit of req_rot
    // --------------------------------------------------------
    logic found;
    always_comb begin : gen_priority
        grant_rot = '0;
        found = 1'b0;
        for (int i = 0; i < WIDTH; i++) begin
            if (req_rot[i] & ~found) begin
                grant_rot[i] = 1'b1;
                found        = 1'b1;
            end
        end
    end

    // --------------------------------------------------------
    // Step 3 - Un-rotate: map grant_rot back to original index
    //   next_grant[( i + pointer) % WIDTH] = grant_rot[i]
    // --------------------------------------------------------
    always_comb begin : gen_unrotate
        next_grant = '0;
        for (int i = 0; i < WIDTH; i++)
            next_grant[(i + int'(pointer)) % WIDTH] = grant_rot[i];
    end

    // --------------------------------------------------------
    // Combinational outputs
    // --------------------------------------------------------
    assign any_req     = |req;
    assign grant_valid = any_req;

    // --------------------------------------------------------
    // Pointer update: (granted_index + 1) mod WIDTH
    // Advance only on successful grant (Section 2.2)
    // --------------------------------------------------------
    always_comb begin : gen_next_ptr
        next_pointer = pointer;                       // hold by default
        if (any_req) begin
            for (int i = 0; i < WIDTH; i++) begin
                if (next_grant[i])
                    next_pointer = PTR_W'((i + 1) % WIDTH);
            end
        end
    end

    // --------------------------------------------------------
    // Sequential: synchronous reset (Section 2.1)
    // Only two registers: pointer and grant
    // --------------------------------------------------------
    always_ff @(posedge clk) begin : seq
        if (!rst_n) begin
            pointer <= '0;
            grant   <= '0;
        end else begin
            pointer <= next_pointer;
            grant   <= next_grant;
        end
    end

endmodule
