module encoder_16_to_4 (
    input  [15:0] in,
    output reg [3:0] out,
    output reg valid
);
    // Using casez and '?' instead of casex to pass strict Verilator linting
    always @(*) begin
        casez (in)
            16'b1???_????_????_????: begin out = 4'd15; valid = 1; end
            16'b01??_????_????_????: begin out = 4'd14; valid = 1; end
            16'b001?_????_????_????: begin out = 4'd13; valid = 1; end
            16'b0001_????_????_????: begin out = 4'd12; valid = 1; end
            16'b0000_1???_????_????: begin out = 4'd11; valid = 1; end
            16'b0000_01??_????_????: begin out = 4'd10; valid = 1; end
            16'b0000_001?_????_????: begin out = 4'd9;  valid = 1; end
            16'b0000_0001_????_????: begin out = 4'd8;  valid = 1; end
            16'b0000_0000_1???_????: begin out = 4'd7;  valid = 1; end
            16'b0000_0000_01??_????: begin out = 4'd6;  valid = 1; end
            16'b0000_0000_001?_????: begin out = 4'd5;  valid = 1; end
            16'b0000_0000_0001_????: begin out = 4'd4;  valid = 1; end
            16'b0000_0000_0000_1???: begin out = 4'd3;  valid = 1; end
            16'b0000_0000_0000_01??: begin out = 4'd2;  valid = 1; end
            16'b0000_0000_0000_001?: begin out = 4'd1;  valid = 1; end
            16'b0000_0000_0000_0001: begin out = 4'd0;  valid = 1; end
            default: begin out = 4'd0; valid = 0; end
        endcase
    end
endmodule

module encoder_256_to_8 (
    input  [255:0] in,
    output [7:0] out,
    output valid
);
    // 64-bit flat bus (16 blocks * 4 bits per block) to avoid 2D array warnings
    wire [63:0] block_out_flat; 
    wire [15:0] block_valid;
    wire [3:0]  block_addr;
    wire [3:0]  offset_addr;

    // 1. Instantiate 16 encoders of 16-bits each
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : encoder_blocks
            encoder_16_to_4 u_enc (
                .in(in[(i*16)+15 : i*16]),
                .out(block_out_flat[(i*4)+3 : i*4]), 
                .valid(block_valid[i])
            );
        end
    endgenerate

    // 2. Priority encode the block_valid signals
    encoder_16_to_4 master_enc (
        .in(block_valid),
        .out(block_addr),
        .valid(valid)
    );

    // 3. Select the offset from the active block
    assign offset_addr = block_out_flat[(block_addr * 4) +: 4];

    // 4. Concatenate: [High 4 bits (block index), Low 4 bits (within block)]
    assign out = {block_addr, offset_addr};
endmodule
