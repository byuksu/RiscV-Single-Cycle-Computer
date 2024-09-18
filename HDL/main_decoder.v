module main_decoder(
	input wire [31:0] instr,
	output reg Branch, Jump, ImmJump, MemWrite, ALUSrc, RegWrite, data_select,
	output reg [1:0] ResultSrc, ALUOp);

wire [6:0] Op;
assign Op = instr[6:0];

always @(*)
	begin
		case (Op)
		// R
		7'b0110011: 
			begin
				Branch = 1'b0;
				Jump = 1'b0;
				ImmJump = 1'b0;
				ResultSrc = 2'b00;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b1;
				ALUOp = 2'b10;
				data_select = 1'b0;
			end 
		// I 
		7'b0010011: 
			begin
				Branch = 1'b0;
				Jump = 1'b0;
				ImmJump = 1'b0;
				ResultSrc = 2'b00;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				ALUOp = 2'b10;
				data_select = 1'b0;
			end
		//L
		7'b0000011: 
			begin
				Branch = 1'b0;
				Jump = 1'b0;
				ImmJump = 1'b0;
				ResultSrc = 2'b01;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				ALUOp = 2'b00;
				data_select = 1'b0;
			end
		//JALR
		7'b1100111:
			begin
				Branch = 1'b0;
				Jump = 1'b0;
				ImmJump = 1'b1;
				ResultSrc = 2'b10;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				ALUOp = 2'b00;
				data_select = 1'b1;
			end
		// XORID
		7'b0001011:
			begin
				Branch = 1'b0;
				Jump = 1'b0;
				ImmJump = 1'b0;
				ResultSrc = 2'b00;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				ALUOp = 2'b10;
				data_select = 1'b0;
			end
		// B
		7'b1100011:
			begin
				Branch = 1'b1;
				Jump = 1'b0;
				ImmJump = 1'b0;
				ResultSrc = 2'b00;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b0;
				ALUOp = 2'b01;
				data_select = 1'b0;
			end
		//JAL
		7'b1101111:
			begin
				Branch = 1'b0;
				Jump = 1'b1;
				ImmJump = 1'b0;
				ResultSrc = 2'b10;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b1;
				ALUOp = 2'b00;
				data_select = 1'b1;
			end
		//S
		7'b0100011:
			begin
				Branch = 1'b0;
				Jump = 1'b1;
				ImmJump = 1'b0;
				ResultSrc = 2'b00;
				MemWrite = 1'b1;
				ALUSrc = 1'b1;
				RegWrite = 1'b0;
				ALUOp = 2'b00;
				data_select = 1'b0;
			end
		//LUI
		7'b0110111:
			begin
				Branch = 1'b0;
				Jump = 1'b0;
				ImmJump = 1'b0;
				ResultSrc = 2'b00;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				ALUOp = 2'b11;
				data_select = 1'b0;
			end
		//AUIPC
		7'b0010111:
			begin
				Branch = 1'b0;
				Jump = 1'b0;
				ImmJump = 1'b0;
				ResultSrc = 2'b00;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				ALUOp = 2'b11;
				data_select = 1'b1;
			end
		default:
			begin
				Branch = 1'b0;
				Jump = 1'b0;
				ImmJump = 1'b0;
				ResultSrc = 2'b00;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b0;
				ALUOp = 2'b00;
				data_select = 1'b0;
			end
		endcase
	end
endmodule
			
		