module shake_128_keccak_input (
    input [255:0] rho,        
    input [7:0]   i,          
    input [7:0]   j,          
    output [1599:0] keccak_input   
);


    wire [7:0] shake_prefix;
    assign shake_prefix = 8'b00011111; // 0x1F
    wire [7:0] shake_suffix;
    assign shake_suffix = 8'b10000000; // 0x80

    //assign keccak_input = {rho, j, i, 8'h1F, 1056'b0, 8'h80, 256'b0};
    //assign keccak_input = {rho, i, j, 5'b11111, 1066'b0, 1'b1, 256'b0};

    assign keccak_input = {rho, j, i, shake_prefix, {1056{1'b0}}, shake_suffix, {256{1'b0}}};



endmodule
