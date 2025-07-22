module shake_256_keccak_input (
    input [511:0] rho,          
    input [1:0] ml_dsa_level,     
    output [1599:0] keccak_input

);

    wire [7:0] shake256_prefix;
    assign shake256_prefix = 8'b00011111; // 0x1F
    wire [7:0] shake256_suffix;
    assign shake256_suffix = 8'b10000000; // 0x80


    assign keccak_input = {rho[255:0], shake256_prefix, {816{1'b0}}, shake256_suffix, {512{1'b0}}}; //level 1 (rho 32 bytes)
    //assign keccak_input = {rho[383:0], shake256_prefix, {688{1'b0}}, shake256_suffix, {512{1'b0}}}; //level 2 (rho 48 bytes)
    //assign keccak_input = {rho, shake256_prefix, {560{1'b0}}, shake256_suffix, {512{1'b0}}}; //level 3 (rho 64 bytes)

endmodule
