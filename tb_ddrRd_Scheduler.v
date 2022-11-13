//extension modified by scy
`timescale  1ns / 1ns

module tb_ddrRd_Scheduler;

    // ddrRd_Scheduler Parameters
    parameter PERIOD           = 10         ;
    parameter SIZE_buffers     = 7          ;
    parameter NUM              = 5          ;
    parameter WIDTH_BASE_ADDR  = 32         ;
    parameter BASE_ADDR0       = 0          ;
    parameter BASE_ADDR1       = 0          ;
    parameter BASE_ADDR2       = 0          ;
    parameter BASE_ADDR3       = 0          ;
    parameter BASE_ADDR4       = 0          ;
    parameter MAX_WIDTH_Vaddr  = 20         ;
    localparam WIDTH_ddr_addr =20 ;

    // ddrRd_Scheduler Inputs(block 除外)
    reg   clk                                  = 0 ;
    reg   reset                                = 1 ;

    reg   [15:0]  ddr_data                     = 0 ;
    reg   ddr_en                               = 0 ;

    // ddrRd_Scheduler Outputs(block 除外)

    wire  ddr_req                              ;
    wire  [WIDTH_ddr_addr-1:0]  ddr_addr       ;
    wire  [WIDTH_ddr_addr-1:0]  ddr_len        ;
    //block
    reg [NUM-1:0]block_pause_ahead1;
    wire [NUM-1:0]block_granted;
    reg [MAX_WIDTH_Vaddr-1:0]block_Vaddr[NUM-1:0];
    reg [NUM-1:0]block_req;
    wire [17:0] data18bit[NUM-1:0];
    wire [NUM-1:0]data18bit_vld;
    wire   [NUM*MAX_WIDTH_Vaddr-1:0]  flat__block_Vaddr   ;
    wire  [NUM*18-1:0]  flat__data18bit        ;
    generate
        genvar jj;
        for(jj=0;jj<NUM;jj=jj+1)
        begin
            //DS的input
            assign flat__block_Vaddr[((jj+1)*MAX_WIDTH_Vaddr-1)-:MAX_WIDTH_Vaddr]=block_Vaddr[jj];
            //DS的output
            assign data18bit[jj]=flat__data18bit[((jj+1)*18-1)-:18];
        end
    endgenerate

`include "ddrScheduler3.v"

    ddrRd_Scheduler #(
                        .SIZE_buffers    ( SIZE_buffers    ),
                        .NUM             ( NUM             ),
                        .WIDTH_BASE_ADDR ( WIDTH_BASE_ADDR ),
                        .BASE_ADDR0      ( BASE_ADDR0      ),
                        .BASE_ADDR1      ( BASE_ADDR1      ),
                        .BASE_ADDR2      ( BASE_ADDR2      ),
                        .BASE_ADDR3      ( BASE_ADDR3      ),
                        .BASE_ADDR4      ( BASE_ADDR4      ),
                        .MAX_WIDTH_Vaddr ( MAX_WIDTH_Vaddr ))
                    u_ddrRd_Scheduler (
                        .clk                       ( clk                                                 ),
                        .reset                     ( reset                                               ),
                        .block_pause_ahead1  ( block_pause_ahead1  [NUM-1:0]                 ),
                        .flat__block_Vaddr         ( flat__block_Vaddr         [NUM*MAX_WIDTH_Vaddr-1:0] ),
                        .block_req           ( block_req           [NUM-1:0]                 ),
                        .ddr_data                  ( ddr_data                  [15:0]                    ),
                        .ddr_en                    ( ddr_en                                              ),

                        .block_granted(block_granted),
                        .flat__data18bit           ( flat__data18bit           [NUM*18-1:0]              ),
                        .data18bit_vld       ( data18bit_vld       [NUM-1:0]                 ),
                        .ddr_req                   ( ddr_req                                             ),
                        .ddr_addr                  ( ddr_addr                  [WIDTH_ddr_addr-1:0]      ),
                        .ddr_len                   ( ddr_len                   [WIDTH_ddr_addr-1:0]      )
                    );




    initial
    begin
        forever
            #(PERIOD/2)  clk=~clk;
    end

    initial
    begin
        #(PERIOD*2) reset  =  0;
    end


    //仿block
    integer  ct_clk=0;
    always @( posedge clk )
    begin
        if (reset)
        begin
            block_pause_ahead1<=0;
        end
        else
        begin
            ct_clk<=ct_clk+1;
            if (ct_clk%13==7)
            begin
                block_pause_ahead1[4]<=1;
            end
            else
            begin
                block_pause_ahead1[4]<=0;

            end
        end
    end
    //仿DDR##########################################
    localparam SIZE_DDR = 123;
    reg [64-1:0] ddr[SIZE_DDR-1:0];
    integer j,j1;
    initial
    begin
        for(j=64'd0;j<SIZE_DDR;j=j+1)
        begin
            ddr[j]=j;
        end
        for(j=0;j<NUM;j=j+1)
        begin
            block_req[j]=0;
        end
        #(PERIOD*1)
         for(j=64'd0;j<SIZE_DDR;j=j+1)
         begin
             $display("ddr:%b",ddr[j]);
         end


         #(PERIOD*5)
          block_req[2]=1;
        block_req[4]=1;
        block_Vaddr[2]=4;
        block_Vaddr[4]=4;
         #(PERIOD*25)
        block_req[4]=0;










    end
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
    
    // task ddr_send_data;
       
    // endtask
endmodule
