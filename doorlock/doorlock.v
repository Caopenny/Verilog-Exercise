//fsm practice
// 9 state in total, s0(input nothing), s1(right, input 1), s2(right, input 2)
// s3(right, input 3), s4(right, input 4, pass), E1(wrong, input 1)
//E2(wrong input 2), E3(wrong, input 3), E4(wrong input 4 fail)


//detect doorlock code from switch settings
module doorlock (
	input clk,    // Clock
	input clr,
	input [7:0] sw,
	input [1:0] bn.
	output reg pass,
	output reg fail
);


reg [3:0] present_state, next_state;
parameter s0=4'b0000, s1=4'b0001,s2=4'b0010,s3=4'b0011,s4=4'b0100,
		 	 		  e1=4'b0101,e2=4'b0110,e3=4'b0111,e4=4'b1000;

//state register
always @(posedge clk or posedge clr) begin
	if(clr==1) present_state<=s0
	else present_state<=next_state;
end

//module c1------determine the nextstate based on the current state and the input
always @(*) begin 

case (present_state)
	s0: if(bn==sw[7:6])
			next_state<=s1;
		else
			next_state<=e1;
	s1: if(bn==sw[5:4])
			next_state<=s2;
		else next_state<=e2;
	s2: if(bn==sw[3:2])
			next_state<=s3;
		else next_state<=e3;
	s3: if(bn==sw[1:0])
			next_state<=s4;
		else next_state<=e4;
	s4: if(bn==sw[7:6])
			next_state<=s1;
		else
			next_state<=e1;
	e1: next_state<=e2;
	e2: next_state<=e3;
	e3: next_state<=e4;
	e4: if(bn==sw[7:6])
			next_state<=s1;
		else
			next_state<=e1;
	default:next_state<=s0;
endcase // present_state


//c2 module; determine the output based on the present_state
always @(*)begin
	if(present_state==s4)  
	pass=1; 
	else pass=0;

	if(present_state==e4)
		fail=1;
	else fail=0;

end



end




















endmodule