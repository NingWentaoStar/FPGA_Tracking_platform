


module Conv_BN(
        clk,reset,start,e_w,e_b,Ain,Bin,out,A,B,reload,acc,finish,ready,almost_ready
    );


    //parameter##############################
    parameter NUM_conv_ele = 9;
    parameter WIDTH_A =18 ;
    parameter WIDTH_B =18 ;
    parameter WIDTH_o =96 ;
    parameter WIDTH_eW =18 ;
    parameter WIDTH_eB =18 ;
    //inout##############################
    input clk,reset/* synthesis syn_keep=1 */;
    input   start/* synthesis syn_keep=1 */;
    input  [WIDTH_eW-1:0]  e_w/* synthesis syn_keep=1 */;
    input  [WIDTH_eB-1:0]  e_b/* synthesis syn_keep=1 */;
    input     [WIDTH_A-1:0] Ain/* synthesis syn_keep=1 */;
    input     [WIDTH_B-1:0] Bin/* synthesis syn_keep=1 */;
    //连接到MA##############################
    input [WIDTH_o-1:0] out/* synthesis syn_keep=1 */;//即MA的p。是本模块的核心输出数据(虽然被声明为input)
    output reg   [WIDTH_A-1:0] A/* synthesis syn_preserve = 1 */;
    output reg   [WIDTH_B-1:0] B/* synthesis syn_preserve = 1 */;
    output reg reload/* synthesis syn_preserve = 1 */;
    output reg    [WIDTH_o-1:0] acc/* synthesis syn_preserve = 1 */;//acc_init
    //END连接到MA##############################
    output reg finish/* synthesis syn_preserve = 1 */;
    output wire ready;
    output wire almost_ready;
    //localparam##############################
    localparam WIDTH_ct = $clog2(NUM_conv_ele+2);
    localparam IDLE = {WIDTH_ct{1'b0}};
    //reg##############################
    reg ready_reg/* synthesis syn_preserve = 1 */;
    reg [WIDTH_ct-1:0]  ct/* synthesis syn_preserve = 1 */;
    reg [WIDTH_eW-1:0]  reg_e_w/* synthesis syn_preserve = 1 */;
    reg  [WIDTH_eB-1:0] reg_e_b/* synthesis syn_preserve = 1 */;
    reg  [WIDTH_o-1:0] reg_out/* synthesis syn_preserve = 1 */;
    //assign##############################
    assign ready=start?0:ready_reg;
    assign almost_ready=(ct==NUM_conv_ele+2)?1'b1:1'b0;
    //always##############################
    always @( posedge clk )
    begin
        if (reset)
        begin
            finish<=1'b0;
        end
        else
        begin
            if (ct==NUM_conv_ele+2)
            begin
                finish<=1'b1;
            end
            else
            begin
                finish<=1'b0;
            end
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            ct<=IDLE;
        end
        else
        begin
            case (ct        )
                IDLE:
                begin
                    ct<=start?'d2:IDLE;
                end
                NUM_conv_ele+2:
                begin
                    ct<= IDLE;
                end
                default:
                    ct<=ct+1;
            endcase
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            reload<=1'b0;
        end
        else
        begin
            if (ct==NUM_conv_ele ||  ct==NUM_conv_ele+2)
            begin
                reload<=1'b1;
            end
            else
            begin
                reload<=1'b0;
            end
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            acc<={WIDTH_o{1'b0}};
        end
        else
        begin
            if (ct==NUM_conv_ele)
            begin
                acc<=reg_e_b;
            end
            else
            begin
                acc<={WIDTH_o{1'b0}};
            end
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            reg_out<={WIDTH_o{1'b0}};
        end
        else
        begin
            reg_out<=out;
        end
    end
    always @(* )
    begin

        case (ct        )
            IDLE:
            begin
                if (start)
                begin
                    A=Ain;
                    B=Bin;
                end
                else
                begin
                    A=0;
                    B=0;
                end
            end
            NUM_conv_ele+2:
            begin
                A=reg_out;
                B=reg_e_w;
            end
            NUM_conv_ele+1:
            begin
                A=0;
                B=0;
            end
            default:
            begin
                A=Ain;
                B=Bin;
            end
        endcase
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            reg_e_w<={WIDTH_eW{1'b0}};
            reg_e_b<={WIDTH_eB{1'b0}};
        end
        else
        begin
            if (ct==IDLE&&start==1'b1)
            begin
                reg_e_w<=e_w;
                reg_e_b<=e_b;
            end
        end
    end
    always @( posedge clk )
    begin
        if (reset)
        begin
            ready_reg<=1'b1;
        end
        else
        begin
            if (ct==NUM_conv_ele+2)
            begin
                ready_reg<=1'b1;
            end
            else if (start)
            begin
                ready_reg<=1'b0;
            end
            else
            begin
                ready_reg<=ready_reg;
            end
        end
    end
endmodule
