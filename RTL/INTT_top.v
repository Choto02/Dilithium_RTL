module INTT_top (
    input clk,
    input rst_n,
    input start_NTT,
    input load_mem,
    input [15:0] A_load,
    input [23:0] D_load,
    input        WEB_load,

    output done_NTT,
    output [23:0] Q0,
    output [23:0] Q1
);


    wire [15:0]     A0_NTT, A1_NTT, A0, A1;    
    wire [23:0]     D0_NTT, D1_NTT, D0, D1;
    wire            WEB0_NTT, WEB1_NTT, WEB0, WEB1;

    assign A0 = load_mem ? A_load : A0_NTT;
    assign D0 = load_mem ? D_load : D0_NTT;
    assign WEB0 = load_mem ? WEB_load : WEB0_NTT;

    wire [45:0] red_in_0;
    wire [45:0] red_in_1;
    wire [45:0] red_in_2;


    wire [22:0] red_out_0;
    wire [22:0] red_out_1;
    wire [22:0] red_out_2;


    INTT_FSM u_INTT_FSM (
        .clk             (clk),
        .rst_n           (rst_n),
        .start_NTT       (start_NTT),

        .reduction_output0(red_out_0),
        .reduction_output1(red_out_1),
        .reduction_output2(red_out_2),


        .done_NTT        (done_NTT),
        .Q0               (Q0),
        .A0               (A0_NTT),
        .D0               (D0_NTT),
        .WEB0             (WEB0_NTT),
        .Q1               (Q1),
        .A1               (A1_NTT),
        .D1               (D1_NTT),
        .WEB1             (WEB1_NTT),
        .reduction_input0 (red_in_0),
        .reduction_input1 (red_in_1),
        .reduction_input2 (red_in_2)
    );

    DRed u_DRed0 (
        .in         (red_in_0),
        .A          (A_0),
        .A_minus_q  (A_minus_q_0),
        .A_minus_2q (A_minus_2q_0),
        .A_plus_q   (A_plus_q_0),
        .out        (red_out_0)
    );

    DRed u_DRed1 (
        .in         (red_in_1),
        .A          (A_1),
        .A_minus_q  (A_minus_q_1),
        .A_minus_2q (A_minus_2q_1),
        .A_plus_q   (A_plus_q_1),
        .out        (red_out_1)
    );

    DRed u_DRed2 (
        .in         (red_in_2),
        .A          (A_2),
        .A_minus_q  (A_minus_q_2),
        .A_minus_2q (A_minus_2q_2),
        .A_plus_q   (A_plus_q_2),
        .out        (red_out_2)
    );


    mem u_mem(
        .A0(A0),       // Address (16 bits)
        .D0(D0),       // Data input
        .BWEB0(24'h0),    // Bit-wise Write Enable (active low)
        .WEB0(WEB0),     // Write Enable (active low)
        .CEB0(1'b0),     // Chip Enable (active low)
        .CLK(clk),     
        .RTSEL(2'b00),   
        .WTSEL(3'b000),   
        .Q0(Q0),
        .A1(A1_NTT),       // Address (16 bits)
        .D1(D1_NTT),       // Data input
        .BWEB1(24'h0),    // Bit-wise Write Enable (active low)
        .WEB1(WEB0_NTT),     // Write Enable (active low)
        .CEB1(1'b0),     // Chip Enable (active low)
        .Q1(Q1)         // Data output
    );



endmodule 