module alu_decoder(
	input wire [1:0] ALUOp,
	input wire [31:0] instr,
	output reg [3:0] ALUControl);

wire Op5, funct7_5, Op3;
wire [2:0] funct3;
assign Op3 = instr[3];
assign Op5 = instr[5];
assign funct7_5 = instr[30];
assign funct3 = instr[14:12];

always @(*)
	begin
		case(ALUOp)
		2'b00:
			begin
				ALUControl = 4'b0000;//S and L
			end
		2'b01:
			begin
				ALUControl = 4'b0001;//B
			end
		2'b10:
			begin
				case(funct3)
				3'b000:
					begin
						if({Op5, funct7_5} == 2'b11)
							begin
								ALUControl = 4'b0001;//SUB
							end
						else
							begin
								ALUControl = 4'b0000;//ADD
							end
					end
				3'b010:
					begin
						ALUControl = 4'b1000;//SLT
					end
				3'b110:
					begin
						ALUControl = 4'b0011;//OR
					end
				3'b111:
					begin
						ALUControl = 4'b0010;//AND
					end
				3'b011:
					begin
						ALUControl = 4'b1001;//SLTU
					end
				3'b100:
					begin
						if(Op3 == 1'b1)
							begin
								ALUControl = 4'b1111;//XORID
							end
						else
							begin
								ALUControl = 4'b0100;//XOR
							end
					end
				3'b001:
					begin
						ALUControl = 4'b0101;//SLL
					end
				3'b101:
					begin
						if(funct7_5 == 1'b0)
							begin
								ALUControl = 4'b0110;//SRL
							end
						else
							begin
								ALUControl = 4'b0111;//SRA
							end
					end
				endcase
			end
		2'b11:
			begin
				ALUControl = 4'b1010;
			end
		endcase
	end
endmodule
				