`timescale 1ns / 1ps
// Module Name:    UartTx 
// Project Name: 

module  uart_tx(
               clk24m ,
               rst    ,
               dat_in ,
               dly_ms ,
               wrn    ,
               tbre   ,
               tsre   ,                                                   
               sdo    ,
               no_bit_tx
               ) ;
               
input          clk24m ,rst;//16x clock. synchronous active high. reset. 
input  [7:0]   dat_in;//input data bus.	 
input          wrn;//write strobe. active low. 
input  [9:0]   dly_ms;
output         tbre ,tsre;//active high. means transmitter buffer register empty.//active high. means serial output register empty.	   
output         sdo;	  		//UART transmitter port.
output [3:0]   no_bit_tx;
   
reg            tbre ,tsre ,sdo ,clk1x_en ,parity;   
reg    [3:0]   no_bit_tx ,cnt_div16 ; 	 
reg    [7:0]   tsr ,Tbr; 
reg            wrn_tmp1 ,wrn_tmp2;	 
reg    [31:0]  cnt_div13;
reg            div13_en ,div16_en;

localparam    SYS_FRE = 32'd24*(10**6),
              BPS     = 32'd115200,
              DIV_CLK = (SYS_FRE / BPS) >>> 4,
              DIV_CNT = DIV_CLK - 32'd1,
              DIV_EN  = (DIV_CNT >>> 1) - 32'd1;

initial begin
  {cnt_div13 ,div13_en}     <= {32'd0 ,1'd0};
  {Tbr ,wrn_tmp2 ,wrn_tmp1} <= {8'd0 ,1'd1 ,1'd1};
  {clk1x_en ,tbre}          <= {1'd0 ,1'd1};
  {cnt_div16 ,div16_en}     <= {4'd0 ,1'd0};
  {sdo ,tsre ,parity ,tsr}  <= {1'd1 ,1'd1 ,1'd0 ,8'd0};	
  no_bit_tx <= 4'b0;  
end
	 
always@(posedge clk24m)
begin
	if(rst) {cnt_div13 ,div13_en} <= {32'd0 ,1'd0};
	else begin
		if(cnt_div13 < DIV_CNT)
		  cnt_div13 <= cnt_div13 + 32'd1;
		else cnt_div13 <= 32'd0;
	end
	case(cnt_div13)
	  DIV_EN: begin div13_en <= 1'd1; end
   default: begin div13_en <= 1'd0; end
  endcase	
end

always @(posedge clk24m)
begin
	if(rst) {Tbr ,wrn_tmp2 ,wrn_tmp1} <= {8'd0 ,1'd1 ,1'd1};
	else begin
		if(div13_en) begin
		  {wrn_tmp2 ,wrn_tmp1} <= {wrn_tmp1 ,wrn};
		  if(!wrn) Tbr <= dat_in ;
		end
	end
end
//--------------------delay------------------------
reg [9 : 0]      cnt_750 ,cnt_1k;
reg [4 : 0]      cnt_32;
reg              clk_1khz ,dly_strt ,dly_stop;
initial begin
	{cnt_750 ,cnt_32} <= {10'd0 ,5'd0};
	{cnt_750 ,cnt_32 ,cnt_1k} <= {10'd0 ,5'd0 ,10'd0};
	{clk_1khz ,dly_strt ,dly_stop} <= {1'd0 ,1'd0 ,1'd0};
end

always@(posedge clk24m)
begin
	if(rst | (~ dly_strt)) {cnt_750 ,cnt_32} <= {10'd0 ,5'd0};	 
	else begin
	  if(cnt_750 == 10'd749)begin          
        cnt_750 <= 10'd0;
        cnt_32 <= cnt_32 + 5'd1; 
    end
    else cnt_750 <= cnt_750 + 10'd1; 
  end
end

always@(posedge clk24m)
begin
 if(cnt_750==10'd749 && cnt_32==5'd31)   
      clk_1khz <= 1'd1; 
 else clk_1khz <= 1'd0; 
end

always@(posedge clk24m)
begin
 if((cnt_1k == 10'd499 && clk_1khz) || (~ dly_strt)) 
     cnt_1k <= 1'd0;
 else if(clk_1khz)
     cnt_1k <= cnt_1k + 10'd1;
 case({cnt_1k ,cnt_div13})
   {dly_ms ,DIV_EN} : dly_stop <= 1'd1;//DLY_MS
            default : dly_stop <= 1'd0; 
 endcase   
end
//------------------end delay----------------------
//generate clk1x enable signal after write strobe
//always @(posedge clk24m)
//begin
//	if(rst) {clk1x_en ,tbre} <= {1'd0 ,1'd1};
//	else begin 
//	  if(div13_en) begin
//	    if(!wrn_tmp1 && wrn_tmp2)	        
//	       {clk1x_en ,tbre} <= {1'd1 ,1'd0};                  
//	    else if(no_bit_tx == 4'd12)	  
//         {clk1x_en ,tbre} <= {1'd0 ,1'd1};               
//	  end
//  end
//end

always @(posedge clk24m)
begin
	if(rst) {clk1x_en ,tbre} <= {1'd0 ,1'd1};
	else begin 
	  if(div13_en) begin
	    if(!wrn_tmp1 && wrn_tmp2)	        
	       {clk1x_en ,tbre} <= {1'd1 ,1'd0};                  
	    else if(no_bit_tx == 4'd12 && dly_stop)	  
         {clk1x_en ,tbre} <= {1'd0 ,1'd1};               
	  end
  end
end

//clk1x works when clk1x enable
always @(posedge clk24m)
begin
	if(rst) {cnt_div16 ,div16_en} <= {4'd0 ,1'd0};
	else begin
		if(div13_en) begin 
       if(clk1x_en) cnt_div16 <= cnt_div16 + 4'd1 ;
	     else if(!clk1x_en) cnt_div16 <= 4'd0;
		   case(cnt_div16)
		     4'd6 : div16_en <= 1'd1;
		   default: div16_en <= 1'd0;
		   endcase
		end
	end		   
end

//transmit data bit
always @(posedge clk24m)
begin
	if(rst) {sdo ,parity ,tsr} <= {1'd1 ,1'd0 ,8'd0};
	else begin
		if(div16_en & div13_en) begin
			case(no_bit_tx)
			  4'd0: begin
			  	      {tsr } <= {Tbr };  
			  	    end
			  4'd1: begin
			  	      sdo <= 1'd0 ;
			  	    end
			  4'd2: begin 
			  	      tsr[6:0] <= tsr[7:1];     
			  	      tsr[7]   <= 1'd0;           
			  	      sdo      <= tsr[0];            
			  	      parity   <= parity ^ tsr[0];
			  	    end
			  4'd3: begin
			  	      tsr[6:0] <= tsr[7:1];       
			  	      tsr[7]   <= 1'd0;           
			  	      sdo      <= tsr[0];         
			  	      parity   <= parity ^ tsr[0];
			  	    end
			  4'd4: begin
			  	      tsr[6:0] <= tsr[7:1];       
			  	      tsr[7]   <= 1'd0;           
			  	      sdo      <= tsr[0];         
			  	      parity   <= parity ^ tsr[0];
			  	    end
			  4'd5: begin
			  	      tsr[6:0] <= tsr[7:1];       
			  	      tsr[7]   <= 1'd0;           
			  	      sdo      <= tsr[0];         
			  	      parity   <= parity ^ tsr[0];
			  	    end
			  4'd6: begin
			  	      tsr[6:0] <= tsr[7:1];       
			  	      tsr[7]   <= 1'd0;           
			  	      sdo      <= tsr[0];         
			  		    parity   <= parity ^ tsr[0];
			  		  end
			  4'd7: begin
			  	      tsr[6:0] <= tsr[7:1];       
			  	      tsr[7]   <= 1'd0;           
			  	      sdo      <= tsr[0];         
			  	      parity   <= parity ^ tsr[0];
			  	    end
			  4'd8: begin
			  	      tsr[6:0] <= tsr[7:1];       
			  	      tsr[7]   <= 1'd0;           
			  	      sdo      <= tsr[0];         
			  	      parity   <= parity ^ tsr[0];
			  	    end
			  4'd9: begin
			  	      tsr[6:0] <= tsr[7:1];       
			  	      tsr[7]   <= 1'd0;           
			  	      sdo      <= tsr[0];         
			  	      parity   <= parity ^ tsr[0];
			  	    end
			 4'd10: begin
			 	        sdo      <= parity ;
			 	      end
			 4'd11: begin
			 	        sdo      <= 1'd1 ;   
			 	        parity   <= 1'd0;
			 	      end
		 default: begin
		 	          {sdo ,parity} <= {1'd1 ,1'd0};   
			  	    end 
			 endcase  			  	      
		end   
	end
end

always @(posedge clk24m)
begin
	if(rst) {dly_strt ,tsre} <= {1'd0 ,1'd1};
	else begin
		case(no_bit_tx)
		  4'd0 : if(div16_en & div13_en) tsre <= 1'd0;  
		  4'd11: if(div16_en & div13_en) dly_strt <= 1'd1;
		  4'd12: if(dly_stop) {dly_strt ,tsre} <= {1'd0 ,1'd1};
		default: ;
		endcase
	end
end

//count transmitted bit
//always @(posedge clk24m or negedge clk1x_en) 
always @(posedge clk24m)
begin
	if(rst) no_bit_tx <= 4'd0;
	else begin		 
	    if(!clk1x_en)
		    no_bit_tx <= 4'd0;
	    else begin
	    	if(div16_en & div13_en)
		      no_bit_tx <= (no_bit_tx <= 4'd11) ? no_bit_tx + 4'd1 : no_bit_tx;
		  end
	end
end

endmodule