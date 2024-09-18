module shifter(
    input [31:0] operand,
    input [4:0] shamt,
    input [1:0] shift_type,
    output reg [31:0] result
);

    always @* begin
        case(shift_type)
            2'b00: result = operand << shamt; // SLL - logical left shift
            2'b01: result = operand >> shamt; // SRL - logical right shift
            2'b10: result = $signed(operand) >>> shamt; // SRA - arithmetic right shift
				2'b11: result = result; // no shift
            default: result = 32'b0; // undefined
        endcase
    end

endmodule
