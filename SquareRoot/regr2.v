//Resets to initial value of lowest 2 bits
module regr2 
#(parameter N=4,
  BIT0=1,
  BIT1=1)
(input wire load,
 input wire clk,
 input wire reset,
 input wire [N-1:0]d,
 output wire [N-1:0] q

	
);


always @(posedge clk or posedge reset)
if (reset) begin
	q[N-1:2]<=0;
	q[0]<=BIT0;
	q[1]<=BIT1;
end
else if (load)
	q<=d;
endmodule