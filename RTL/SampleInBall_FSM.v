module SampleInBall_FSM (
    input clk,
    input rst_n,
    input start_sample_in_ball,
    input done_keccak,
    input [1:0] ml_dsa_level,  
    input [1599:0] keccak_output,
    input [1:0] coeff_out,
    input j_valid,

    output reg done_sample_in_ball,
    output reg start_keccak,
    output reg [1599:0] keccak_in, 
    output reg rho_en,
    output reg [15:0] A,
    output reg [23:0] D,
    output reg WEB,
    output reg [23:0] z_out,
    output reg z_valid,
    output reg keccak_rst_n,
    output reg [7:0] i, 
    output reg [7:0] j_initial,
    output reg sign_int
);



    localparam IDLE  = 3'b000;
    localparam RST_ARY = 3'b001; //reset c array
    localparam LOAD  = 3'b010;  //load next inputs of keccak
    localparam PROC  = 3'b011;  //SampleInBall processing and load received data to memory 
    localparam DONE  = 3'b100;

    //this part is for simulation only
    integer idx;
    genvar gi;

    reg [2:0] current_state, next_state;
    reg [15:0] address_counter;
    reg done_sample_in_ball_round, done_array_rst, j_valid_buffer;
    reg [7:0] round_count, in_round_count, rst_ary_count; //counts how many coefficients have been collected
    reg [1599:0] last_keccak_result;
    reg [63:0] h_reg;
    reg [5:0] tau;
    reg [1:0] c_array [0:255];  // 256 individual 2-bit regs
    reg [8:0] coeff_count;
    reg [1:0] coeff_out_buffer;


    // ----------- State Register (Sequential) -----------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // ----------- Next State Logic (Combinational) -----------
    always @(*) begin
        case (current_state)
            IDLE:  next_state = start_sample_in_ball ? RST_ARY : IDLE;
            RST_ARY: next_state = done_array_rst ? LOAD : RST_ARY;
            LOAD:  next_state = done_keccak ? PROC : LOAD;
            PROC:  next_state = done_sample_in_ball ? DONE : done_sample_in_ball_round ? 
                                LOAD : PROC;
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end



   
    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        address_counter <= 0;
        done_sample_in_ball_round <= 0;
        done_sample_in_ball <= 0;
        start_keccak <= 0;
        keccak_in <= 0;
        rho_en <= 0;
        A <= 0;
        i<= 0;
        j_initial <= 0;
        sign_int <= 0;
        D <= 0;
        WEB <= 0;
        z_out <= 0;
        z_valid <= 0;
        keccak_rst_n <= 1;
        round_count <= 0;  
        in_round_count <= 0;
        coeff_count <= 0;
        h_reg <= 0;
        done_array_rst <= 0;
        rst_ary_count <= 0;
        coeff_out_buffer <= 0;
        j_valid_buffer <=0;

        if(ml_dsa_level==1) begin
            tau <= 39;
        end
        else if (ml_dsa_level==2) begin
            tau <= 49;
        end
        else begin
            tau <= 60;
        end


    end else begin
        case (current_state)
            IDLE: begin
                // address_count<= 0; //not yet introduced
                i<= 0;
                j_initial <= 0;
                sign_int <= 0;
                done_sample_in_ball_round <= 0;
                done_sample_in_ball <= 0;
                start_keccak <= 0;
                keccak_in <= 0;
                rho_en <= 0;
                A <= 0;
                D <= 0;
                WEB <= 0;
                z_out <= 0;
                z_valid <= 0;
                keccak_rst_n <= 0;
                round_count <= 0;  
                coeff_count <= 0;
                in_round_count <= 0;
                h_reg <= 0;
                i <= 256 - tau;
            end

            RST_ARY: begin
                //set 256 entries of array to 0
                c_array[(rst_ary_count * 8)] <= 2'd0;
                c_array[(rst_ary_count * 8) + 1] <= 2'd0;
                c_array[(rst_ary_count * 8) + 2] <= 2'd0;
                c_array[(rst_ary_count * 8) + 3] <= 2'd0;
                c_array[(rst_ary_count * 8) + 4] <= 2'd0;
                c_array[(rst_ary_count * 8) + 5] <= 2'd0;
                c_array[(rst_ary_count * 8) + 6] <= 2'd0;
                c_array[(rst_ary_count * 8) + 7] <= 2'd0;
                
                rst_ary_count <= rst_ary_count + 1;

                if(rst_ary_count == 32) begin
                    done_array_rst <= 1;
                end
               

            end

            LOAD: begin
                start_keccak <= 1;

                if(round_count == 0) begin
                    rho_en <= 1;
                end
                else begin
                    rho_en <= 0;
                end

                keccak_rst_n <= 1;
                in_round_count <= 0;
                done_sample_in_ball_round <= 0;
                z_valid <= 0;
                
            end

            PROC: begin
                keccak_rst_n <= 0;
                start_keccak <= 0;
                rho_en <= 0;
                in_round_count <= in_round_count + 1;
                coeff_out_buffer <= coeff_out;
                j_valid_buffer <= j_valid;


                if (round_count == 0) begin
                    // for initial round's 1st iteration, the h reg is initialized
                    //h_reg <= keccak_output[1599:1536];  //8 bytes squeezed for h
                    h_reg <= {keccak_output[1543:1536], keccak_output[1551:1544], keccak_output[1559:1552], 
                                keccak_output[1567:1560], keccak_output[1575:1568], keccak_output[1583:1576], 
                                keccak_output[1591:1584], keccak_output[1599:1592]};
                    last_keccak_result <= {keccak_output[1535:0], 64'h0}; //shifted for next squeeze
                    keccak_in <= keccak_output; //output saved for next keccak input
                    //sign_int <= h_reg[0]; //sign of polynomial taken from 
                    round_count <= round_count + 1; //ready for next round
                end
                else if (in_round_count < 129) begin
                    // if j is invalid then it is rejected and and new j squeezed from keccak
                    j_initial <= {
                        last_keccak_result[1599: 1592]
                    };
                    last_keccak_result <= {last_keccak_result[1591:0],8'h0};
                    sign_int <= h_reg[0];
                end
                else if (in_round_count == 8'd129) begin
                    done_sample_in_ball_round <= 1;
                    round_count <= round_count + 1;
                end

                if (in_round_count == 0) begin
                    keccak_in <= keccak_output;
                end

                // if (in_round_count > 1 && in_round_count < 129 && j_valid && i_counter < 256) begin
                //     // if j is valid then it is accepted and stored
                //     c_array[i] <= c_array[j_initial];
                //     c_array[j_initial] <= coeff_out_buffer;
                //     h_reg <= {1'b0, h_reg[63:1]};
                //     i_counter <= i_counter + 1;
                // end 

                // if (in_round_count > 0 && in_round_count < 129 && j_valid_buffer && i_counter < 257) begin
                //     //if j is valid then it is accepted and stored
                //     //c_array[i] <= c_array[j_initial];
                //     //c_array[j_initial] <= coeff_out_buffer;
                //     // h_reg <= {1'b0, h_reg[63:1]};
                //     // i_counter <= i_counter + 1;

                // end 

                if (in_round_count > 1 && in_round_count < 129 && j_valid_buffer && i < 255) begin
                    // if j is valid then it is accepted and stored
                    c_array[i] <= c_array[j_initial];
                    c_array[j_initial] <= coeff_out_buffer;
                    h_reg <= {1'b0, h_reg[63:1]};
                    i <= i + 1;
                end

                if (i == 255) begin
                    done_sample_in_ball <= 1;
                end
                        
            end


            DONE: begin
                $display("Contents of c_array:");
                for (idx = 0; idx < 256; idx = idx + 1) begin
                    $display("c_array[%0d] = %0d", idx, c_array[idx]);
                end
                done_sample_in_ball <= 0;

            end

            default: begin
                A <= 0;
                D <= 0;
                WEB <= 1;
                address_counter <= 0;
            end
        endcase
    end
end


endmodule