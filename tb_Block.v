`include "Conv_BN.v"


module
    Block(
            clk,reset
        );
    //parameter##############################
    parameter C  = 64;
    parameter H  = 3;
    parameter W  = 4;
    //
    parameter NUM_conv_ele = 9;
    parameter WIDTH_A   = 18;//A:feature image
    parameter WIDTH_B   = 18;//B:filter
    parameter WIDTH_o   = 96;
    parameter WIDTH_eW  = 18;
    parameter WIDTH_eB  = 18;


    //localparam##############################
    localparam WIDTH_ct = $clog2(NUM_conv_ele+1);
    //reg##############################
    reg [WIDTH_ct-1:0]  ct;
    //inout##############################
    input  wire clk;
    input   wire  reset;



    //未分类#################################
    wire MA_finish;
    wire almost_ready;//ahead ready,MA_finish 1clk
    localparam WIDTH_c=$clog2(C) ;
    localparam WIDTH_y=$clog2(H) ;
    localparam WIDTH_x=$clog2(W) ;
    reg [WIDTH_c-1:0] c0;
    reg [WIDTH_y-1:0] y0;
    reg [WIDTH_x-1:0] x0;
    wire [WIDTH_y-1:0] y;
    wire [WIDTH_x-1:0] x;
    wire padding;
    reg padding_d;
    wire     [WIDTH_A-1:0] Ain;
    wire     [WIDTH_B-1:0] Bin;
    wire block_finish;//本block的工作完毕。即：update_整个特征图
    wire update_c0;
    wire update_y0;//y0将要update（卷积中心换入新一行(包含进入新一通道)）
    wire update_x0;
    parameter DS_data_NUM_in_1_batch = 224;//一次req从DS接受多少个18bit
    parameter rdDS_Vaddr_DELTA = 144*28;//下次req DS_Vaddr要加这么多
    wire   DRM_wr_en                 ;
    wire   [7:0]  DRM_rd_addr           ;
    wire   [7:0]  DRM_wr_addr           ;
    wire  [17:0]  DRM_rd_data        ;
    wire   [17:0]  DRM_wr_data       ;
    parameter SIZE_ram = TODO;
    parameter HEAD_lines_buffer = TODO;
    localparam NUM_inputLB = 3+2+DS_data_NUM_in_1_batch;//多少个line_buffer.3+DS_data_NUM_in_1_batch+冗余
    localparam SIZE_line_buffer =W;
    localparam SIZE_lines_buffer = NUM_inputLB*SIZE_line_buffer;//lines_buffer占多少地址（单位：36bit,2个18bit的FixedPoint）
    localparam WIDTH_DRM_addr = $clog2(SIZE_ram);
    reg [WIDTH_DRM_addr-1:0] head_cur_1st_line;
    //ct_line_buffer
    localparam WIDTH_ct_line_buffer = $clog2(NUM_inputLB);
    //input LB管理############################################
    reg [NUM_inputLB-1:0] f_inputLB_vld;
    reg [$clog2(NUM_inputLB)-1:0] num_invalid_inputLB;
    //连接至 ddrScheduler  .以DS_大头######################
    //1.data
    input [WIDTH_ddr_data-1:0] rdDS_data18bit;
    input rdDS_data18bit_vld;
    //2.控制信号
    output rdDS_req;//发起req后，未收到DS_granted前保持拉高
    input rdDS_granted;//仅HIGH 1clk
    //3.Vaddr
    parameter END_rdDS_Vaddr = C*W*H*18;//虚拟末尾地址，head_inputLB>=这个就不再发起新的req
    localparam  WIDTH_rdDS_Vaddr = $clog2(END_rdDS_Vaddr);//Vddr地址线位宽
    output [WIDTH_rdDS_Vaddr-1:0] rdDS_Vaddr;//虚拟起始地址。ddr中的实际地址=分配给本模块的base地址+虚拟地址。由ddrScheduler完成虚拟地址到实际地址的映射
    wire pause_ahead1=almost_ready;





    //#############################
    always @( posedge clk )
    begin
        if (reset)
        begin
            ct<={WIDTH_ct{1'b0}};
        end
        else
        begin
            case (ct)
                0:
                begin
                    if (almost_ready&&TODO)
                    begin
                        ct<=1;
                    end
                end
                NUM_conv_ele:
                begin
                    ct<=0;
                end
                default:
                    ct<=ct+1;
            endcase
        end
    end
    // localparam WIDTH_c=$clog2(C) ;
    // localparam WIDTH_y=$clog2(H) ;
    // localparam WIDTH_x=$clog2(W) ;
    // //c0,y0,x0:feature中卷积中心的位置
    // reg [WIDTH_c-1:0] c0;
    // reg [WIDTH_y-1:0] y0;
    // reg [WIDTH_x-1:0] x0;
    // //y,x:当前计算feature的位置
    // wire [WIDTH_y-1:0] y;
    // wire [WIDTH_x-1:0] x;
    always @(* )
    begin
        if (padding||ct==0)
        begin
            y<=0;
        end
        else
        begin
            y<=(y0-1)+(ct-1)/3;
        end
    end
    always @(* )
    begin
        if (padding||ct==0)
        begin
            x<=0;
        end
        else
        begin
            x<=(x0-1)+(ct-1)%3;
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            c0<={WIDTH_c{1'b0}};
        end
        else
        begin
            if (update_c0)
            begin
                c0<=c0+1;//可能溢出，但无所谓，反正block_finish了
            end
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            y0<={WIDTH_y{1'b0}};
        end
        else
        begin
            if (update_y0)
            begin
                if (y0==H-1)
                begin
                    y0<={WIDTH_y{1'b0}};
                end
                else
                begin
                    y0<=y0+1;
                end
            end
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            x0<={WIDTH_x{1'b0}};
        end
        else
        begin
            if (update_x0)
            begin
                if (x0==W-1)
                begin
                    x0<={WIDTH_x{1'b0}};
                end
                else
                begin
                    x0<=x0+1;
                end
            end
        end
    end
    // wire padding;
    always @( * )
    begin
        if (      (y0==0&&ct>=1&&ct<=3)||(y0==H-1&&ct>=7&&ct<=9)||(x0==0&&ct%3==1)||(x0==W-1&&ct%3==0)   )
        begin
            padding<=1'b1;
        end
        else
        begin
            padding<=1'b0;
        end
    end
    // reg padding_d;
    always @( posedge clk )
    begin
        if (reset)
        begin
            padding_d<=1'b0;
        end
        else
        begin
            padding_d<=padding;
        end
    end
    // wire block_finish;//本block的工作完毕。即：update_整个特征图
    // wire update_c0;
    // wire update_y0;//y0将要update（卷积中心换入新一行(包含进入新一通道)）
    // wire update_x0;
    assign update_x0= MA_finish ;
    assign update_y0=(x0==W-1)&&update_x0;
    assign update_c0=(y0==H-1)&&update_y0;
    assign block_finish=(c0==C-1)&&update_c0;



    //Conv_BN#####################
    // wire     [WIDTH_A-1:0] Ain;
    // wire     [WIDTH_B-1:0] Bin;
    always @(*)
    begin
        if (padding_d)
        begin
            Ain=0;
        end
        else
        begin
            Ain=rd_data;
        end
    end
    always @(*)
    begin
        if (padding_d)
        begin
            rd_addr<=0;//随意
        end
        else
        begin
            rd_addr<=head_cur_1st_line+SIZE_line_buffer*(y-(y0-1))+x;
        end
    end
    //    wire MA_finish;
    // wire almost_ready;//ahead ready,MA_finish 1clk

    Conv_BN #(
                .NUM_conv_ele(NUM_conv_ele),
                .WIDTH_A  ( WIDTH_A  ),
                .WIDTH_B  ( WIDTH_B  ),
                .WIDTH_o  ( WIDTH_o  ),
                .WIDTH_eW ( WIDTH_eW ),
                .WIDTH_eB ( WIDTH_eB ))
            u_Conv_BN (
                .clk                     ( clk                    ),
                .reset                   ( reset                  ),
                .start                   ( start                  ),
                .e_w                     ( e_w     [WIDTH_eW-1:0] ),
                .e_b                     ( e_b     [WIDTH_eB-1:0] ),
                .Ain                     ( Ain     [WIDTH_A-1:0]  ),
                .Bin                     ( Bin     [WIDTH_B-1:0]  ),
                .out                     ( out     [WIDTH_o-1:0]  ),

                .A                       ( A       [WIDTH_A-1:0]  ),
                .B                       ( B       [WIDTH_B-1:0]  ),
                .reload                  ( reload                 ),
                .acc                     ( acc     [WIDTH_o-1:0]  ),
                .finish                  ( MA_finish              ),
                .ready                   ( ready                  ),
                .almost_ready(almost_ready)
            );

    //RAM#########################
    // parameter SIZE_ram = TODO;
    // parameter HEAD_lines_buffer = ;
    // localparam NUM_inputLB = 3+data_NUM_in_1_batch;//多少个line_buffer
    // localparam SIZE_line_buffer =W;
    // localparam SIZE_lines_buffer = NUM_inputLB*SIZE_line_buffer;//lines_buffer占多少地址（单位：36bit,2个18bit的FixedPoint）
    // localparam WIDTH_DRM_addr = $clog2(SIZE_ram);
    // reg [WIDTH_DRM_addr-1:0] head_cur_1st_line;
    // //ct_line_buffer
    // localparam WIDTH_ct_line_buffer = $clog2(NUM_inputLB);
    always @( posedge clk )
    begin
        if (reset)
        begin
            head_cur_1st_line<=HEAD_lines_buffer;
        end
        else
        begin
            if (update_y0)
            begin
                if (head_cur_1st_line==SIZE_line_buffer*3)
                begin
                    head_cur_1st_line<=HEAD_lines_buffer;
                end
                else
                begin
                    head_cur_1st_line=head_cur_1st_line+SIZE_line_buffer;
                end
            end
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            head_cur_1st_line<=HEAD_lines_buffer;
        end
        else
        begin
            if (update_c0)
            begin
                head_cur_1st_line<=HEAD_lines_buffer;
            end
        end
    end
    // wire   DRM_wr_en                 ;
    // wire   [7:0]  DRM_rd_addr           ;
    // wire   [7:0]  DRM_wr_addr           ;
    // wire  [17:0]  DRM_rd_data        ;
    // wire   [17:0]  DRM_wr_data       ;
    DualDRM1 u_DualDRM1 (
                 .wr_data(DRM_wr_data),    // input [35:0]
                 .wr_addr(DRM_wr_addr),    // input [7:0]
                 .wr_en(DRM_wr_en),        // input
                 .wr_clk(clk),      // input
                 .wr_rst(reset),      // input
                 .rd_addr(DRM_rd_addr),    // input [7:0]
                 .rd_data(DRM_rd_data),    // output [35:0]
                 .rd_clk(clk),      // input
                 .rd_rst(reset)       // input
             );
    //写入DRM中的afterDW-------------
    parameter HEAD_afterDW =TODO ;//afterDW区的起始地址
    reg [WIDTH_DRM_addr-1:0] p_wt_afterDW;
    always @( posedge clk )
    begin
        if (reset)
        begin
            p_wt_afterDW<=HEAD_afterDW;
        end
        else
        begin
            if (MA_finish)
            begin
                p_wt_afterDW<=p_wt_afterDW+1;
            end
        end
    end
    always @( * )
    begin
        if (MA_finish || DS_data18bit_vld)
        begin
            DRM_wr_en<=1'b1;
        end
        else
        begin
            DRM_wr_en<=1'b0;
        end
    end
    always @( * )
    begin
        if (MA_finish)
        begin
            DRM_wr_addr<=p_wt_afterDW;
        end
        else
        begin
            if(DS_data18bit_vld)
            begin
                DRM_wr_addr<=p_wt_inputLB;
            end
            else
            begin
                DRM_wr_addr<=0;
            end
        end
    end
    always @( * )
    begin
        if (MA_finish)
        begin
            DRM_wr_data<=out;
        end
        else
        begin
            if(DS_data18bit_vld)
            begin
                DRM_wr_data<=DS_data18bit;
            end
            else
            begin
                DRM_wr_data<=0;
            end
        end
    end

    //MA#########################
    wire  reload;
    Mult_Accumulator_1
        MA
        (
            .a(A),                      // input [17:0]
            .b(B),                      // input [17:0]
            .clk(clk),                  // input
            .rst( reset),                  // input
            .ce(1'b1),                    // input
            .reload(reload),            // input
            .acc_init(acc),            // input
            .p(out)                       // output [95:0]
        );




    //连接至 ddrScheduler  .以DS_大头######################
    always @( posedge clk )
    begin
        if (reset)
        begin
            rdDS_req<=0;
        end
        else
        begin
            if (rdDS_granted||rdDS_data18bit_vld)//||rdDS_data18bit_vld:保险
            begin
                rdDS_req<=0;
            end
            else if(num_invalid_inputLB>=DS_data_NUM_in_1_batch&&rdDS_Vaddr<END_rdDS_Vaddr)
            begin
                rdDS_req<=1;
            end
        end
    end


    //input LB管理############################################
    always @( posedge clk )
    begin
        if (reset)
        begin
            f_inputLB_vld<=0;
        end
        else
        begin

            if (p_wt_inputLB%SIZE_line_buffer==SIZE_line_buffer-1)//TODO:应该&&p_wt_inputLB自增时
            begin
                f_inputLB_vld[p_wt_inputLB/SIZE_line_buffer]<=1;
                num_invalid_inputLB<=num_invalid_inputLB-1;
            end
            if (update_y0)
            begin
                f_inputLB_vld[p_wt_inputLB/SIZE_line_buffer]<=0;
                num_invalid_inputLB<=num_invalid_inputLB+1;
            end
        end
    end




endmodule
