module ExpandA_FSM (
    input clk,
    input rst_n,
    input start_expandA,
    input done_rej,
    input [23:0] z_out,
    input z_valid,

    output reg done_expandA,
    output reg [7:0]   i,          
    output reg [7:0]   j,     
    output reg start_rej,

    output reg [15:0] A,
    output reg [23:0] D,
    output reg WEB

);
    localparam IDLE  = 3'b000;
    localparam LOAD  = 3'b001;  //load next inputs of RejNTTPoly
    localparam PROC  = 3'b010;  //RejNTTPoly processing and load received data to memory 
    localparam DONE  = 3'b011;

    wire [1:0] ML_DSA_level;
    reg [2:0] current_state, next_state;

    reg [15:0] address_counter;

    assign ML_DSA_level = 2'h1; //(1 is lowest level, 3 is the highest) (not used yet)

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
            IDLE:  next_state = start_expandA ? LOAD : IDLE;
            LOAD:  next_state = PROC;
            PROC:  next_state = done_expandA ? DONE : done_rej ? LOAD : PROC;
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end



   
    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
            done_expandA <= 0;
            i <= 0;
            j <= 0;   
            start_rej <= 0;

            A <= 0;
            D <= 0;
            WEB <= 1;
            address_counter <= 0;

    end else begin
        case (current_state)
            IDLE: begin
                done_expandA <= 0;
                i <= 0;
                j <= 0;
                start_rej <= 0;
                WEB <= 1;
                address_counter <= 0;

            end

            LOAD: begin
                start_rej <= 1;
            end

            PROC: begin
                start_rej <= 0;
                
                if (z_valid) begin
                    A <= address_counter;
                    D <= z_out;
                    WEB <= 0;
                    address_counter <= address_counter + 1;
                end
                else begin
                    WEB <= 1;
                end

                if (z_valid && (address_counter == 255  || address_counter == 511  || address_counter == 767  ||
                    address_counter == 1279 || address_counter == 1535 || address_counter == 1791 ||
                    address_counter == 2303 || address_counter == 2559 || address_counter == 2815 ||
                    address_counter == 3327 || address_counter == 3583 || address_counter == 3839))
                begin
                    i <= i + 1;
                end

                if (address_counter == 1023  || address_counter == 2047 || address_counter == 3071)
                begin
                    j <= j + 1;
                    i <= 0;
                end

                if (address_counter == 4096)
                begin
                    done_expandA <= 1;
                end
                
            end


            DONE: begin
                done_expandA <= 0;
            end

            default: begin
                done_expandA <= 0;
                i <= 0;
                j <= 0;   
                start_rej <= 0;

                A <= 0;
                D <= 0;
                WEB <= 1;
                address_counter <= 0;
            end
        endcase
    end
end

endmodule