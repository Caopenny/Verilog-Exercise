`timescale 1ns / 1ps

// Module Name:    uart_rx 

module uart_rx(
              clk24m   ,
              rst      ,
              rdn      ,
              rx_dat    ,
              dat_o     ,
              dat_rdy   ,              
              frm_err   ,
              pity_err  ,
              dat_chg_flg
              );
input         clk24m;//systerm clock input.
input         rst;//reset, asynchronous active high.
input         rdn;//read strob. active low.
input         rx_dat;//UART receiver port.

output [7:0]  dat_o;//output data bus. it's high'z when no read strob.
output        dat_rdy;//active high. means dat_o ready for output. 	
output        frm_err;//active high. means stop bit error.
output        pity_err;//active high. means Parity check error.
output        dat_chg_flg;//active high.means rx data change.
   
reg           dat_rdy ,frm_err ,pity_err;
reg           clk1x_en;//enable the clk1x. active high.
reg    [8:0]  rsr;//receiver serial data from rx_dat and tranfer data to rbr.
reg    [7:0]  rbr;//accept data from rsr[7:0] and tranfer to dat_o.
reg    [3:0]  no_bit_rx;
reg           pity ,dat_chg_flg;
reg    [31:0] cnt_div13;
reg           div13_en;//24M/13=1.84M->(1.80M~1.88M) 1.84M clk enable
reg    [3:0]  cnt_div16;
reg           div16_en;//(1.84M divide 16) clk enable 
reg           dat_tmp_2 ,dat_tmp_1;

wire   [7:0]  dat_o;

localparam    SYS_FRE = 32'd24*(10**6),
              BPS     = 32'd115200,
              DIV_CLK = (SYS_FRE / BPS) >>> 4,
              DIV_CNT = DIV_CLK - 32'd1,
              DIV_EN  = (DIV_CNT >>> 1) - 32'd1;
                                
assign dat_o   = !rdn ? rbr : 8'bz ;

initial begin
  {cnt_div13 ,div13_en}    <= {32'd0 ,1'd0};
  {dat_tmp_2 ,dat_tmp_1}   <= {1'd1 ,1'd1};
  {clk1x_en ,dat_rdy}      <= {1'd0 ,1'd0};
  {cnt_div16 ,div16_en}    <= {4'd0 ,1'd0};
  {rsr ,rbr ,pity}         <= {9'd0 ,8'd0 ,1'd1};
  {pity_err ,frm_err}      <= {1'd0 ,1'd0};
  {no_bit_rx ,dat_chg_flg} <= {4'd0 ,1'd0};
end

always@(posedge clk24m)
begin
	if(rst) begin
		{cnt_div13 ,div13_en} <= {32'd0 ,1'd0};
	end
	else begin
		if(cnt_div13 < DIV_CNT) begin
		  cnt_div13 <= cnt_div13 + 32'd1;
		end
		else begin
			cnt_div13 <= 32'd0;
		end
	end
	case(cnt_div13)
	  DIV_EN: begin div13_en <= 1'd1; end
   default: begin div13_en <= 1'd0; end
  endcase	
end

always @(posedge clk24m)
begin
	if(rst) begin
		{dat_tmp_2 ,dat_tmp_1} <= {1'd1 ,1'd1};
	end
	else begin
		if(div13_en) begin
		  {dat_tmp_2 ,dat_tmp_1} <= {dat_tmp_1 ,rx_dat};
		end
	end
end

//rx_dat transfer from high to low means begin receiving data.
always @(posedge clk24m)
begin
	if(rst)
		clk1x_en <= 1'd0;
	else begin
		if(div13_en) begin
		  if(!dat_tmp_1 && dat_tmp_2)
			  clk1x_en <= 1'd1;
		  else begin
		    if(no_bit_rx == 4'd12)
			    clk1x_en <= 1'd0;
			end
		end
	end
end

//set data ready flag enable(High) after received
//set data ready flag disable(Low) after read enable.
always @(posedge clk24m)
begin
	if(rst)
		dat_rdy <= 1'd0;
	else begin
		if(div13_en) begin
		  if(!rdn)
		  	dat_rdy <= 1'd0;
		  else if((no_bit_rx == 4'd11) && (cnt_div16 == 4'd15))
		  	dat_rdy <= 1'd1; 
		end
	end
end


//generate clock, frequency = 1/16 * clk16x .(clk16x=clk24m/13)
always @(posedge clk24m)
begin
	if(rst) begin 
		{cnt_div16 ,div16_en} <= {4'd0 ,1'd0};
	end
	else begin
		if(div13_en) begin 
       if(clk1x_en) begin
		      cnt_div16 <= cnt_div16 + 4'd1;
		   end
	     else begin
	     	 if(!clk1x_en) begin
		        cnt_div16 <= 4'd0;
		     end
		   end
		   case(cnt_div16)
		     4'd6 : div16_en <= 1'd1;
		   default: div16_en <= 1'd0;
		   endcase
		end
	end		   
end


//receive data bit and generate the Parity bit 
always @(posedge clk24m)
begin
	if(rst) begin
		{rsr ,rbr ,pity} <= {9'd0 ,8'd0 ,1'd1};
	end
	else begin
		if(div16_en & div13_en) begin 
			case(no_bit_rx)
		  4'd1: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end
		  4'd2: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end		  	    
		  4'd3: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end
		  4'd4: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end	
		  4'd5: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end
		  4'd6: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end
		  4'd7: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end
		  4'd8: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end
		  4'd9: begin rsr[8]   <= dat_tmp_2;
		  	          rsr[7:0] <= rsr[8:1];
		  	          pity     <= pity ^ dat_tmp_2;
		  	    end
		  4'd10:begin rbr      <= rsr[7:0];
		  	    end
		default:begin pity     <= 1'd1;
			      end	    		  	    		  	    		  	    		  	    		  	    	  	    			
      endcase
    end
	end
end

//check Parity, set Parity error flag if Parity error
always @(posedge clk24m)
begin
	if(rst)
		pity_err <= 1'd0;
	else begin
		if(div16_en) begin
		  if((no_bit_rx >= 4'd10) && (!pity))
   	  	pity_err <= 1'd1;
		  else
		  	pity_err <= 1'd0;
		end
	end
end

//check frame integrality, set frame error flag if frame error
always @(posedge clk24m)
begin
	if(rst)
		frm_err <= 1'd0;
	else begin
		if(div16_en) begin
		  if((no_bit_rx >= 4'd11) && (dat_tmp_2 != 1'd1))
			  frm_err <= 1'd1;
		  else
			  frm_err <= 1'd0;
		end
	end
end

//generate receive bit count
//always @(posedge clk24m or negedge clk1x_en) 
always @(posedge clk24m)
begin
	if(rst)
		no_bit_rx <= 4'd0;
	else if (!clk1x_en)
		no_bit_rx <= 4'd0 ;
	else
	  if(div16_en & div13_en) begin
		  no_bit_rx <= no_bit_rx + 4'd1 ;
		end
end

always @(posedge clk24m)
begin
	if(rst)
		dat_chg_flg <= 1'd0;
	else
	  if(div16_en & div13_en) begin 
	    case(no_bit_rx)
	      4'd10: dat_chg_flg<=1'd1;
	    default: dat_chg_flg<=1'd0;
	    endcase
	  end
end

endmodule
