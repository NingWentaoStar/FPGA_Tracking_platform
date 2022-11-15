// `include "ddrScheduler.v"
// `include "Block.v"
module DL(
        clk,reset,ddr_data,ddr_en,ddr_req,ddr_addr,ddr_len
    );
    //parameter ##################################################
    //DL
    parameter NUM              = 2          ;

    //DDR
    parameter  DS_data_NUM_in_1_batch= 224;//一次req从DS接受多少个18bit
    parameter WIDTH_ddr_addr =25 ;

    //DS
    parameter SIZE_buffers     = 7          ;
    //B
    parameter rdDS_Vaddr_DELTA = 144*28;//下次req DS_Vaddr要加这么多
    parameter WIDTH_BASE_ADDR  = 32         ;



    localparam B6_BASE_ADDR       = 0          ;
    localparam  B7_BASE_ADDR       = B6_BASE_ADDR  +64*3*4*18        ;
    localparam  B8_BASE_ADDR       = B7_BASE_ADDR  +64*3*4*18        ;



    parameter MAX_WIDTH_Vaddr = 20;//所有B中最宽的Vaddr的宽度

    //IO##################################################

    // ->DL
    input   clk                                 ;
    input   reset                              ;
    //DDR->DL.DS
    input   [15:0]  ddr_data                    ;
    input   ddr_en                              ;
    // DL.DS->DDR
    output wire  ddr_req                              ;
    output wire  [WIDTH_ddr_addr-1:0]  ddr_addr       ;
    output wire  [WIDTH_ddr_addr-1:0]  ddr_len        ;
    //DL.rdDS->B
    wire [17:0] rd_data18bit[NUM-1:0];
    wire [NUM-1:0]rd_data18bit_vld;
    wire  [NUM*18-1:0]  rd_flat__data18bit        ;
    wire [NUM-1:0]rd_block_granted;

    //B->DL.rdDS
    wire   [NUM*MAX_WIDTH_Vaddr-1:0]  rd_flat__block_Vaddr   ;
    wire [NUM-1:0]rd_block_req;
    wire [NUM-1:0]rd_block_pause_ahead1;
    //B<->DL.rdDS    flat
    generate
        genvar jj;
        for(jj=0;jj<NUM;jj=jj+1)
        begin
            //DS的output
            assign rd_data18bit[jj]=rd_flat__data18bit[((jj+1)*18-1)-:18];//pds inner error
        end
    endgenerate

    //例化##################################################

    //rdDS
    ddrRd_Scheduler #(
                        .SIZE_buffers    ( SIZE_buffers    ),
                        .NUM             ( NUM             ),
                        .WIDTH_BASE_ADDR ( WIDTH_BASE_ADDR ),
                        .BASE_ADDR0      ( B6_BASE_ADDR      ),
                        .BASE_ADDR1      ( B7_BASE_ADDR      ),
                        .WIDTH_ddr_addr(WIDTH_ddr_addr),
                        // .BASE_ADDR2      ( BASE_ADDR2      ),
                        // .BASE_ADDR3      ( BASE_ADDR3      ),
                        // .BASE_ADDR4      ( BASE_ADDR4      ),
                        .MAX_WIDTH_Vaddr ( MAX_WIDTH_Vaddr ))
                    rdDS (
                        .clk                       ( clk                                                 ),
                        .reset                     ( reset                                               ),
                        .block_pause_ahead1  ( rd_block_pause_ahead1  [NUM-1:0]                 ),
                        .flat__block_Vaddr         ( rd_flat__block_Vaddr         [NUM*MAX_WIDTH_Vaddr-1:0] ),
                        .block_req           ( rd_block_req           [NUM-1:0]                 ),
                        .ddr_data                  ( ddr_data                  [15:0]                    ),
                        .ddr_en                    ( ddr_en                                              ),

                        .block_granted(rd_block_granted),
                        .flat__data18bit           ( rd_flat__data18bit           [NUM*18-1:0]              ),
                        .data18bit_vld       ( rd_data18bit_vld       [NUM-1:0]                 ),
                        .ddr_req                   ( ddr_req                                             ),
                        .ddr_addr                  ( ddr_addr                  [WIDTH_ddr_addr-1:0]      ),
                        .ddr_len                   ( ddr_len                   [WIDTH_ddr_addr-1:0]      )
                    );
    //B6
    Block #(
              //   .C                      ( 16                      ),
              //   .H                      ( 12                      ),
              //   .W                      ( 16                     ),
              //   .WIDTH_A                ( 18                ),
              //   .WIDTH_B                ( 18                ),
              //   .WIDTH_o                ( 18                ),
              //   .WIDTH_eW               ( 18               ),
              //   .WIDTH_eB               ( 18               ),
              .C                      ( 64                      ),
              .H                      ( 3                      ),
              .W                      ( 4                     ),
              .WIDTH_A                ( 18                ),
              .WIDTH_B                ( 18                ),
              .WIDTH_o                ( 18                ),
              .WIDTH_eW               ( 18               ),
              .WIDTH_eB               ( 18               ),
              .DS_data_NUM_in_1_batch ( DS_data_NUM_in_1_batch ),



              //DRM
              .SIZE_inputLsB          ( 248          ),
              .SIZE_afterDW           ( 768           ),
              .SIZE_outputLsB         ( 248         ),
              .SIZE_LsB               ( 248               ),
              .SIZE_DRM               ( 1016               ),

              .WIDTH_rdDS_Vaddr(MAX_WIDTH_Vaddr),
              .END_rdDS_Vaddr         ( B7_BASE_ADDR-B6_BASE_ADDR         )
          )
          B6 (
              .clk                     ( clk                                        ),
              .reset                   ( reset                                      ),
              .rdDS_data18bit          ( rd_flat__data18bit[((0+1)*18-1)-:18]    ),
              .rdDS_data18bit_vld      ( rd_data18bit_vld[0]                         ),
              .rdDS_granted            ( rd_block_granted[0]                               ),

              .rdDS_Vaddr              ( rd_flat__block_Vaddr[((0+1)*MAX_WIDTH_Vaddr-1)-:MAX_WIDTH_Vaddr] ),
              .rdDS_req                ( rd_block_req[0]                                   )
          );

    //B7
    Block #(
              .C                      ( 64                      ),
              .H                      ( 3                      ),
              .W                      ( 4                     ),
              .WIDTH_A                ( 18                ),
              .WIDTH_B                ( 18                ),
              .WIDTH_o                ( 18                ),
              .WIDTH_eW               ( 18               ),
              .WIDTH_eB               ( 18               ),
              .DS_data_NUM_in_1_batch ( DS_data_NUM_in_1_batch ),



              //DRM
              .SIZE_inputLsB          ( 248          ),
              .SIZE_afterDW           ( 768           ),
              .SIZE_outputLsB         ( 248         ),
              .SIZE_LsB               ( 248               ),
              .SIZE_DRM               ( 1016               ),


              .WIDTH_rdDS_Vaddr(MAX_WIDTH_Vaddr),
              .END_rdDS_Vaddr         ( B8_BASE_ADDR-B7_BASE_ADDR         )
          )
          B7 (
              .clk                     ( clk                                        ),
              .reset                   ( reset                                      ),
              .rdDS_data18bit          ( rd_flat__data18bit[((1+1)*18-1)-:18]   ),
              .rdDS_data18bit_vld      ( rd_data18bit_vld[1]                         ),
              .rdDS_granted            ( rd_block_granted[1]                               ),

              .rdDS_Vaddr              ( rd_flat__block_Vaddr[((1+1)*MAX_WIDTH_Vaddr-1)-:MAX_WIDTH_Vaddr] ),
              .rdDS_req                ( rd_block_req[1]                                   )

          );





endmodule
