module uart_top(
                input   clk,rst,
                input   rxd,tx_en,
                output  txd,//,rx_flg,pty_err,frm_err,tx_bsy,   
               // output [7:0] rx_dat,
                input  [7:0] tx_dat
                );                                                                                                                                                                    

reg        dat_chg_flg_ff1,dat_chg_flg_ff2;
wire [7:0] dat_o;
wire       dat_chg_flg;
assign  tx_en_dn  = ~dat_chg_flg_ff1&& dat_chg_flg_ff2;

always@(posedge clk)
begin
	if(rst) {dat_chg_flg_ff1,dat_chg_flg_ff2}<=2'd0;
	else {dat_chg_flg_ff1,dat_chg_flg_ff2}       <={dat_chg_flg,dat_chg_flg_ff1};
end


uart_rx uart_rx_uut (                              
    .clk24m     (clk        ),      
    .rst        (rst        ),      
    .rdn        (1'd0       ),      
    .rx_dat     (rxd        ),      
    .dat_o      (dat_o      ),      
    .dat_rdy    (           ),      
    .frm_err    (           ),      
    .pity_err   (           ),      
    .dat_chg_flg(dat_chg_flg)                      
    );                                             


uart_tx uart_tx_uut (             
    .clk24m   (clk      ),        
    .rst      (rst      ),        
    .dat_in   (dat_o    ),        
    .dly_ms   (10'd0    ),        
    .wrn      (tx_en_dn ),        
    .tbre     (         ),        
    .tsre     (         ),        
    .sdo      (txd      ),        
    .no_bit_tx(         )         
    );                            
endmodule