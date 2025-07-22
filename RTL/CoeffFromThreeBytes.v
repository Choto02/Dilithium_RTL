module CoeffFromThreeBytes (
    input [23:0] b0b1b2,        
    output [23:0] z   
);

    wire [7:0] b0, b1, b2prime_ori, b2prime_new;
    wire [24:0] zprime;

    assign b0 = b0b1b2[23:16];
    assign b1 = b0b1b2[15:8];
    assign b2prime_ori = b0b1b2[7:0];


    //method from c code
    assign zprime = b0b1b2 & 24'h7FFFFF;

    assign z = (zprime < 24'd8380417) ? zprime : 24'd8380417; //if q is obtained, means the value is rejected

endmodule
