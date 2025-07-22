module RejNTTPoly_top (
    input clk,
    input rst_n,
    input start_rej,
    input [255:0] rho,       
    input [7:0]   i,          
    input [7:0]   j, 
    output done_rej,
    output [23:0] z_out,
    output z_valid
);

    wire [8*3*56-1:0] b0b1b2_all; // 1344 bits input (56 groups of 3 bytes)
    wire [23:0] b0b1b2, z;
    wire [1599:0] keccak_output, keccak_in; 
    wire done, start, keccak_rst_n; 

    G_function_top u_G_function_top(
        .clk(clk),
        .rst_n(keccak_rst_n),
        .start(start),
        .rho(rho),       
        .i(i),          
        .j(j),          
        .keccak_in(keccak_in),
        .rho_en(rho_en),   //if enabled means rho is input, else the keccak_in is input
        .keccak_output(keccak_output),
        .done(done)  
    );

    CoeffFromThreeBytes u_CoeffFromThreeBytes (
                .b0b1b2(b0b1b2),  // Take 24 bits (3 bytes) per instance
                .z(z)             // Assign 24-bit output per instance
            );

    RejNTTPolyFSM u_RejNTTPolyFSM(
        .clk(clk),
        .rst_n(rst_n),
        .start_keccak(start),              
        .done_keccak(done),
        .start_rej(start_rej),
        .done_rej(done_rej),
        .z(z),
        .keccak_output(keccak_output),  //it recieves the output from keccak
        .keccak_in(keccak_in),          //it sends new input to keccak
        .rho_en(rho_en),   //if enabled means rho is input, else the keccak_in is input
        .keccak_rst_n(keccak_rst_n),
        .b0b1b2(b0b1b2),
        .z_out(z_out),
        .z_valid(z_valid)
    );

endmodule
