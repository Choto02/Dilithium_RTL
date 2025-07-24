module NTT_FSM (
    input clk,
    input rst_n,
    input start_NTT,
    input [23:0] Q0,
    input [23:0] Q1,

    input [23:0] input_chunk, //256 chunks of 24 bits (256*24)
    input [22:0] reduction_output0,
    input [22:0] reduction_output1,
    input [22:0] reduction_output2,

    output reg done_NTT,
    output [15:0] A0,
    output [23:0] D0,
    output WEB0,
    output [15:0] A1,
    output [23:0] D1,
    output WEB1,
    output [45:0] reduction_input0,
    output [45:0] reduction_input1,
    output [45:0] reduction_input2

);

    localparam IDLE  = 3'b000;
    localparam len_loop  = 3'b001;  //process NTT
    localparam start_loop = 3'b010;
    localparam j_read = 3'b011;
    localparam j_write = 3'b100;
    localparam DONE = 3'b101;




    reg [2:0] current_state, next_state;
    reg [10:0] m, len, start, j ;
    wire [23-1:0] zeta [0:255];
    reg [22:0] z;
   

    assign A0 = j + len; //added 1
    assign A1 = j ;    

    assign WEB0 = (current_state==j_read) ? 1'b1 : (current_state==j_write) ? 1'b0 : 1'b1;
    assign WEB1 = (current_state==j_read) ? 1'b1 : (current_state==j_write) ? 1'b0 : 1'b1; 

    assign D0 = reduction_output1;
    assign D1 = reduction_output2;

    assign reduction_input0 = z*(Q0);                
    assign reduction_input1 = Q1 - reduction_output0 + 23'd8380417;  
    assign reduction_input2 = Q1 + reduction_output0;    


    assign zeta[0] = 23'h000001;
    assign zeta[1] = 23'h495E02;
    assign zeta[2] = 23'h397567;
    assign zeta[3] = 23'h396569;
    assign zeta[4] = 23'h4F062B;
    assign zeta[5] = 23'h53DF73;
    assign zeta[6] = 23'h4FE033;
    assign zeta[7] = 23'h4F066B;
    assign zeta[8] = 23'h76B1AE;
    assign zeta[9] = 23'h360DD5;
    assign zeta[10] = 23'h28EDB0;
    assign zeta[11] = 23'h207FE4;
    assign zeta[12] = 23'h397283;
    assign zeta[13] = 23'h70894A;
    assign zeta[14] = 23'h088192;
    assign zeta[15] = 23'h6D3DC8;
    assign zeta[16] = 23'h4C7294;
    assign zeta[17] = 23'h41E0B4;
    assign zeta[18] = 23'h28A3D2;
    assign zeta[19] = 23'h66528A;
    assign zeta[20] = 23'h4A18A7;
    assign zeta[21] = 23'h794034;
    assign zeta[22] = 23'h0A52EE;
    assign zeta[23] = 23'h6B7D81;
    assign zeta[24] = 23'h4E9F1D;
    assign zeta[25] = 23'h1A2877;
    assign zeta[26] = 23'h2571DF;
    assign zeta[27] = 23'h1649EE;
    assign zeta[28] = 23'h7611BD;
    assign zeta[29] = 23'h492BB7;
    assign zeta[30] = 23'h2AF697;
    assign zeta[31] = 23'h22D8D5;
    assign zeta[32] = 23'h36F72A;
    assign zeta[33] = 23'h30911E;
    assign zeta[34] = 23'h29D13F;
    assign zeta[35] = 23'h492673;
    assign zeta[36] = 23'h50685F;
    assign zeta[37] = 23'h2010A2;
    assign zeta[38] = 23'h3887F7;
    assign zeta[39] = 23'h11B2C3;
    assign zeta[40] = 23'h0603A4;
    assign zeta[41] = 23'h0E2BED;
    assign zeta[42] = 23'h10B72C;
    assign zeta[43] = 23'h4A5F35;
    assign zeta[44] = 23'h1F9D15;
    assign zeta[45] = 23'h428CD4;
    assign zeta[46] = 23'h3177F4;
    assign zeta[47] = 23'h20E612;
    assign zeta[48] = 23'h341C1D;
    assign zeta[49] = 23'h1AD873;
    assign zeta[50] = 23'h736681;
    assign zeta[51] = 23'h49553F;
    assign zeta[52] = 23'h3952F6;
    assign zeta[53] = 23'h62564A;
    assign zeta[54] = 23'h65AD05;
    assign zeta[55] = 23'h439A1C;
    assign zeta[56] = 23'h53AA5F;
    assign zeta[57] = 23'h30B622;
    assign zeta[58] = 23'h087F38;
    assign zeta[59] = 23'h3B0E6D;
    assign zeta[60] = 23'h2C83DA;
    assign zeta[61] = 23'h1C496E;
    assign zeta[62] = 23'h330E2B;
    assign zeta[63] = 23'h1C5B70;
    assign zeta[64] = 23'h2EE3F1;
    assign zeta[65] = 23'h137EB9;
    assign zeta[66] = 23'h57A930;
    assign zeta[67] = 23'h3AC6EF;
    assign zeta[68] = 23'h3FD54C;
    assign zeta[69] = 23'h4EB2EA;
    assign zeta[70] = 23'h503EE1;
    assign zeta[71] = 23'h7BB175;
    assign zeta[72] = 23'h2648B4;
    assign zeta[73] = 23'h1EF256;
    assign zeta[74] = 23'h1D90A2;
    assign zeta[75] = 23'h45A6D4;
    assign zeta[76] = 23'h2AE59B;
    assign zeta[77] = 23'h52589C;
    assign zeta[78] = 23'h6EF1F5;
    assign zeta[79] = 23'h3F7288;
    assign zeta[80] = 23'h175102;
    assign zeta[81] = 23'h075D59;
    assign zeta[82] = 23'h1187BA;
    assign zeta[83] = 23'h52ACA9;
    assign zeta[84] = 23'h773E9E;
    assign zeta[85] = 23'h0296D8;
    assign zeta[86] = 23'h2592EC;
    assign zeta[87] = 23'h4CFF12;
    assign zeta[88] = 23'h404CE8;
    assign zeta[89] = 23'h4AA582;
    assign zeta[90] = 23'h1E54E6;
    assign zeta[91] = 23'h4F16C1;
    assign zeta[92] = 23'h1A7E79;
    assign zeta[93] = 23'h03978F;
    assign zeta[94] = 23'h4E4817;
    assign zeta[95] = 23'h31B859;
    assign zeta[96] = 23'h5884CC;
    assign zeta[97] = 23'h1B4827;
    assign zeta[98] = 23'h5B63D0;
    assign zeta[99] = 23'h5D787A;
    assign zeta[100] = 23'h35225E;
    assign zeta[101] = 23'h400C7E;
    assign zeta[102] = 23'h6C09D1;
    assign zeta[103] = 23'h5BD532;
    assign zeta[104] = 23'h6BC4D3;
    assign zeta[105] = 23'h258ECB;
    assign zeta[106] = 23'h2E534C;
    assign zeta[107] = 23'h097A6C;
    assign zeta[108] = 23'h3B8820;
    assign zeta[109] = 23'h6D285C;
    assign zeta[110] = 23'h2CA4F8;
    assign zeta[111] = 23'h337CAA;
    assign zeta[112] = 23'h14B2A0;
    assign zeta[113] = 23'h558536;
    assign zeta[114] = 23'h28F186;
    assign zeta[115] = 23'h55795D;
    assign zeta[116] = 23'h4AF670;
    assign zeta[117] = 23'h234A86;
    assign zeta[118] = 23'h75E826;
    assign zeta[119] = 23'h78DE66;
    assign zeta[120] = 23'h05528C;
    assign zeta[121] = 23'h7ADF59;
    assign zeta[122] = 23'h0F6E17;
    assign zeta[123] = 23'h5BF3DA;
    assign zeta[124] = 23'h459B7E;
    assign zeta[125] = 23'h628B34;
    assign zeta[126] = 23'h5DBECB;
    assign zeta[127] = 23'h1A9E7B;
    assign zeta[128] = 23'h0006D9;
    assign zeta[129] = 23'h6257C5;
    assign zeta[130] = 23'h574B3C;
    assign zeta[131] = 23'h69A8EF;
    assign zeta[132] = 23'h289838;
    assign zeta[133] = 23'h64B5FE;
    assign zeta[134] = 23'h7EF8F5;
    assign zeta[135] = 23'h2A4E78;
    assign zeta[136] = 23'h120A23;
    assign zeta[137] = 23'h0154A8;
    assign zeta[138] = 23'h09B7FF;
    assign zeta[139] = 23'h435E87;
    assign zeta[140] = 23'h437FF8;
    assign zeta[141] = 23'h5CD5B4;
    assign zeta[142] = 23'h4DC04E;
    assign zeta[143] = 23'h4728AF;
    assign zeta[144] = 23'h7F735D;
    assign zeta[145] = 23'h0C8D0D;
    assign zeta[146] = 23'h0F66D5;
    assign zeta[147] = 23'h5A6D80;
    assign zeta[148] = 23'h61AB98;
    assign zeta[149] = 23'h185D96;
    assign zeta[150] = 23'h437F31;
    assign zeta[151] = 23'h468298;
    assign zeta[152] = 23'h662960;
    assign zeta[153] = 23'h4BD579;
    assign zeta[154] = 23'h28DE06;
    assign zeta[155] = 23'h465D8D;
    assign zeta[156] = 23'h49B0E3;
    assign zeta[157] = 23'h09B434;
    assign zeta[158] = 23'h7C0DB3;
    assign zeta[159] = 23'h5A68B0;
    assign zeta[160] = 23'h409BA9;
    assign zeta[161] = 23'h64D3D5;
    assign zeta[162] = 23'h21762A;
    assign zeta[163] = 23'h658591;
    assign zeta[164] = 23'h246E39;
    assign zeta[165] = 23'h48C39B;
    assign zeta[166] = 23'h7BC759;
    assign zeta[167] = 23'h4F5859;
    assign zeta[168] = 23'h392DB2;
    assign zeta[169] = 23'h230923;
    assign zeta[170] = 23'h12EB67;
    assign zeta[171] = 23'h454DF2;
    assign zeta[172] = 23'h30C31C;
    assign zeta[173] = 23'h285424;
    assign zeta[174] = 23'h13232E;
    assign zeta[175] = 23'h7FAF80;
    assign zeta[176] = 23'h2DBFCB;
    assign zeta[177] = 23'h022A0B;
    assign zeta[178] = 23'h7E832C;
    assign zeta[179] = 23'h26587A;
    assign zeta[180] = 23'h6B3375;
    assign zeta[181] = 23'h095B76;
    assign zeta[182] = 23'h6BE1CC;
    assign zeta[183] = 23'h5E061E;
    assign zeta[184] = 23'h78E00D;
    assign zeta[185] = 23'h628C37;
    assign zeta[186] = 23'h3DA604;
    assign zeta[187] = 23'h4AE53C;
    assign zeta[188] = 23'h1F1D68;
    assign zeta[189] = 23'h6330BB;
    assign zeta[190] = 23'h7361B8;
    assign zeta[191] = 23'h5EA06C;
    assign zeta[192] = 23'h671AC7;
    assign zeta[193] = 23'h201FC6;
    assign zeta[194] = 23'h5BA4FF;
    assign zeta[195] = 23'h60D772;
    assign zeta[196] = 23'h08F201;
    assign zeta[197] = 23'h6DE024;
    assign zeta[198] = 23'h080E6D;
    assign zeta[199] = 23'h56038E;
    assign zeta[200] = 23'h695688;
    assign zeta[201] = 23'h1E6D3E;
    assign zeta[202] = 23'h2603BD;
    assign zeta[203] = 23'h6A9DFA;
    assign zeta[204] = 23'h07C017;
    assign zeta[205] = 23'h6DBFD4;
    assign zeta[206] = 23'h74D0BD;
    assign zeta[207] = 23'h63E1E3;
    assign zeta[208] = 23'h519573;
    assign zeta[209] = 23'h7AB60D;
    assign zeta[210] = 23'h2867BA;
    assign zeta[211] = 23'h2DECD4;
    assign zeta[212] = 23'h58018C;
    assign zeta[213] = 23'h3F4CF5;
    assign zeta[214] = 23'h0B7009;
    assign zeta[215] = 23'h427E23;
    assign zeta[216] = 23'h3CBD37;
    assign zeta[217] = 23'h273333;
    assign zeta[218] = 23'h673957;
    assign zeta[219] = 23'h1A4B5D;
    assign zeta[220] = 23'h196926;
    assign zeta[221] = 23'h1EF206;
    assign zeta[222] = 23'h11C14E;
    assign zeta[223] = 23'h4C76C8;
    assign zeta[224] = 23'h3CF42F;
    assign zeta[225] = 23'h7FB19A;
    assign zeta[226] = 23'h6AF66C;
    assign zeta[227] = 23'h2E1669;
    assign zeta[228] = 23'h3352D6;
    assign zeta[229] = 23'h034760;
    assign zeta[230] = 23'h085260;
    assign zeta[231] = 23'h741E78;
    assign zeta[232] = 23'h2F6316;
    assign zeta[233] = 23'h6F0A11;
    assign zeta[234] = 23'h07C0F1;
    assign zeta[235] = 23'h776D0B;
    assign zeta[236] = 23'h0D1FF0;
    assign zeta[237] = 23'h345824;
    assign zeta[238] = 23'h0223D4;
    assign zeta[239] = 23'h68C559;
    assign zeta[240] = 23'h5E8885;
    assign zeta[241] = 23'h2FAA32;
    assign zeta[242] = 23'h23FC65;
    assign zeta[243] = 23'h5E6942;
    assign zeta[244] = 23'h51E0ED;
    assign zeta[245] = 23'h65ADB3;
    assign zeta[246] = 23'h2CA5E6;
    assign zeta[247] = 23'h79E1FE;
    assign zeta[248] = 23'h7B4064;
    assign zeta[249] = 23'h35E1DD;
    assign zeta[250] = 23'h433AAC;
    assign zeta[251] = 23'h464ADE;
    assign zeta[252] = 23'h1CFE14;
    assign zeta[253] = 23'h73F1CE;
    assign zeta[254] = 23'h10170E;
    assign zeta[255] = 23'h74B6D7;



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
            IDLE:  next_state = start_NTT ? len_loop : IDLE;
            len_loop: next_state = (len >= 9'b1) ? start_loop : DONE ;
            start_loop: next_state = (start < 9'd256) ? j_read : len_loop;
            j_read: next_state = j_write;
            j_write: next_state = (j != start + len - 1) ? j_read : start_loop ;
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end


    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        m <= 0;
        len <= 0;
        start <= 0;
        j <= 0;
        done_NTT <=0;
        z<=0;
        

    end else begin
        case (current_state)
            IDLE: begin
                m <= 1;   //changed from 0 to 1
                len <= 9'd128;
                start <= 0;
                j <= 0;
                done_NTT <=0;
                z<=0;
            end

            //i am here
            len_loop: begin
                if (len >= 1) begin
                    start <= 0;
                end

            end

            start_loop: begin
                if (start < 9'd256) begin
                    m <= m+1;
                    z <= zeta[m];
                    j <= start;
                end
                else begin
                    len <= {1'b0, len[10:1]};
                end


            end

            j_read: begin
 
            end

            j_write: begin
                if ((j < start + len -1) ) begin
                    j <= j+1;
                end
                
                if ((j == start + len -1) ) begin
                    start <= start + {len[9:0], 1'b0};
                end

            end

            DONE: begin
                done_NTT <= 1;

            end

            default: begin
                m <= 1;   //changed from 0 to 1
                len <= 9'd128;
                start <= 0;
                j <= 0;
                done_NTT <=0;
                z<=0;
            end
        endcase
    end
end


endmodule
