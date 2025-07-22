module G_function_top (
    input clk,
    input rst_n,
    input start,
    input [255:0] rho,       
    input [7:0]   i,          
    input [7:0]   j,          
    input [1599:0] keccak_in, //used to bypass rho for subsequent operations
    input rho_en,             //used to enable rho input and disable keccak_in
    output [1599:0] keccak_output,
    output done  
);


    wire [1599:0] keccak_input, keccak_input_rho;

    assign keccak_input = rho_en ? keccak_input_rho : keccak_in;

    shake_128_keccak_input u_shake_128_keccak_input(
        .rho(rho),        
        .i(i),          
        .j(j),         
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