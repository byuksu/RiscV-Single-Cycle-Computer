module ALU(
    input wire [31:0] a, b,    // ALU inputs
    input wire [3:0] alu_ctrl, // ALU control signal
    output reg [31:0] result,  // ALU result
    output wire zero, Neg, NegU           // Zero flag
);

	 localparam studentId1 = 32'd2110047;	// Bilal Yuksu
	 localparam studentId2 = 32'd2232700; // Hilmi Taşkın
	 
    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;       // ADD
            4'b0001: result = a - b;       // SUB
            4'b0010: result = a & b;       // AND
            4'b0011: result = a | b;       // OR
            4'b0100: result = a ^ b;       // XOR
            4'b0101: result = a << b[4:0]; // SLL
            4'b0110: result = a >> b[4:0]; // SRL
            4'b0111: result = $signed(a) >>> b[4:0]; // SRA
            4'b1000: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT
            4'b1001: result = (a < b) ? 1 : 0; // SLTU
				4'b1010: result = b; // Move
				4'b1111: result = a ^ (studentId1 ^ studentId2);                   // XORID
            default: result = 0;
        endcase
    end

    assign zero = (result == 0);
	 assign NegU = (a < b) ? 1'b1 : 1'b0; 
	 assign Neg = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0; 
endmodule
