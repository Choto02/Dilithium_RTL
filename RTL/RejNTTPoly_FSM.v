module RejNTTPolyFSM (
    input clk,
    input rst_n,
    input done_keccak,
    input start_rej,
    input [23:0] z,
    input [1599:0] keccak_output,

    output reg [1599:0] keccak_in,
    output reg start_keccak,
    output reg rho_en,
    output reg done_rej,
    output reg keccak_rst_n,   
    output reg [23:0] b0b1b2,
    output reg [23:0] z_out,
    output reg z_valid

);


    localparam IDLE  = 3'b000;
    localparam LOAD  = 3'b001;  //load keccak
    localparam PROC  = 3'b010;  //keccak processing
    localparam SAMP  = 3'b011;   //sampling (goes back to keccak processing when done)
    localparam DONE  = 3'b100;

    reg [23:0] z_array [0:255];  // 256 individual 24-bit regs
    reg [5:0] z_round_counter;
    reg [8:0] z_counter;
    reg [1599:0] last_keccak_result;
    reg sample_round_done, sample_done;


    always @(z_round_counter) begin
        if (z_round_counter > 1 && z_round_counter < 57)
        begin
            last_keccak_result <= {last_keccak_result[1575:0],24'h0};
        end
    end


    integer i;

    reg [2:0] current_state, next_state;

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
            IDLE:  next_state = start_rej ? LOAD : IDLE;
            LOAD:  next_state = PROC;
            PROC:  next_state = done_keccak ? SAMP : PROC;
            SAMP:  next_state = (sample_done) ? DONE : (z_round_counter == 57) ? PROC : SAMP;
            //SAMP:  next_state = (sample_done) ? DONE : PROC;
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end



   
    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        z_counter <= 0;
        z_round_counter <= 0;
        sample_done <= 0;
        keccak_in <= 0;
        rho_en <= 1;
        keccak_rst_n <= 0;
        done_rej <= 0;
        start_keccak <= 0;
        z_out <= 0;
        z_valid <= 0;

    end else begin
        case (current_state)
            IDLE: begin
                // Do nothing in IDLE
                sample_done <= 0;
                keccak_in <= 0;
                rho_en <= 1;
                keccak_rst_n <= 0;
                done_rej <= 0;
                start_keccak <= 0;
            end

            LOAD: begin
                // Reset counters before sampling
                z_counter <= 0;
                z_round_counter <= 0;
                sample_done <= 0;
                keccak_rst_n <= 1;
            end

            PROC: begin
                keccak_rst_n <= 1;
                start_keccak <= 1;
                sample_round_done <= 0;
                z_round_counter <= 0;  //testing 
                z_valid <= 0;
                
            end

            SAMP: begin
                start_keccak <= 0;
                rho_en <= 0;

                //testingggg
                keccak_rst_n <= 0;
                z_round_counter <= z_round_counter + 1;


                if (z_round_counter == 0) begin
                    last_keccak_result <= keccak_output;
                    keccak_in <= keccak_output;
                end
                else if (z_round_counter < 57) begin
                    // Assign current 24-bit block from keccak_output in reverse byte order
                    b0b1b2 <= {
                        last_keccak_result[1583: 1576],
                        last_keccak_result[1591: 1584],
                        last_keccak_result[1599: 1592]
                    };
                end
                else if (z_round_counter == 57) begin
                    sample_round_done <= 1;
                end

                // Check z and store if valid, # of z not complete, and round counter > 1 
                //(round counter 0 = keccak value fetched), (round counter 1 = first sampled coeffecient produced)
                if (z != 24'h7FE001 && z_counter <= 255 && z_round_counter > 1) begin
                    z_array[z_counter] <= z;
                    z_counter <= z_counter + 1;

                    //used to eventually store z in sram
                    z_out <= z;
                    z_valid <= 1;
                end
                else begin
                    z_valid <= 0;
                end


                if (z_counter == 255) begin
                    sample_done <= 1;
                end
            end

            DONE: begin
                // Final state — flag completion

                //THIS IS ONLY FOR VERIFICATION NOT SYNTHESIZABLEE
                    $display("---- z_array contents ----");
                    for (i = 0; i < 256; i = i + 1) begin
                        // $display("z_array[%0d] = %h", i, z_array[i]);
                        $display("%h", z_array[i]);
                    end
                done_rej <= 1;
            end

            default: begin
                // Default behavior 
                z_counter <= 0;
                z_round_counter <= 0;
                sample_done <= 0;
                keccak_in <= 0;
                rho_en <= 1;
                keccak_rst_n <= 0;
            end
        endcase
    end
end


endmodule