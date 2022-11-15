
`timescale 1ns/1ps
module  threshold_binary#(
        // parameter DW        = 24 ,
        // parameter Y_TH      = 150,
        // parameter Y_TL      = 40 ,
        // parameter CB_TH     = 155,
        // parameter CB_TL     = 100,
        // parameter CR_TH     = 240,
        // parameter CR_TL     = 160, //red

        parameter DW        = 24 ,
        parameter Y_TH      = 235,
        parameter Y_TL      = 16 ,
        parameter CB_TH     = 127,
        parameter CB_TL     = 77,
        parameter CR_TH     = 173,
        parameter CR_TL     = 133, //human skin


        parameter Y_TH_B      = 135 ,
        parameter Y_TL_B      = 50  ,
        parameter CB_TH_B     = 245 ,
        parameter CB_TL_B     = 156 ,
        parameter CR_TH_B     = 140 ,
        parameter CR_TL_B     = 80   //blule

)(
        input                            pixelclk   ,
        input                            reset_n    ,
        input [DW-1:0]                   i_ycbcr    ,
        input [DW-1:0]                   i_rgb      ,
        input                            i_hsync    ,
        input                            i_vsync    ,
        input                            i_de       ,
   
        
        output [DW-1:0]                  o_binary   ,
        output [DW-1:0]                  o_rgb      ,
        output                           o_hsync    ,
        output                           o_vsync    ,   
        output                           o_de                                                                                                
);


reg  [DW-1:0]           binary_r    ;
reg  [DW-1:0]           i_rgb_r     ;
reg                     h_sync_r    ;
reg                     v_sync_r    ;
reg                     de_r        ;
wire                    en0         ;
wire                    en1         ;
wire                    en2         ;
wire                    en0_b         ;
wire                    en1_b         ;
wire                    en2_b         ;
wire                    en0_g         ;
wire                    en1_g         ;
wire                    en2_g         ;

assign o_binary = binary_r; 
assign o_rgb    = i_rgb_r;
assign o_hsync  = h_sync_r;
assign o_vsync  = v_sync_r;
assign o_de     = de_r;

////////////////////// threshold//////////////////////////////////////
assign en0      =i_ycbcr[23:16] >=Y_TL  && i_ycbcr[23:16] <= Y_TH;
assign en1      =i_ycbcr[15: 8] >=CB_TL && i_ycbcr[15: 8] <= CB_TH;
assign en2      =i_ycbcr[ 7: 0] >=CR_TL && i_ycbcr[ 7: 0] <= CR_TH;
assign en0_b      =i_ycbcr[23:16] >=Y_TL_B && i_ycbcr[23:16] <= Y_TH_B  ;
assign en1_b      =i_ycbcr[15: 8] >=CB_TL_B && i_ycbcr[15: 8] <= CB_TH_B;
assign en2_b      =i_ycbcr[ 7: 0] >=CR_TL_B && i_ycbcr[ 7: 0] <= CR_TH_B;
assign en0_g      =i_rgb[23:16] >=8'd0 && i_rgb[23:16]  <= 8'd120;
assign en1_g      =i_rgb[15: 8] >=8'd160  && i_rgb[15: 8] <= 8'd250;
assign en2_g      =i_rgb[ 7: 0] >=8'd0  && i_rgb[ 7: 0] <= 8'd120;
/********************************************************************************************/

/***************************************timing***********************************************/

always @(posedge pixelclk)begin
    h_sync_r<= i_hsync;
    v_sync_r<= i_vsync;
    de_r    <= i_de;
    i_rgb_r <= i_rgb;
end 



/********************************************************************************************/

/***************************************Binarization threshold*******************************/


always @(posedge pixelclk or negedge reset_n) begin
    if(!reset_n)begin 
        binary_r <= 24'd0;
    end 
    else begin 
        if(en0==1'b1 && en1 ==1'b1 && en2==1'b1) begin 
            binary_r <= 24'h333333;
        end             
		else if(en0_b==1'b1 && en1_b ==1'b1 && en2_b==1'b1)begin         
		 	//binary_r <= 24'h111111;
		 	binary_r <= 24'h0;
		end 		 	
		else if(en0_g==1'b1 && en1_g ==1'b1 && en2_g==1'b1)begin         
		 	//binary_r <= 24'h222222;
		 	binary_r <= 24'h0;
		end
        else begin 
            //binary_r <= 24'hffffff;
            binary_r <= 24'h0;
        end 
    end  
end 



endmodule 