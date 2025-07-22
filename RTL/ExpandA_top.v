module ExpandA_top (
    input clk,
    input rst_n,
    input start_expandA,
    input [255:0] rho,       
    output done_expandA         
);



    wire [7:0] i, j;
    wire start_rej, done_rej, WEB, z_valid;

    wire [15:0]   A;    
    wire [23:0]   D, z_out;


    ExpandA_FSM u_ExpandA_FSM (
        .clk(clk),
        .rst_n(rst_n),
        .start_expandA(start_expandA),      
        .done_expandA(done_expandA),
        .i(i),          
        .j(j),     
        .start_rej(start_rej),
        .done_rej(done_rej),
        .A(A),
        .D(D),
        .WEB(WEB),
        .z_out(z_out),
        .z_valid(z_valid)
);

    RejNTTPoly_top u_RejNTTPoly_top(
        .clk(clk),
        .rst_n(rst_n),
        .start_rej(start_rej),
        .rho(rho),       
        .i(i),          
        .j(j),          
        .done_rej(done_rej),
        .z_out(z_out),
        .z_valid(z_valid)
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