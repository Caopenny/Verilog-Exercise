//square root control
module SQRTctrl(
	input wire clk,
	input wire clr,
	input wire lteflg,
	input wire go,
	output reg ald,
	output reg sqld,
	output reg dld,
	output reg outld);
reg[1:0]present_state,next_state;
parameter start=2'b00, 
 		  test1=2'b01,
 		  update=2'b10,
 		  done=2'b11;



 //state register
 always @(posedge clk or posedge clr) begin
if(clr) present_state<=start;
else next_state<=present_state;
 end


 always @(*) begin
case (present_state)
	start: if(go) next_state<=test1;
		   else next_state<=start;
	test1: if(lteflg) next_state<=update;
			else next_state<=done;
	update: next_state<=test1;
	done: next_state<=done;
	default: next_state<=start;
endcase // present_state
 end


 always @(*) begin
 	ald=0;sqld=0;dld=0;outld=0;
case(present_state)
	start: ald=1;
	test1:;
	update: begin
		sqld=1;dld=1;
	end
	done:outld=1;
	default:;
endcase




 end
endmodule // SQRTctrl












