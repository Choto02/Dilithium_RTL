module H_function_top (
    input clk,
    input rst_n,
    input start,
    input [511:0] rho,              
    input [1599:0] keccak_in,
    input rho_en,
    input [1:0] ml_dsa_level , // (1 is the lowest level and 3 is the highest)
    output [1599:0] keccak_output,
    output done  
);


    wire [1599:0] keccak_input, keccak_input_rho;

    assign keccak_input = rho_en ? keccak_input_rho : keccak_in;

    shake_256_keccak_input u_shake_256_keccak_input(
        .rho(rho),         
        .ml_dsa_level(ml_dsa_level),
        .keccak_input(keccak_input_rho)   
    );

	keccak_power u_keccak_power(
		    .clk         (clk), 
		    .rst_n       (rst_n), 
		    .start       (start),
			.in_string   (keccak_input),
			.out_string  (keccak_output),
            .done        (done)
	);

endmodule