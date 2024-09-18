module Memory#(
    parameter BYTE_SIZE = 4,  // Size of data in bytes 
    parameter ADDR_WIDTH = 32 // Width of the address bus
)(
    input clk,                   // Clock signal
    input WE,                    // Write Enable signal
    input [ADDR_WIDTH-1:0] ADDR, // Address input
    input [2:0] funct3,          // Function code to determine type of load/store
    input [(BYTE_SIZE*8)-1:0] WD, // Write Data input
    output reg [(BYTE_SIZE*8)-1:0] RD // Read Data output
);

    reg [7:0] mem [255:0]; // Memory array of 256 bytes

    // Combinational read logic
    always @(*) begin
        case (funct3)
            3'b000: RD = {{24{mem[ADDR][7]}}, mem[ADDR]}; // lb
            3'b001: RD = {{16{mem[ADDR+1][7]}}, mem[ADDR+1], mem[ADDR]}; // lh
            3'b010: RD = {mem[ADDR+3], mem[ADDR+2], mem[ADDR+1], mem[ADDR]}; // lw
            3'b100: RD = {24'b0, mem[ADDR]}; // lbu
            3'b101: RD = {16'b0, mem[ADDR+1], mem[ADDR]}; // lhu
            default: RD = 32'b0;
        endcase
    end

    // Synchronous write logic
    always @(posedge clk) begin
        if (WE) begin
            case (funct3)
                3'b000: mem[ADDR] <= WD[7:0]; // sb
                3'b001: {mem[ADDR+1], mem[ADDR]} <= WD[15:0]; // sh
                3'b010: {mem[ADDR+3], mem[ADDR+2], mem[ADDR+1], mem[ADDR]} <= WD; // sw
                default: ;
            endcase
        end
    end

endmodule
