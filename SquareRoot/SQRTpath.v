module SQRTpath(
	input wire clk,
	input wire clr,
	input wire ald,
	input wire sqld,
	input wire dld,
	input wire outld,
	input wire [7:0] sw,
	output reg lteflg,
	output wire [3:0] root);
	wire [7:0] a;
	wire [8:0] sq,s;
	wire [4:0] del,del2;
	wire [3:0] dml;
	assign s=sq+{4'b0000,del};//adder8
	assign dp2=del+2;
	assign dml=del[4:1]-1;
	always@(*)begin
		if(sq<={1'b0,a})
			lteflg=<=1;
		else lteflg<=0;
	end // 

regr2#(.N(8),.BIT0(0),.BIT1(0))
aReg(.load(ald),.clk(clk),.reset(clr),.d(sw),.q(a));


regr2#(.N(8),.BIT0(1),.BIT1(0))
sqReg(.load(sqld),.clk(clk),.reset(clr),.d(s),.q(sq));

regr2#(.N(5),.BIT0(1),.BIT1(1))
delReg(.load(dld),.clk(clk),.reset(clr),.d(dp2),.q(del));

regr2#(.N(4),.BIT0(0),.BIT1(0))
outReg(.load(outld),.clk(clk),.reset(clr),.d(dml),.q(root));
endmodule // SQRTpath