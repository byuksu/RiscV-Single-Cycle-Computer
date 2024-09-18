module Register #(parameter WIDTH=32) (
    input clk,
    input reset,
    input we,
    input [WIDTH-1:0] DATA,
    output reg [WIDTH-1:0] OUT
);

	initial begin
		OUT<=0;
	end	
	
    always @(posedge clk) begin
        if (reset) begin
            OUT <= {WIDTH{1'b0}};
        end else if (we) begin
            OUT <= DATA;
        end
    end
endmodule
