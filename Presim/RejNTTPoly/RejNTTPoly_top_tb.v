`timescale 1ns / 1ps

module tb_RejNTTPoly_top;

    // Inputs
    reg clk;
    reg rst_n;
    reg start_rej;
    reg [255:0] rho;
    reg [7:0] i;
    reg [7:0] j;

    // Outputs
    wire done_rej;

    // Instantiate the DUT
    RejNTTPoly_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_rej(start_rej),
        .rho(rho),
        .i(i),
        .j(j),
        .done_rej(done_rej)
    );

    // --------------------------------------------------------------------------------
    initial  begin
    $dumpfile("RejNTTPoly_top.vcd");
    $dumpvars(0, dut);
    end
    // --------------------------------------------------------------------------------

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    initial begin

        // Initialize
        rst_n = 0;
        start_rej = 0;
        rho = 256'h0f2ebf0e8faf87ca5f1d160b4c3988a13781f607f05f3d5679584750deda1f1c;
        i = 8'd3;
        j = 8'd1;

        #20;
        rst_n = 1;

        #10;
        start_rej = 1;
        #10;
        start_rej = 0;

        // Wait for done_rej signal
        wait (done_rej);

        // Wait a little after done
        #50;

        // $display("done_rej triggered. z_all = %h", z_all);
        $finish;
    end

endmodule
