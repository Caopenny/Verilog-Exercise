module gcd_control (
input wire eqflg,
input wire ltflg,
input wire clr,
input wire clk,
input wire go,
output reg xmsel,
output reg ymsel,
output reg xld,
output reg yld,
output reg gld
);
reg [2:0] present_state, nextstate;

parameter start=3'b000,
		  input1=3'b001,
		  test1=3'b010,
		  test2=3'b011,
		  update1=3'b100,
		  update2=3'b101,
		  done=3'b110;

//start registers
always @(posedge clk or posedge clr) begin 
	if(clr) present_state<=start;
	else present_state<=nextstate;
end

always @(*) begin 
case(present_state)
	start: if(go) nextstate<=inpu1;
		   else nextstate<=start;
	input1: nextstate<=test1;
	test1: if(eqflg)nextstate<=done;
		   else nextstate<=test2;
	test2: if(ltflg) nextstate<=update1;
		   else nextstate<=update2;
	update1: nextstate<=test1;
	update2: nextstate<=test1;
	done: nextstate<=done;
	default: nextstate<=start;
	endcase // present_state

end


always @(*) begin 
	xld=0;yld=0;gd=0;
	xmsel=0;ymsel=0;

	case(present_state)
		input1: begin xld=1;yld=1;xmsel=1;ymsel=1;endcase
		update1: yld=1;
		update2: xld=1;
		done:gld=1;
		default:;
	endcase

end

endmodule

endmodule
















