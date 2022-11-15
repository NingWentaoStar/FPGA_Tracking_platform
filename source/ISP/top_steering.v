// `include "clk_counter.v"
// `include "x_2_PWM.v"

module top_steering (
        clk,reset,x,y,PWMsteering1,PWMsteering2,
x_high_us,y_high_us,x_ct_us,y_ct_us


    );


        output [14:0]x_high_us;
        output [14:0]y_high_us;
        
        output [14:0]x_ct_us;
        output [14:0]y_ct_us;


parameter CLK_DIVIDOR = 1000/20;//1us/20ns
    // x_2_PWM Parameters
    parameter UPDATE_INTERVAL_in_us  = 20_000;
    parameter W                      = 1024   ;
    parameter H                      = 768    ;
    parameter xGoal                  = W/2   ;
    parameter yGoal                  = H/2   ;
    parameter THRESHOLD              = 2     ;
    parameter INITIAL_degree1         = 90    ;
    parameter INITIAL_degree2         = 90    ;
    parameter MAX_alpha = 180;
    parameter MIN_alpha = 0;
    localparam WIDTH_x =11;
    localparam WIDTH_y =11;

    // x_2_PWM Inputs
    input   clk                                  ;
    input   reset                                ;
    input     [WIDTH_x-1:0]  x                     ;
    input   [WIDTH_y-1:0]  y                     ;
    output wire PWMsteering1;
    output wire PWMsteering2;
    // x_2_PWM Outputs


    wire   en_us                                ;



    //clk 2 en_us

    clk_counter  //每计满num_clk_in_1_interval个，en就维持1个clk时长的高电平
                 #(
                      .num_clk_in_1_interval(CLK_DIVIDOR)//1us/20ns
                   
                 )
                 clk_counter_u
                 (
                     .clk(clk),
                     .reset_asyn(reset) ,
                     .en(en_us)
                 );






    x_2_PWM #(
                .UPDATE_INTERVAL_in_us ( UPDATE_INTERVAL_in_us ),
                .W                     ( W                     ),
                .xGoal                 ( xGoal                 ),
                .THRESHOLD             ( THRESHOLD             ),
                .INITIAL_degree        ( INITIAL_degree1        ),
                .MAX_alpha           ( MAX_alpha           ),
                .MIN_alpha           ( MIN_alpha           )
            )
            u_x_2_PWM (
                .clk                     ( clk                        ),
                .reset                   ( reset                      ),
                .en_us                   ( en_us                      ),
                .x                       ( x            [WIDTH_x-1:0] ),

                .PWMsteering             ( PWMsteering1                ),
                .new_high_us                 (x_high_us),
                .ct_us                   (x_ct_us)
            );

    x_2_PWM #(
                .UPDATE_INTERVAL_in_us ( UPDATE_INTERVAL_in_us ),
                .W                     ( H                     ),
                .xGoal                 ( yGoal                 ),
                .THRESHOLD             ( THRESHOLD             ),
                .INITIAL_degree        ( INITIAL_degree2        ),
                .MAX_alpha           ( MAX_alpha           ),
                .MIN_alpha           ( MIN_alpha           ))
            u_y_2_PWM (
                .clk                     ( clk                        ),
                .reset                   ( reset                      ),
                .en_us                   ( en_us                      ),
                .x                       ( y            [WIDTH_y-1:0] ),

                .PWMsteering             ( PWMsteering2                ),
                .new_high_us                 (y_high_us),
                .ct_us                   (y_ct_us)
            );
endmodule
