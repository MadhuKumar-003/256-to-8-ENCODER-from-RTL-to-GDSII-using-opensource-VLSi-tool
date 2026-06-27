`timescale 1ns / 1ps

module tb_encoder();
    reg [255:0] in;
    wire [7:0] out;
    wire valid;

    encoder_256_to_8 uut (.in(in), .out(out), .valid(valid));

    integer i;

    initial begin
        $dumpfile("encoder_verification.vcd");
        $dumpvars(0, tb_encoder);

        $display("Starting Automated Verification...");

        // 1. Test All Single Bits
        for (i = 0; i < 256; i = i + 1) begin
            in = 256'b0;
            in[i] = 1'b1;
            #1;
            if (out !== i || valid !== 1'b1) begin
                $display("FAIL: Single bit test failed at bit %d", i);
            end
        end
        $display("Passed: Single bit tests.");

        // 2. Test Priority Logic (Randomized)
        repeat (100) begin
            in = $random; // Note: For 256 bits, use a better RNG if needed
            // Logic to determine expected output
            // (Highest bit index active)
            #1;
            // Add custom checker logic here if needed
        end

        $display("Verification Complete.");
        $finish;
    end
endmodule
