module DRed (
    input [45:0] in,
    output signed [25:0] A, A_minus_q, A_minus_2q, A_plus_q,
    output reg signed [22:0] out
);

wire [2:0] a4;
wire [9:0] a3, a2, a1;
wire [12:0] a0;

assign {a4, a3, a2, a1, a0} = in;

// A = (-a4) * 2^20 + (a0 - (a2+a3+a4)) + (a1+a2+a3+a4) * 2^13 - (a3+a4) * 2^10

wire [11+13:0] t1;
assign t1 = ((a1 + a2 + a3 + a4) <<< 13);
wire [10+10:0] t2;
assign t2 = ((a3 + a4) <<< 10);
wire signed [14-1:0] t3;
assign t3 = (a0-a2-a3-a4);
wire [22:0] t4;
assign t4 = (a4 <<< 20);

wire signed [11+13+1:0] signed_t1; // 26 bits
assign signed_t1 = { 1'b0, t1 };
wire signed [10+10+1:0] signed_t2; // 22 bits
assign signed_t2 = { 1'b0, t2 };
wire signed [22+1:0] signed_t4; // 24 bits
assign signed_t4 = { 1'b0, t4 };

assign A = signed_t1 - signed_t2 + t3 - signed_t4;
// assign A = ((a1 + a2 + a3 + a4) <<< 13) - ((a3 + a4) <<< 10) + (a0-a2-a3-a4) - (a4 <<< 20);
// assign t_sum = t1 + t2 + t3 + t4; 

assign A_plus_q = A + 23'd8380417;

assign A_minus_q = A - 23'd8380417;

assign A_minus_2q = A_minus_q - 23'd8380417;

always @(*) begin
    if (A < 0) out = A_plus_q[22:0];
    else if (A < 23'd8380417) out = A[22:0];
    else if (A_minus_q < 23'd8380417) out = A_minus_q[22:0];
    else if (A_minus_2q < 23'd8380417) out = A_minus_2q[22:0];
    else out = A[22:0];
end
endmodule




//FOR SIGNED NUMBERS

// module DRed (
//     input [45:0] in,  //Changed to unsigned
//     output signed [25:0] A, A_minus_q, A_minus_2q, A_plus_q,
//     output reg [22:0] out
// );

// wire signed [2:0] a4_signed; //Abdullah changed to signed
// wire [9:0] a3, a2, a1;
// wire [12:0] a0;
// wire signed [10:0] a3_signed, a2_signed, a1_signed;
// wire signed [13:0] a0_signed;

// assign {a4_signed, a3, a2, a1, a0} = in;

// assign a3_signed = { 1'b0, a3 };
// assign a2_signed = { 1'b0, a2 };
// assign a1_signed = { 1'b0, a1 };
// assign a0_signed = { 1'b0, a0 };

// wire signed [1+11+13:0] t1;
// assign t1 = ((a1_signed + a2_signed + a3_signed + a4_signed) <<< 13); //Abdullah changed to signed

// wire signed [1+10+10:0] t2;
// assign t2 = ((a3_signed + a4_signed) <<< 10); //Abdullah changed to signed

// wire signed [1+14-1:0] t3;
// assign t3 = (a0_signed-a2_signed-a3_signed-a4_signed);

// wire signed [1+22:0] t4;   //Abdullah changed to signed
// assign t4 = (a4_signed <<< 20);

// assign A = t1 - t2 + t3 - t4;

// assign A_plus_q = A + 23'd8380417;

// assign A_minus_q = A - 23'd8380417;

// assign A_minus_2q = A_minus_q - 23'd8380417;

// always @(*) begin
//     if (A < 0) out = A_plus_q[22:0];
//     else if (A < 23'd8380417) out = A[22:0];
//     else if (A_minus_q < 23'd8380417) out = A_minus_q[22:0];
//     else if (A_minus_2q < 23'd8380417) out = A_minus_2q[22:0];
//     else out = A[22:0];
// end
// endmodule

