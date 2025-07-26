`timescale 1ns / 1ps

module H_function_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [511:0] rho;
    reg [1599:0] keccak_in;
    reg rho_en;
    reg [1:0] ml_dsa_level;

    // Outputs
    wire [1599:0] keccak_output;
    wire done;

    // Waveform
    initial begin
        $dumpfile("H_function_top.vcd");
        $dumpvars(0, uut);
    end

    // Instantiate DUT
    H_function_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .rho(rho),
        .keccak_in(keccak_in),
        .rho_en(rho_en),
        .ml_dsa_level(ml_dsa_level),
        .keccak_output(keccak_output),
        .done(done)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin

        // Initialize signals
        rst_n = 0;
        start = 0;
        rho = 512'h0f2ebf0e8faf87ca5f1d160b4c3988a13781f607f05f3d5679584750deda1f1c;
        keccak_in = 1600'h0;
        rho_en = 1;
        ml_dsa_level = 2'b01;  // Example value

        // Apply reset
        #20 rst_n = 1;

        // Start operation with rho_en = 1 (using rho as input)
        #10 start = 1;
        #10 start = 0;

        // Wait for done signal
        wait(done == 1);
        
        #50 
        $display("keccak_output = %h\n", keccak_output); //1st 1088 bits are usable
        $finish;
    end

endmodule
