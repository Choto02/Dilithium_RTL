`timescale 1ns/1ps

module ExpandA_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg start_expandA;
    reg [255:0] rho;

    // Outputs
    wire done_expandA;

    // Instantiate the Unit Under Test (UUT)
    ExpandA_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .start_expandA(start_expandA),
        .rho(rho),
        .done_expandA(done_expandA)
    );


    // --------------------------------------------------------------------------------
    initial  begin
        $dumpfile("ExpandA.vcd");
        $dumpvars(0, uut);
    end
    // --------------------------------------------------------------------------------

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        start_expandA = 0;
        rho = 256'h0f2ebf0e8faf87ca5f1d160b4c3988a13781f607f05f3d5679584750deda1f1c;

        // Reset pulse
        #20;
        rst_n = 1;

        // Stimulus
        #10;
        start_expandA = 1;
        #10;
        start_expandA = 0;

        // Wait for operation to complete
        wait(done_expandA == 1);
        //uut.u_mem.print_memory();
        uut.u_mem.print_memory_to_file();
        $display("ExpandA complete");

        // Finish simulation
        #20;
        $finish;
    end


endmodule
