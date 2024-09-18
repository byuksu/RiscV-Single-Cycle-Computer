module ALUControl(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire funct7,
    output reg [3:0] alu_ctrl
);
    always @(*) begin
        case (opcode)
            7'b0110011: // R-type
                case ({funct7, funct3})
                    4'b0000: alu_ctrl = 4'b0000; // ADD
                    4'b1000: alu_ctrl = 4'b0001; // SUB
                    4'b0111: alu_ctrl = 4'b0010; // AND
                    4'b0110: alu_ctrl = 4'b0011; // OR
                    4'b0100: alu_ctrl = 4'b0100; // XOR
                    4'b0001: alu_ctrl = 4'b0101; // SLL
                    4'b0101: alu_ctrl = 4'b0110; // SRL
                    4'b1101: alu_ctrl = 4'b0111; // SRA
                    4'b0010: alu_ctrl = 4'b1000; // SLT
                    4'b0011: alu_ctrl = 4'b1001; // SLTU
                    default: alu_ctrl = 4'b0000;
                endcase
            7'b0010011: // I-type
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b111: alu_ctrl = 4'b0010; // ANDI
                    3'b110: alu_ctrl = 4'b0011; // ORI
                    3'b100: alu_ctrl = 4'b0100; // XORI
                    3'b001: alu_ctrl = 4'b0101; // SLLI
                    3'b101:
                        if (funct7 == 1'b0) alu_ctrl = 4'b0110; // SRLI
                        else alu_ctrl = 4'b0111; // SRAI
                    3'b010: alu_ctrl = 4'b1000; // SLTI
                    3'b011: alu_ctrl = 4'b1001; // SLTIU
                    default: alu_ctrl = 4'b0000;
                endcase
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule
