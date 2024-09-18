module Controller(
	input wire [31:0] instr,
	input wire zero, Neg, NegU,
	output wire [1:0] PCSrc, ResultSrc,
	output wire	[3:0] ALUControl,
	output wire RegWrite, MemWrite, ALUSrc, data_select);

wire Branch, Jump, ImmJump;
wire [1:0] ALUOp;
wire [2:0] funct3;
wire [6:0] Op;
reg x;
assign funct3 = instr[14:12];
assign Op = instr[6:0];

main_decoder main_decoder(
	.instr(instr),
	.Branch(Branch),
	.Jump(Jump),
	.ImmJump(ImmJump),
	.MemWrite(MemWrite),
	.ALUSrc(ALUSrc),
	.RegWrite(RegWrite),
	.ResultSrc(ResultSrc),
	.ALUOp(ALUOp),
	.data_select(data_select));

alu_decoder alu_decoder(
	.ALUOp(ALUOp),
	.instr(instr),
	.ALUControl(ALUControl));

assign PCSrc[1] = ImmJump;
always @(*)
	begin
		if(Op == 7'b1100011)
			begin
				case(funct3)
				3'b000://BEQ
					begin
						x = (Jump |(Branch & zero));
					end
				3'b001://BNE
					begin
						x = (Jump |(Branch & ~zero));
					end
				3'b100://BLT
					begin
						x = (Jump | (Branch & Neg));
					end
				3'b101://BGE
					begin
						x = (Jump | (Branch & ~Neg));
					end
				3'b110://BLTU
					begin
						x = (Jump | (Branch & NegU));
					end
				3'b111://BGEU
					begin
						x = (Jump | (Branch & ~NegU));
					end
				default:
					begin
						x = 1'b0;
					end
				endcase
			end
		else if(Op == 7'b0010111) // AUIPC
			begin
				x = 1'b1;
			end
		else
			begin
				x = 1'b0;
			end
	end
assign PCSrc[0] = x;
endmodule
				
							
						
						
						
						
