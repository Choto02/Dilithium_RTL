module keccak_power (
	input clk, rst_n, start,
	input [1599:0] in_string,

    `ifdef KECCEK_ALL_OUT
        output [1599:0] out_theta, out_rho, out_pi, out_chi,
    `endif


	output [1599:0] out_string,
	output done
);

reg [4:0] cnt_keccak_rnd;
reg [3:0] state;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cnt_keccak_rnd <= 5'd31;
	end
	else begin
		if (state == 1) begin
			if (cnt_keccak_rnd == 5'd31)
				cnt_keccak_rnd <= 0;
			else if ((cnt_keccak_rnd >= 0) && (cnt_keccak_rnd <= 23))  begin
				cnt_keccak_rnd <= cnt_keccak_rnd + 1;
			end
		end
		else begin
			cnt_keccak_rnd <= cnt_keccak_rnd;
		end
	end

end


always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state <= 0;
	end
	else begin
		if (cnt_keccak_rnd == 5'd31) begin
			if (start)
				state <= 1;
		end
		else begin
			state <= state;
		end
	end

end



reg [1599:0] Sout;

wire [1599:0] in_keccak_permutation; 
assign in_keccak_permutation =  (cnt_keccak_rnd == 0) ? in_string : Sout;

wire [1599:0] out_keccak_permutation;

keccak_permutation u_keccak_permutation (
    .in_keccak_1600     (in_keccak_permutation),
    .cnt_keccak_rnd     (cnt_keccak_rnd),

    //
    `ifdef KECCEK_ALL_OUT
        .out_theta      (out_theta),
        .out_rho        (out_rho), 
        .out_pi         (out_pi), 
        .out_chi        (out_chi),  
    `endif
    //

    .out_keccak_1600    (out_keccak_permutation)
);


always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		Sout <= 0;
	end
	else begin
		if ((cnt_keccak_rnd >= 0) && (cnt_keccak_rnd <= 23)) begin
			Sout <= out_keccak_permutation;
		end
		else begin
			Sout <= Sout;
			
		end
	end

end
assign out_string = Sout;
assign done = (cnt_keccak_rnd == 23)? 1'b1: 1'b0;

endmodule
