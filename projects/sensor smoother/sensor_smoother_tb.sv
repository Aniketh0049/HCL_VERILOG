`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.05.2026 18:57:47
// Design Name: 
// Module Name: sensor_smoother_tb
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

module sensor_smoother_tb;

    localparam OUT_VALID = 4;          // ? local, visible to properties

    logic [7:0] sample_in, filt_out;
    logic       valid_in, valid_out, clk, rst_n;
    int         count = 0;

    sensor_smoother dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .sample_in (sample_in),
        .valid_in  (valid_in),
        .filt_out  (filt_out),
        .valid_out (valid_out)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        rst_n = 1;
        #10 rst_n = 0;
        #5  rst_n = 1;
        forever begin
            #120 rst_n = 0;
            #10  rst_n = 1;
        end
    end

    initial #2000 $finish;
    logic directed_test_running = 0;

initial begin
    @(posedge rst_n);
    repeat(2) @(posedge clk);

    directed_test_running = 1;
    @(posedge clk); #1;

    sample_in = 8'd10; valid_in = 1'b1; @(posedge clk); #1;
    sample_in = 8'd20;                  @(posedge clk); #1;
    sample_in = 8'd30;                  @(posedge clk); #1;
    sample_in = 8'd40;                  @(posedge clk); #1;
    // valid_out=1, filt_out=(10+20+30+40)>>2 = 25

    directed_test_running = 0;
end
    // ---------- Stimulus class ----------
    class random_stim;
        rand logic [7:0] a, b;
        rand logic [7:0] sample_in;
        rand bit         sel;
        rand bit k;
        function void valid();
          randcase
            3:k=1;
            1:k=1;
          endcase
        endfunction
        constraint c1 {
            (a < 50)  -> (b > 150);
            (a > 150) -> (b < 50);
        }
        constraint pick {
            sample_in inside {a, b};
            (sel == 1) -> (sample_in == a);
            (sel == 0) -> (sample_in == b);
        }
    endclass

    random_stim r1;
    initial r1 = new();


always @(posedge clk) begin
    if (!rst_n) begin
        count     <= 0;
        sample_in <= 0;
        valid_in  <= 0;
    end
    else if(!directed_test_running) begin
        if (!r1.randomize())
            $fatal(1, "randomize() failed");
        sample_in <= r1.sample_in;
        valid_in  <= r1.k;

        // FIX: was r1.k - must use valid_in (port) so TB count
        // matches exactly what the DUT latches each cycle
        if (valid_in && !valid_out)
            count <= count + 1;
    end
end

    // ---------- Properties ----------
 
    property p1;
        @(posedge clk) disable iff (!rst_n)
            (count == OUT_VALID) |=> (valid_out == 1);
    endproperty
    assert property (p1)
        else $error("FAIL p1: valid_out not asserted after %0d valid samples", OUT_VALID);

    property p2;
        @(posedge clk) disable iff (!rst_n)
            (count < OUT_VALID) |-> (valid_out == 1'b0);
    endproperty
    assert property (p2)
        else $error("FAIL p2: valid_out asserted too early (count=%0d)", count);   // ? fixed name

    property p3;
        @(posedge clk)
            (!rst_n) |->##2 (filt_out == 0);
    endproperty
    assert property (p3)
        else $error("FAIL p3: filt_out not zero after reset");

    property p4;
        logic [7:0] filt_captured;
        @(posedge clk) disable iff (!rst_n)
            (valid_out && !valid_in, filt_captured = filt_out) |=> (filt_out == filt_captured);
    endproperty
    assert property (p4)
        else $error("FAIL p4: filt_out changed without valid_in");

endmodule

