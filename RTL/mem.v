module mem (
    input  [15:0]   A,       // Address (16 bits)
    input  [23:0] D,       // Data input
    input  [23:0] BWEB,    // Bit-wise Write Enable (active low)
    input          WEB,     // Write Enable (active low)
    input          CEB,     // Chip Enable (active low)
    input          CLK,     
    input  [1:0]   RTSEL,   
    input  [2:0]   WTSEL,   
    output reg [23:0] Q    // Data output
);

    // 65536-depth memory with 24-bit words
    reg [23:0] mem_array [0:65535];

    always @(posedge CLK) begin
        if (!CEB) begin
            // Perform write only if WEB is low (write enabled)
            mem_array[A] <= (!WEB) ?  (D & ~BWEB)  : mem_array[A];                      

            // Read back the memory regardless of write enable
            Q <= mem_array[A];
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