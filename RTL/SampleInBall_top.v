module SampleInBall_top (
    input clk,
    input rst_n,
    input start_sample_in_ball,
    input [511:0] rho,  
    input [1:0] ml_dsa_level,     
    output done_sample_in_ball         
);



    wire start_keccak, done_keccak, WEB, z_valid, keccak_rst_n, sign_int, j_valid, rho_en;

    wire [15:0]   A;    
    wire [23:0]   D, z_out;
    wire [1599:0] keccak_in, keccak_output;
    wire [7:0] i, j_initial;
    wire [1:0] coeff_out;


    SampleInBall_FSM u_SampleInBall_FSM (
        .clk(clk),
        .rst_n(rst_n),
        .start_sample_in_ball(start_sample_in_ball),      
        .done_sample_in_ball(done_sample_in_ball),   
        .start_keccak(start_keccak),
        .done_keccak(done_keccak),
        .keccak_in(keccak_in),
        .keccak_output(keccak_output),
        .keccak_rst_n(keccak_rst_n),
        .rho_en(rho_en),
        .A(A),
        .D(D),
        .WEB(WEB),
        .z_out(z_out),
        .z_valid(z_valid),
        .i(i), 
        .j_initial(j_initial),
        .sign_int(sign_int),
        .coeff_out(coeff_out),
        .j_valid(j_valid),
        .ml_dsa_level(ml_dsa_level)
);



    H_function_top u_H_function_top(
        .clk(clk),
        .rst_n(keccak_rst_n),
        .start(start_keccak),
        .rho(rho),                
        .keccak_in(keccak_in),
        .rho_en(rho_en),   //if enabled means rho is input, else the keccak_in is input
        .ml_dsa_level(ml_dsa_level),
        .keccak_output(keccak_output),
        .done(done_keccak)  
    );

    rejection_sample u_rejection_sample(
        .i(i), 
        .j_initial(j_initial),
        .sign_int(sign_int),
        .coeff_out(coeff_out),
        .j_valid(j_valid)
    );

                
    mem u_mem(
        .A(A),       // Address (16 bits)
        .D(D),       // Data input
        .BWEB(24'h0),    // Bit-wise Write Enable (active low)
        .WEB(WEB),     // Write Enable (active low)
        .CEB(1'b0),     // Chip Enable (active low)
        .CLK(clk),     
        .RTSEL(2'b00),   
        .WTSEL(3'b000),   
        .Q(Q)    // Data output
);

endmodule