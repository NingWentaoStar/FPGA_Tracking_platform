//extension modified by scy
`timescale  1ns / 1ns
// `include "DL.v"

module tb_DL;
 //##########GRS_INST#####################
    reg grs_n;
    GTP_GRS GRS_INST(.GRS_N (grs_n) );
    initial
    begin
        grs_n = 1'b0;
        #5000 grs_n = 1'b1;
    end
// DL Parameters
parameter PERIOD                  = 10    ;
parameter NUM                     = 2     ;
    parameter WIDTH_ddr_addr =25 ;
parameter DS_data_NUM_in_1_batch  = 224   ;
parameter SIZE_buffers            = 7     ;
parameter rdDS_Vaddr_DELTA        = 144*28;
parameter WIDTH_BASE_ADDR         = 32    ;
parameter MAX_WIDTH_Vaddr         = 20    ;

// DL Inputs
reg   clk                                  = 0 ;
reg   reset                                = 1 ;
reg   [15:0]  ddr_data                     = 0 ;
reg   ddr_en                               = 0 ;

// DL Outputs
wire  ddr_req                              ;
wire  [WIDTH_ddr_addr-1:0]  ddr_addr       ;
wire  [WIDTH_ddr_addr-1:0]  ddr_len        ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) reset  =  0;
end

DL #(
    .NUM                    ( NUM                    ),
    .WIDTH_ddr_addr(WIDTH_ddr_addr),
    .DS_data_NUM_in_1_batch ( DS_data_NUM_in_1_batch ),
    .SIZE_buffers           ( SIZE_buffers           ),
    .rdDS_Vaddr_DELTA       ( rdDS_Vaddr_DELTA       ),
    .WIDTH_BASE_ADDR        ( WIDTH_BASE_ADDR        ),
    .MAX_WIDTH_Vaddr        ( MAX_WIDTH_Vaddr        ))
 u_DL (
    .clk                     ( clk                            ),
    .reset                   ( reset                          ),
    .ddr_data                ( ddr_data  [15:0]               ),
    .ddr_en                  ( ddr_en                         ),

    .ddr_req                 ( ddr_req                        ),
    .ddr_addr                ( ddr_addr  [WIDTH_ddr_addr-1:0] ),
    .ddr_len                 ( ddr_len   [WIDTH_ddr_addr-1:0] )
);




 //仿DDR##########################################
    localparam SIZE_DDR = 111111;
    reg [64-1:0] ddr[SIZE_DDR-1:0];
    integer j,j1;
 
    initial begin
        #(PERIOD*5)

        forever begin
         wait(ddr_req)
            begin
                #(PERIOD*5)
                 for(j=0;j<ddr_len;j=j+1)
                 begin
                     for(j1=0;j1<64/16;j1=j1+1)
                     begin
                         #PERIOD
                          ddr_data=ddr[ddr_addr+j][((j1+1)*16-1)-:16];
                         $strobe("ddr[ddr_addr+j]:%b", ddr[ddr_addr+j]);
                         $strobe("ddr_data:%b",ddr_data);
                         ddr_en=1;
                     end
                 end
             end
             ddr_en=0;
    end
    end
endmodule
