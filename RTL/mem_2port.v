module mem (
    input  [15:0]       A0,       // Address (16 bits)
    input  [23:0]       D0,       // Data input
    input  [23:0]       BWEB0,    // Bit-wise Write Enable (active low)
    input               WEB0,     // Write Enable (active low)
    input               CEB0,     // Chip Enable (active low)
    input               CLK,     
    input  [1:0]        RTSEL,   
    input  [2:0]        WTSEL,   
    output reg [23:0]   Q0,    // Data output

    input  [15:0]       A1,       // Address (16 bits)
    input  [23:0]       D1,       // Data input
    input  [23:0]       BWEB1,    // Bit-wise Write Enable (active low)
    input               WEB1,     // Write Enable (active low)
    input               CEB1,     // Chip Enable (active low)   
    output reg [23:0]   Q1    // Data output
);

    // 65536-depth memory with 24-bit words
    reg [23:0] mem_array [0:65535];

    always @(posedge CLK) begin
        if (!CEB0) begin
            // Perform write only if WEB is low (write enabled)
            mem_array[A0] <= (!WEB0) ?  (D0 & ~BWEB0)  : mem_array[A0];                      

            // Read back the memory regardless of write enable
            Q0 <= mem_array[A0];
        end
    end

    always @(posedge CLK) begin
        if (!CEB1) begin
            // Perform write only if WEB is low (write enabled)
            mem_array[A1] <= (!WEB1) ?  (D1 & ~BWEB1)  : mem_array[A1];                      

            // Read back the memory regardless of write enable
            Q1 <= mem_array[A1];
        end
    end





    // FOR DEBUGGING PURPOSES ONLY
    task print_memory;
    integer i;
        begin
            $display("---- Memory Dump ----");
            for (i = 0; i < 65536; i = i + 1) begin
                $display("mem[%0d] = %h", i, mem_array[i]);
            end
            $display("----------------------");
        end
    endtask


    task print_memory_to_file;
        integer i;
        integer file;
        begin
            file = $fopen("mem_dump.txt", "w");  
            if (file == 0) begin
                $display("ERROR: Could not open file for memory dump.");
            end else begin
                $fdisplay(file, "---- Memory Dump ----");
                for (i = 0; i < 65536; i = i + 1) begin
                    if (mem_array[i] !== 24'dx)
                        // $fdisplay(file, "mem[%0d] = %h", i, mem_array[i]);
                        $fdisplay(file, "%h", mem_array[i]);
                end
                $fdisplay(file, "----------------------");
                $fclose(file);
            end
        end
    endtask



endmodule