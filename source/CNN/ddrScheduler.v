module ddrRd_Scheduler (
        clk,reset,flat__block_Vaddr,block_pause_ahead1,block_req,flat__data18bit,data18bit_vld,block_granted,ddr_data,ddr_en,ddr_req,ddr_addr,ddr_len
    );
    //#####################################
    //state
    localparam WIDTH_state = $clog2(5);
    reg[WIDTH_state-1:0] state;
    localparam STATE_IDLE = 0;
    localparam STATE_REQ = 1;
    localparam STATE_WAITING_FOR_EN = 2;
    localparam STATE_READING = 3;
    localparam STATE_CLEARING_BUFFERS = 4;
    //buffers
    parameter  SIZE_buffers = 7;
    reg[144-1:0]buffers[SIZE_buffers-1:0];
    reg [SIZE_buffers-1:0] buffer_vld;
    //index
    parameter NUM = 5;
    localparam WIDTH_index = $clog2(NUM);
    reg [WIDTH_index-1:0] index;
    //i_into_buffers
    localparam BUFFERS_SIZE_in_16bit = SIZE_buffers*144/16;
    localparam WIDTH_i_into_buffers = $clog2(BUFFERS_SIZE_in_16bit);
    reg[WIDTH_i_into_buffers-1:0] i_into_buffers;
    //i_out_buffers
    localparam BUFFERS_SIZE_in_18bit = SIZE_buffers*144/18;//56
    localparam WIDTH_i_out_buffers =  $clog2(BUFFERS_SIZE_in_18bit );//6
    reg[WIDTH_i_out_buffers-1:0] i_out_buffers;
    //杂
    reg [15:0] ddr_data_d1;
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
    //input
    input [NUM*MAX_WIDTH_Vaddr-1:0]flat__block_Vaddr ;
    input [NUM-1:0] block_pause_ahead1;
    wire [MAX_WIDTH_Vaddr-1:0]block_Vaddr[NUM-1:0];
    input [NUM-1:0] block_req ;
    //output
    reg [17:0] data18bit[NUM-1:0];
    output  wire [NUM*18-1:0] flat__data18bit;
    output reg [NUM-1:0]data18bit_vld;
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

    input [15:0] ddr_data;
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
                    state<=STATE_WAITING_FOR_EN;
                end
                STATE_WAITING_FOR_EN:
                begin
                    if (ddr_en==1)
                    begin
                        state<=STATE_READING;
                    end
                end
                STATE_READING:
                begin
                    if (ddr_en==0)
                    begin
                        state<=STATE_CLEARING_BUFFERS;
                    end
                end
                STATE_CLEARING_BUFFERS:
                begin
                    if (buffer_vld[i_out_buffers*18/144]==0)
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
            for(j=0;j<NUM;j=j+1)
            begin
                data18bit_vld[j]<=0;
                data18bit[j]<=0;
            end
        end
        else
        begin
            case (state)
                STATE_IDLE:
                begin
                    buffer_vld<=0;
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
                end


                STATE_REQ:
                begin
                    ddr_req<=1;
                    ddr_addr<=block_Vaddr[index]+FLAT__BASE_ADDR[((index+1)*WIDTH_BASE_ADDR-1)-:WIDTH_BASE_ADDR];
                    ddr_len<=64;
                    i_into_buffers<=0;
                    i_out_buffers<=0;
                    block_granted[index]<=1;
                end
                // STATE_WAITING_FOR_EN:
                // begin

                // end
                STATE_READING:
                begin
                    block_granted[index]<=0;
                    if (i_into_buffers==SIZE_buffers*144/16-1)
                    begin
                        i_into_buffers<=0;
                    end
                    else
                    begin
                        i_into_buffers<=i_into_buffers+1;
                    end
                    buffers[i_into_buffers*16/144][(i_into_buffers*16%144)-:16]<=ddr_data_d1;
                    if (i_into_buffers%(144/16)==144/16-1)
                    begin
                        buffer_vld[i_into_buffers*16/144]<=1;
                    end
                    //common part of STATE_READING、STATE_CLEARING_BUFFERS
                    if (block_pause_ahead1[index]||buffer_vld[i_out_buffers*18/144]==0)
                    begin
                        data18bit_vld[index]<=0;
                    end
                    else
                    begin
                        if (i_out_buffers==SIZE_buffers*144/18-1)
                        begin
                            i_out_buffers<=0;
                        end
                        else
                        begin
                            i_out_buffers<=i_out_buffers+1;
                        end




                        case (   i_out_buffers[5:3] /*除以8*/  )//ok
                            3'd0:
                                data18bit[index]<=buffers[0][(i_out_buffers%8+18-1)-:18];
                            3'd1:
                                data18bit[index]<=buffers[1][(i_out_buffers%8+18-1)-:18];
                            3'd2:
                                data18bit[index]<=buffers[2][(i_out_buffers%8+18-1)-:18];
                            3'd3:
                                data18bit[index]<=buffers[3][(i_out_buffers%8+18-1)-:18];
                            3'd4:
                                data18bit[index]<=buffers[4][(i_out_buffers%8+18-1)-:18];
                            3'd5:
                                data18bit[index]<=buffers[5][(i_out_buffers%8+18-1)-:18];
                            3'd6:
                                data18bit[index]<=buffers[6][(i_out_buffers%8+18-1)-:18];
                            default:
                                data18bit[index]<=0;
                        endcase





                        data18bit_vld[index]<=1;
                        if (i_out_buffers%(144/18)==144/18-1)
                        begin
                            buffer_vld[i_out_buffers*18/144]<=0;
                        end
                    end
                end
                STATE_CLEARING_BUFFERS:
                begin
                    //common part of STATE_READING、STATE_CLEARING_BUFFERS
                    if (block_pause_ahead1[index]||buffer_vld[i_out_buffers*18/144]==0)
                    begin
                        data18bit_vld[index]<=0;
                    end
                    else
                    begin
                        if (i_out_buffers==SIZE_buffers*144/18-1)
                        begin
                            i_out_buffers<=0;
                        end
                        else
                        begin
                            i_out_buffers<=i_out_buffers+1;
                        end



                        // flat__data18bit[((index+1)*18-1)-:18] <=buffers[i_out_buffers/8][(i_out_buffers*18%144)-:18];//sb
                        // data18bit[index] <=buffers[i_out_buffers/8][(i_out_buffers*18%144)-:18];//sb
                        // data18bit[index] <=buffers[i_out_buffers/8][17:0];//sb
                        // data18bit[index] <=buffers[i_out_buffers/8] ;//sb
                        // data18bit[index] <=buffers[0][(i_out_buffers*18%144)-:18];//ok
                        // data18bit[index] <=buffers[i_out_buffers][(i_out_buffers*18%144)-:18];//sb
                        // case (   i_out_buffers[5:3] /*除以8*/ )//ok
                        //     3'd0:
                        //         data18bit[index]<=buffers[0][((i_out_buffers+1)*18%144-1)-:18];
                        //     3'd1:
                        //         data18bit[index]<=buffers[1][((i_out_buffers+1)*18%144-1)-:18];
                        //     3'd2:
                        //         data18bit[index]<=buffers[2][((i_out_buffers+1)*18%144-1)-:18];
                        //     3'd3:
                        //         data18bit[index]<=buffers[3][((i_out_buffers+1)*18%144-1)-:18];
                        //     3'd4:
                        //         data18bit[index]<=buffers[4][((i_out_buffers+1)*18%144-1)-:18];
                        //     3'd5:
                        //         data18bit[index]<=buffers[5][((i_out_buffers+1)*18%144-1)-:18];
                        //     3'd6:
                        //         data18bit[index]<=buffers[6][((i_out_buffers+1)*18%144-1)-:18];
                        //     default:
                        //         data18bit[index]<=0;
                        // endcase
                        // data18bit[index] <=buffers[i_out_buffers[5:3]   ][(i_out_buffers*18%144)-:18];//sb

                        // data18bit[index] <=buffers[index ] ;//ok
                        // data18bit[index] <=buffers[i_out_buffers[5:3] ] ;//sb
                        // data18bit[index] <=buffers[i_out_buffers[4:3] ] ;//sb
                        // data18bit[index] <=buffers[index*2 ] ; //sb
                        case (   i_out_buffers[5:3] /*除以8*/ )//ok
                            3'd0:
                                data18bit[index]<=buffers[0][(i_out_buffers%8+18-1)-:18];
                            3'd1:
                                data18bit[index]<=buffers[1][(i_out_buffers%8+18-1)-:18];
                            3'd2:
                                data18bit[index]<=buffers[2][(i_out_buffers%8+18-1)-:18];
                            3'd3:
                                data18bit[index]<=buffers[3][(i_out_buffers%8+18-1)-:18];
                            3'd4:
                                data18bit[index]<=buffers[4][(i_out_buffers%8+18-1)-:18];
                            3'd5:
                                data18bit[index]<=buffers[5][(i_out_buffers%8+18-1)-:18];
                            3'd6:
                                data18bit[index]<=buffers[6][(i_out_buffers%8+18-1)-:18];
                            default:
                                data18bit[index]<=0;
                        endcase






                        data18bit_vld[index]<=1;
                        if (i_out_buffers*18%144==143)
                        begin
                            buffer_vld[i_out_buffers*18/144]<=0;
                        end
                    end
                end
            endcase
        end
    end
    always @( posedge clk )
    begin
        ddr_data_d1<=ddr_data;
    end




endmodule
