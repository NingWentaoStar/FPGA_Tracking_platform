module ddrWt_Scheduler (
        clk,reset,flat__block_Vaddr,block_pause_ahead1,block_req,flat__data18bit,data18bit_vld,block_granted,ddr_data,ddr_en,ddr_req,ddr_addr,ddr_len
    );
    //#####################################
    //state
    localparam WIDTH_state = $clog2(3);
    reg[WIDTH_state-1:0] state;
    localparam STATE_IDLE = 0;
    localparam STATE_REQ = 1;
    localparam STATE_S1 = 2;
    //buffers
    parameter  SIZE_buffers = 227*18;//227个18bit
    reg[SIZE_buffers-1:0]buffers;
    //index
    parameter NUM = 5;
    localparam WIDTH_index = $clog2(NUM);
    reg [WIDTH_index-1:0] index;
    //i_into_buffers
    localparam WIDTH_i_into_buffers = $clog2( 227 );
    reg[WIDTH_i_into_buffers-1:0] i_into_buffers;
    //i_out_buffers
    localparam WIDTH_i_out_buffers = $clog2( 255 );
    reg[WIDTH_i_out_buffers-1:0] i_out_buffers;
    //杂
    reg block_finish;
    reg ddr_finish;
    parameter WIDTH_BASE_ADDR = 32;
    parameter [WIDTH_BASE_ADDR-1:0]BASE_ADDR0 =0 ;
    parameter [WIDTH_BASE_ADDR-1:0]BASE_ADDR1 =0 ;
    parameter [WIDTH_BASE_ADDR-1:0]BASE_ADDR2 =0 ;
    parameter [WIDTH_BASE_ADDR-1:0]BASE_ADDR3 =0 ;
    parameter [WIDTH_BASE_ADDR-1:0]BASE_ADDR4 =0 ;
    localparam  [NUM*WIDTH_BASE_ADDR-1:0] FLAT__BASE_ADDR  ={BASE_ADDR4,BASE_ADDR3,BASE_ADDR2,BASE_ADDR1,BASE_ADDR0};
    //#####################################
    input clk;
    input reset;
    //###from/to Block:pause_ahead1;(data18bit_vld;data18bit);(Vaddr;req)
    parameter MAX_WIDTH_Vaddr = 20;//所有B中最宽的Vaddr的宽度
    //IO
    input [NUM*MAX_WIDTH_Vaddr-1:0]flat__block_Vaddr ;
    wire [MAX_WIDTH_Vaddr-1:0]block_Vaddr[NUM-1:0];
    input [NUM-1:0] block_req ;
    reg [17:0] data18bit[NUM-1:0];
    input  wire [NUM*18-1:0] flat__data18bit;
    output reg [NUM-1:0]block_granted;//只保持1clk
    genvar jj;
    for(jj=0;jj<NUM;jj=jj+1)
    begin
        //input
        assign block_Vaddr[jj]=flat__block_Vaddr[((jj+1)*MAX_WIDTH_Vaddr-1)-:MAX_WIDTH_Vaddr];
        //output
        assign flat__data18bit[((jj+1)*18-1)-:18]=data18bit[jj];//pds inner error
    end

    //###DDR
    parameter WIDTH_ddr_addr =25 ;

    output [15:0] ddr_data;
    input ddr_en;
    output reg ddr_req;
    output reg [WIDTH_ddr_addr-1:0]ddr_addr;
    output reg [WIDTH_ddr_addr-1:0]ddr_len;
    //#####################################
    always @( posedge clk )
    begin
        if (reset)
        begin
            state<=STATE_IDLE;
        end
        else
        begin
            case (state)
                STATE_IDLE:
                begin
                    if (block_req[index]==1)
                    begin
                        state<=STATE_REQ;
                    end
                end
                STATE_REQ:
                begin
                    state<=STATE_S1;
                end
                STATE_S1:
                begin
                    if(ddr_finish)
                    begin
                        state<=STATE_IDLE;
                    end
                end
                default:
                    state<=STATE_IDLE;
            endcase
        end
    end
    integer j;
    always @( posedge clk )
    begin
        if (reset)
        begin
            ddr_addr<=0;
            ddr_len<=0;
            ddr_req<=0;
            index<=0;
            i_into_buffers<=0;
            i_out_buffers<=0;

        end
        else
        begin
            case (state)
                STATE_IDLE:
                begin
                    block_granted<=0;
                    if (block_req[index]==0)
                    begin
                        if (index==NUM-1)
                        begin
                            index<=0;
                        end
                        else
                        begin
                            index<=index+1;
                        end
                    end
                    i_into_buffers<=0;
                    i_out_buffers<=0;
                    ddr_finish<=0;
                    block_finish<=0;
                end


                STATE_REQ:
                begin
                    ddr_req<=1;
                    ddr_addr<=block_Vaddr[index]+FLAT__BASE_ADDR[((index+1)*WIDTH_BASE_ADDR-1)-:WIDTH_BASE_ADDR];
                    ddr_len<=64;
                    block_granted[index]<=1;
                end
                STATE_S1:
                begin
                    block_granted[index]<=0;
                    if (ddr_en)
                    begin
                        ddr_req<=0;
                    end
                    if(i_into_buffers==227)
                    begin
                        block_finish<=1;
                        if (index==NUM-1)
                        begin
                            index<=0;
                        end
                        else
                        begin
                            index<=index+1;
                        end
                    end
                    else
                    begin
                        buffers[]<=data18bit[index];
                        i_into_buffers<=i_into_buffers+1;
                    end
                    if(block_finish)
                    begin
                        if (block_req[index]==0)
                        begin
                            if (index==NUM-1)
                            begin
                                index<=0;
                            end
                            else
                            begin
                                index<=index+1;
                            end
                        end
                    end
                    if(i_out_buffers<254)
                    begin
                        ddr_data<=buffers[];
                    end
                    else if(i_out_buffers==254)
                    begin
                        ddr_finish<=1;
                        ddr_data<={buffers[(227*18-1)-:6],10'b0};
                    end
                    else
                    begin
                        ddr_data<=0;
                    end
                    if(ddr_en || i_out_buffers<254)
                    begin
                        i_out_buffers<=i_out_buffers+1;
                    end
                end


            endcase
        end
    end





endmodule
