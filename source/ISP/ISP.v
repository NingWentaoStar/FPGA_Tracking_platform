module ISP(

    input            pixelclk,
    input            rstin   ,
    input    [23:0]  i_rgb   ,
    input            i_hsync ,
    input            i_vsync ,
    input            i_de    ,

    input            red_en  ,
    input            grenn_en,
    input            blue_en ,

    output   [23:0]  VGA_rgb ,
    output           VGA_hsync,
    output           VGA_vsync,
    output           VGA_de,


    output wire [11:0]    vcount_center,
    output wire [11:0]    hcount_center
   );



wire    [23:0]    o_rgb;
wire   [23:0]    o_ycbcr;
wire             o_hsync;
wire             o_vsync;
wire             o_de;

reg        red_en_r;
reg        grenn_en_r;
reg        blue_en_r;

  


always@(posedge pixelclk or negedge rstin)
    if(!rstin) begin
      red_en_r<=0;  
    grenn_en_r<=0;
     blue_en_r<=0;   
       end
    else if(grenn_en) begin
      red_en_r<=0;  
    grenn_en_r<=1;
     blue_en_r<=0;        
        end
    else if(1'd1) begin
      red_en_r<=1;  
    grenn_en_r<=0;
     blue_en_r<=0;        
        end        
    else if(blue_en) begin
      red_en_r<=0;  
    grenn_en_r<=0;
     blue_en_r<=1;        
        end
    else begin
      red_en_r<=red_en_r;  
    grenn_en_r<=grenn_en_r;
     blue_en_r<=blue_en_r; 
end


rgb2ycbcr rgb2ycbcr(
    .pixelclk   (pixelclk),
	 .rst_n      (rstin) ,
    .i_rgb      (i_rgb),
    .i_hsync    (i_hsync),
    .i_vsync    (i_vsync),
    .i_de       (i_de),
    .i_de0      (),
  
    .o_rgb      (o_rgb),
    .o_ycbcr    (o_ycbcr),
    .o_hsync    (o_hsync),
    .o_vsync    (o_vsync),    
    .o_de0      (),                          
    .o_de       (o_de)                                                                                        
);


wire [23:0] o_binary_1 ;
wire [23:0] o_rgb_1    ;
wire        o_hsync_1  ;
wire        o_vsync_1  ;
wire        o_de_1     ;



threshold_binary#(
        // .DW         (24 ),
        // .Y_TH       (150),
        // .Y_TL       (40 ),
        // .CB_TH      (155),
        // .CB_TL      (100),
        // .CR_TH      (240),
        // .CR_TL      (160), //red

        .DW         (24 ),
        .Y_TH       (235),
        .Y_TL       (16 ),
        .CB_TH      (127),
        .CB_TL      (77),
        .CR_TH      (173),
        .CR_TL      (133), //human skin

      
        .Y_TH_B       (135 ),
        .Y_TL_B       (50  ),
        .CB_TH_B      (245 ),
        .CB_TL_B      (156 ),
        .CR_TH_B      (140 ),
        .CR_TL_B      (80  ) //blule

)threshold_binary(
        .pixelclk   (pixelclk),
        .reset_n    (rstin),
        .i_ycbcr    (o_ycbcr),
        .i_rgb      (o_rgb),
        .i_hsync    (o_hsync),
        .i_vsync    (o_vsync),
        .i_de       (o_de),
  
        
        .o_binary   (o_binary_1),
        .o_rgb      (o_rgb_1),
        .o_hsync    (o_hsync_1),
        .o_vsync    (o_vsync_1),   
        .o_de       (o_de_1)                                                                                         
);


wire [11:0] hcount;
wire [11:0] vcount;

wire HV_o_hsync;
wire HV_o_vsync;
wire HV_o_de;
wire [23:0] HV_dout;
wire [23:0] HV_o_rgb;



HVcount#(
     .DW(24),
	 .IW(1024)
      )HVcount(
    .pixelclk(pixelclk),
    .reset_n(rstin),
    .i_data(o_rgb_1),
    .i_binary(o_binary_1),
    .i_hsync(o_hsync_1),
    .i_vsync(o_vsync_1),
    .i_de(o_de_1),
    
    .hcount(hcount),
    .vcount(vcount),
    .o_data(HV_o_rgb),
    .o_binary(HV_dout),
    .o_hsync(HV_o_hsync),
    .o_vsync(HV_o_vsync),
    .o_de(HV_o_de)
    );    



reg [11:0] hcount_l;
reg [11:0] hcount_r;
reg [11:0] vcount_l;
reg [11:0] vcount_r;


wire [11:0] hcount_l_r;
wire [11:0] hcount_r_r;
wire [11:0] vcount_l_r;
wire [11:0] vcount_r_r;

wire [11:0] hcount_l_g;
wire [11:0] hcount_r_g;
wire [11:0] vcount_l_g;
wire [11:0] vcount_r_g;


wire [11:0] hcount_l_b;
wire [11:0] hcount_r_b;
wire [11:0] vcount_l_b;
wire [11:0] vcount_r_b;


reg    [23:0]HV_dout_r;
reg    [23:0]HV_dout_g;
reg    [23:0]HV_dout_b;

always@(posedge pixelclk or negedge rstin)
    if(!rstin)begin
        HV_dout_r<=0;
        HV_dout_g<=0;
        HV_dout_b<=0;
end
    else if(red_en_r)begin
        HV_dout_r<=HV_dout;
        HV_dout_g<=23'h0;
        HV_dout_b<=23'h0;       
    end
    else if(grenn_en_r)begin
        HV_dout_r<=23'h0;
        HV_dout_g<=HV_dout;
        HV_dout_b<=23'h0;       
    end
    else if(blue_en_r)begin
        HV_dout_r<=23'h0;
        HV_dout_g<=23'h0;
        HV_dout_b<=HV_dout;       
    end





Vertical_Projection_r#(
       .IMG_WIDTH_LINE (1024)
       )red(
       .pixelclk   (pixelclk) ,
	   . reset_n    (rstin) , 
       .en     (    red_en_r  ) ,   
	   . i_binary   (HV_dout_r) ,
	   . i_hs       (HV_o_hsync) ,
	   . i_vs       (HV_o_vsync) ,
	   . i_de       (HV_o_de) ,       
       
	   . i_hcount   (hcount) ,
	   . i_vcount   (vcount) ,
	   

	  . hcount_l    (hcount_l_r),
       .hcount_r    (hcount_r_r),
       .vcount_l    (vcount_l_r),
       .vcount_r    (vcount_r_r)

		 );


Vertical_Projection_g#(
       .IMG_WIDTH_LINE (1024)
       )green(
       .pixelclk   (pixelclk) ,
	   . reset_n    (rstin) , 
       .en     (   grenn_en_r    ) ,   
	   . i_binary   (HV_dout_g) ,
	   . i_hs       (HV_o_hsync) ,
	   . i_vs       (HV_o_vsync) ,
	   . i_de       (HV_o_de) ,       
       
	   . i_hcount   (hcount) ,
	   . i_vcount   (vcount) ,
   
	   . hcount_l    (hcount_l_g),
       .hcount_r    (hcount_r_g),
       .vcount_l    (vcount_l_g),
       .vcount_r    (vcount_r_g)

		 );


Vertical_Projection_b#(
       .IMG_WIDTH_LINE (1024)
       )blue(
       .pixelclk   (pixelclk) ,
	   . reset_n    (rstin) , 
       .en     (   blue_en_r    ) ,   
	   . i_binary   (HV_dout_b) ,
	   . i_hs       (HV_o_hsync) ,
	   . i_vs       (HV_o_vsync) ,
	   . i_de       (HV_o_de) ,       
       
	   . i_hcount   (hcount) ,
	   . i_vcount   (vcount) ,
	   
	   . hcount_l    (hcount_l_b),
       .hcount_r    (hcount_r_b),
       .vcount_l    (vcount_l_b),
       .vcount_r    (vcount_r_b)

		 );



always@(posedge pixelclk or negedge rstin)
    if(!rstin) begin
      hcount_l<=0;
      hcount_r<=0;
      vcount_l<=0;
      vcount_r<=0;  

  end
    else if(red_en_r) begin
        hcount_l<=hcount_l_r;
        hcount_r<=hcount_r_r;
        vcount_l<=vcount_l_r;
        vcount_r<=vcount_r_r;
end
    else if(grenn_en_r) begin
        hcount_l<=hcount_l_g;
        hcount_r<=hcount_r_g;
        vcount_l<=vcount_l_g;
        vcount_r<=vcount_r_g;
end
    else if(blue_en_r) begin
        hcount_l<=hcount_l_b;
        hcount_r<=hcount_r_b;
        vcount_l<=vcount_l_b;
        vcount_r<=vcount_r_b;
end
    else begin
       hcount_l<=0;
      hcount_r<=0;
      vcount_l<=0;
      vcount_r<=0;       
end        
 

wire [23:0]VGA_rgb;
wire       VGA_hsync;
wire       VGA_vsync;
wire       VGA_de;

display display(
        
      .pixelclk    (pixelclk),
	   .reset_n    (rstin) ,
       .red_en     (   red_en_r   ) ,
       .grenn_en     (   grenn_en_r  ) ,
       .blue_en     (   blue_en_r    ) ,
              
  	   .i_rgb      (HV_o_rgb) ,
	   .i_hsync    (HV_o_hsync) ,
	   .i_vsync    (HV_o_vsync) ,
	   .i_de       (HV_o_de) ,
                 
	   .hcount     (hcount) ,
      .vcount      (vcount),
               
      .hcount_l    (hcount_l),
      .hcount_r    (hcount_r),
      .vcount_l    (vcount_l),
      .vcount_r    (vcount_r),
             
                                 
      .o_rgb       (VGA_rgb),
	   .o_hsync    (VGA_hsync) ,
      .o_vsync     (VGA_vsync),                                                                                                  
	   .o_de       (VGA_de),


      .vcount_center    (vcount_center),
      .hcount_center    (hcount_center)
 );





endmodule