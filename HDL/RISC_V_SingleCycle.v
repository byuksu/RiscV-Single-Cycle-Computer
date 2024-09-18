module RISC_V_SingleCycle(
    input wire clk, reset,       // Clock and reset
	 input wire [4:0] Debug_Source_select,
    output wire [31:0] PC,       // Program counter
	 output wire [31:0] Debug_out
);
    // Internal control signals
    wire RegWrite, MemWrite, mem_read, ALUSrc, zero, Neg, NegU, data_select;
    wire [3:0] ALUControl;
    wire [31:0] instr;     // Current instruction
	 wire [1:0] PCSrc, ResultSrc;
	 
    // Datapath instantiation
    Datapath my_datapath (
        .clk(clk),
        .reset(reset),
        .instr(instr),
        .pc(PC),
        .zero(zero),
		  .Neg(Neg),
		  .NegU(NegU),
		  .Debug_out(Debug_out),
		  .Debug_Source_select(Debug_Source_select),
		  .alu_ctrl(ALUControl),
		  .alu_src(ALUSrc),
		  .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .PCSrc(PCSrc),
		  .result_src(ResultSrc),
		  .data_select(data_select)
    );

    // Controller instantiation
    Controller my_controller (
        .instr(instr),
        .zero(zero),
		  .Neg(Neg),
		  .NegU(NegU),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
		  .ALUControl(ALUControl),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
		  .data_select(data_select)
    );

endmodule
