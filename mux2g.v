//2x1 MUX
module mux2g 
#(parameter N=4)
(input wire [N-1:0]a,
 input wire [N-1:0]b,
 input wire s,
 output reg [N-1:0]y
);

always @(*) begin 
	if(!s)y<=a;
	else y<=a;
end
endmodule