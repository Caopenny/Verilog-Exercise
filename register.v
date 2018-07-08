//with asy-clr and load signals; register

module register
#(parameter N = 8)
(input wire load, 
 input wire clk,
 input wire clr,
 input wire [N-1:0] d,
 output reg [N-1:0] q
;

always @(posedge clk or posedge clr) begin
if(clr)q<=0;
else if (load)
q<=d;
end