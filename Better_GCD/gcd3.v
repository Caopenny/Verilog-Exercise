module gcd3(
	input wire clk, 
	input wire clr, 
	input wire go,
	input wire [3:0] xin,
	input wire [3:0] yin,
	output reg done,
	output reg [3:0] gcd
);

	reg [3:0]x,y;
	reg calc;
	always @(posedge clk or posedge clr) begin 
		if(clr)begin
			x<=0;y<=0;gcd<=0;
			done<=0;cal<=0;
		end // if(clr)
		else begin
			done<=0;
			if(go==1)begin
				x<=xin;
				y<=yin;
				calc<=1;
			end // if(go==1)
			else begin
				if(calc)
					if(x==y)
					begin
						gcd<=x;
						done<=1;
						calc<=0;
					end
					else 
						if(x<y) y<=y-x;
						else x<=x-y;
				end
			end



	end
	endmodule // gcd3
