module gcd(
	input wire clk,
	input wire clr,
	input wire go,
	input wire [3:0] xin,
	input wire[3:0] yin,
	output wire [3:0] gcd_out);

wire eqflg,ltflg,xmsel,ymsel;
wire xld,yld,gld;

gcd_datapath U1
(.clk(clk),
 .clr(clr),
 .xmsel(xmsel),
 .ymsel(ymsel),
 .xld(xld),
 .yld(yld),
 .gld(gld),
 .xin(xin),
 .yin(yin),
 .gcd(gcd_out),
 .eqflg(eqflg),
 .ltflg(ltflg));


gcd_control U2(
.eqflg(eqflg),
.ltflg(ltflg),
.clr(clr),
.clk(clk),
.go(go),
.xmsel(xmsel),
.ymsel(ymsel),
.xld(xld),
.yld(yld),
.gld(gld)
);


endmodule // gcd