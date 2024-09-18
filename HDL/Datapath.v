module Datapath(
    input wire clk, reset,       // Clock and reset
    output wire [31:0] instr,     // Current instruction
    output wire [31:0] pc,       // Program counter
    output wire zero, Neg, NegU, // Result from ALU
	 output wire [31:0] Debug_out,
	 input wire [4:0] Debug_Source_select,
	 input wire [3:0] alu_ctrl,
	 input wire alu_src, RegWrite, MemWrite, data_select,
	 input wire [1:0] PCSrc,result_src
);
    // Internal signals
    wire [31:0] pc_next, pc_plus4, pc_target;
    wire [31:0] rd1, rd2, imm_ext, src_a, src_b, result, wd3;
    wire [4:0] rd;
    wire reg_write, mem_read;

    // PC Register

	Register	ProgramCounter(
	.clk(clk),
	.reset(reset),
	.DATA(pc_next),
	.OUT(pc),
	.we(1'b1));
	defparam	ProgramCounter.WIDTH = 32;	// program counter with reset
	
	// instruction Memory
	Instruction_memory instrMem(
	.ADDR(pc),
	.RD(instr));
	defparam	instrMem.ADDR_WIDTH = 32;
	defparam	instrMem.BYTE_SIZE = 4;		//instruction memory
	
	
    // Instruction Decode
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    assign rd = instr[11:7];

    // Register File
    RegisterFile reg_file_dp (
        .clk(clk),
		  .reset(reset),
        .write_enable(RegWrite),
        .Source_select_0(rs1),
        .Source_select_1(rs2),
        .Destination_select(rd),
        .DATA(wd3),
        .out_0(rd1),
        .out_1(rd2),
		  .Debug_out(Debug_out),
		  .Debug_Source_select(Debug_Source_select)
    );

    // Immediate Extender
    ImmediateExtender imm_extender (
		  .instr(instr),
        .opcode(opcode),
        .imm_ext(imm_ext)
    );


    // ALU
    assign src_a = rd1;
	 
	 Mux_2to1	mux_1(
	.select(alu_src),
	.input_0(rd2),
	.input_1(imm_ext),
	.output_value(src_b)); 
	defparam	mux_1.WIDTH = 32; 
	
	 wire [31:0] alu_result;
    ALU alu (
        .a(src_a),
        .b(src_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero),
		  .Neg(Neg),
		  .NegU(NegU)
    );

    // Branch Target Calculation
	 Adder	pctarget(
	.DATA_A(pc),
	.DATA_B(imm_ext),
	.OUT(pc_target));
	defparam	pcPlusFour.WIDTH = 32; // PC target
	 
	 Adder	pcPlusFour(
	.DATA_A(pc),
	.DATA_B(32'b100),
	.OUT(pc_plus4));
	defparam	pcPlusFour.WIDTH = 32; // PC + 4

    // PC Next
	 Mux_4to1	mux_2(
	.select(PCSrc),
	.input_0(pc_plus4),
	.input_1(pc_target),
	.input_2(alu_result),
	.input_3(32'b0),
	.output_value(pc_next)); 
	defparam	mux_2.WIDTH = 32; // pc source selection

    // Output data for store instructions
	 wire [31:0] write_data, read_data;
	 wire [2:0] funct3;
	 assign funct3=instr[14:12];
    assign write_data = rd2;
	 
	 // Data memory
	 Memory	DataMemory(
	.clk(clk),
	.WE(MemWrite),
	.ADDR(alu_result),
	.funct3(funct3),
	.WD(write_data),
	.RD(read_data));
	defparam	DataMemory.ADDR_WIDTH = 32;
	defparam	DataMemory.BYTE_SIZE = 4;
	
	 Mux_4to1	mux_3(
	.select(result_src),
	.input_0(alu_result),
	.input_1(read_data),
	.input_2(pc_plus4),
	.input_3(32'b0),
	.output_value(result)); 
	defparam	mux_3.WIDTH = 32; // pc source selection
	
	Mux_2to1 mux_4(
	.select(data_select),
	.input_0(result),
	.input_1(pc_plus4),
	.output_value(wd3));
	defparam mux_4.WIDTH = 32;
	
	 
endmodule
