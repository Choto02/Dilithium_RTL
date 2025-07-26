`timescale 1ns / 1ps

module NTT_tb;

    // Inputs to NTT_top
    reg clk;
    reg rst_n;
    reg start_NTT;
    reg [23:0] input_chunk;
    reg [15:0] A_load;
    reg [23:0] D_load;
    reg        WEB_load;
    reg        load_mem;


    // Outputs from NTT_top
    wire done_NTT;
    wire [23:0] Q0;
    wire [23:0] Q1;

    // Instantiate NTT_top
    NTT_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_NTT(start_NTT),
        .done_NTT(done_NTT),
        .load_mem(load_mem),
        .A_load(A_load),
        .D_load(D_load),
        .WEB_load(WEB_load)
    );

    // Clock generation
    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("NTT_top_tb.vcd");
        $dumpvars(0, dut);
    end

    initial begin

        // Initialize
        WEB_load = 1;
        load_mem = 0;
        clk = 0;
        rst_n = 0;
        start_NTT = 0;

        #20;
        rst_n = 1;
        #10;


        load_mem = 1;
        WEB_load = 0;
        for (i = 0; i < 256; i = i + 1) begin
            A_load = 16'h000000 + i;
            D_load = 24'h000000 + i;
            #10;
        end
        WEB_load = 1;
        load_mem = 0;
        // dut.u_mem.print_memory_to_file();
        $display("LOAD complete");

        // Start NTT
        start_NTT = 1;

        #10;
        start_NTT = 0;
        #1000000;

        if (done_NTT == 1) begin
            $display("NTT operation complete.");
        end

        dut.u_mem.print_memory_to_file();

        #100;
        $finish;
    end

endmodule
