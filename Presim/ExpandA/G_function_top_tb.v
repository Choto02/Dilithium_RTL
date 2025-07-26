`timescale 1ns / 1ps

module tb_G_function_top;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] rho;
    reg [7:0] i;
    reg [7:0] j;

    // Output
    wire [1599:0] keccak_output;

    // --------------------------------------------------------------------------------
    initial  begin
    $dumpfile("G_function_top_tb.vcd");
    $dumpvars(0, dut);
    end
    // --------------------------------------------------------------------------------

    // Instantiate the DUT
    G_function_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .rho(rho),
        .i(i),
        .j(j),
        .keccak_output(keccak_output),
        .done (done)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        start = 0;
        rho = 256'h0f2ebf0e8faf87ca5f1d160b4c3988a13781f607f05f3d5679584750deda1f1c;
        i = 8'd1;
        j = 8'd1;

        // Apply reset
        #20;
        rst_n = 1;

        // Wait some time and start the operation
        #10;
        start = 1;
        #10;
        start = 0;

        // Wait enough time for keccak to process (adjust this if needed)
        #2000;

        // Finish simulation
        $finish;
    end

endmodule
