`timescale 1ns / 1ps


module tb_SampleInBall_top;

    // Inputs
    reg clk;
    reg rst_n;
    reg start_sample_in_ball;
    reg [511:0] rho;
    reg [1:0] ml_dsa_level;

    // Output
    wire done_sample_in_ball;

    // Instantiate DUT
    SampleInBall_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .start_sample_in_ball(start_sample_in_ball),
        .rho(rho),
        .ml_dsa_level(ml_dsa_level),
        .done_sample_in_ball(done_sample_in_ball)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    initial begin
        // Waveform dump
        $dumpfile("SampleInBall_top_tb.vcd");
        $dumpvars(0, uut);
    end

    initial begin
        // Initialize inputs
        rst_n = 0;
        start_sample_in_ball = 0;
        rho = 512'h0f2ebf0e8faf87ca5f1d160b4c3988a13781f607f05f3d5679584750deda1f1c;
        ml_dsa_level = 2'b01;  // Example level

        // Apply reset
        #20 rst_n = 1;

        // Start sampling
        #10 start_sample_in_ball = 1;
        #10 start_sample_in_ball = 0;

        // Wait for done signal
        wait(done_sample_in_ball == 1);
        $display("SampleInBall operation completed.");
        uut.u_mem.print_memory_to_file();

        // Optional delay for waveform viewing
        #50;
        $finish;
    end

endmodule
