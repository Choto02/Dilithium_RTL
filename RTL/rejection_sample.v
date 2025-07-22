module rejection_sample(
    input [7:0] i, 
    input [7:0] j_initial,
    input sign_int,
    //output signed [1:0] coeff_out,
    output [1:0] coeff_out,
    output j_valid
    );

    assign j_valid = (j_initial <= i) ? 1'b1 : 1'b0;
    assign coeff_out = 2'b1 - {sign_int, 1'b0};


endmodule