module x_2_PWM (
        clk,reset,en_us,x,PWMsteering,
        new_high_us,ct_us
    );
    parameter UPDATE_INTERVAL_in_us =20_000 ;
    parameter W = 1024;
    parameter xGoal = W/2;
    parameter THRESHOLD = 2;
    parameter INITIAL_degree = 90;
    parameter MAX_alpha = 180;
    parameter MIN_alpha = 0;
    localparam FILTER_FACTOR = W/8;//调参
    localparam FACTOR = 2000/180/10;//调参
    localparam   MAX_high_us = 500+2000*MAX_alpha/180;
    localparam   MIN_high_us = 500+2000*MIN_alpha/180;

    localparam INITIAL_high_us = 500+2000*INITIAL_degree/180;
    localparam WIDTH_ct_us = $clog2(UPDATE_INTERVAL_in_us);










      reg [WIDTH_ct_us-1:0] high_us=INITIAL_high_us;












    localparam WIDTH_x = 11;
    input clk;
    input reset;
    input en_us;
    input [WIDTH_x-1:0]x;
    reg [WIDTH_x-1:0]old_x=xGoal;
    // 占空比=500/20000+(2000/20000)*alpha/180
    output reg PWMsteering=1;
   output reg [WIDTH_ct_us-1:0] ct_us=0;//过了多少us
    // reg [WIDTH_ct_us-1:0] high_us;//HIGH 保持多少us
      output reg   [WIDTH_ct_us-1:0] new_high_us=INITIAL_high_us;

    always @( posedge clk )
    begin
        if (reset)
        begin
            old_x<=xGoal;
        end
        else
        begin
            if (ct_us==UPDATE_INTERVAL_in_us-1)
            begin
                old_x<=x;
            end
        end
    end
    //x  ->new_high_us->   high_us
    always @( posedge clk )
    begin
        if (reset)
        begin
            high_us<=INITIAL_high_us;
            new_high_us<=INITIAL_high_us;
        end
        else
        begin
            //new_high 2 high
            if (new_high_us<MIN_high_us)
            begin
                high_us<=MIN_high_us;
            end
            else if (new_high_us>MAX_high_us)
            begin
                high_us<=MAX_high_us;
            end
            else
            begin
                high_us<=new_high_us;
            end
            //x 2 new
            if (ct_us==UPDATE_INTERVAL_in_us-1)
            begin
                if ((old_x<=x&&(x-old_x)<=FILTER_FACTOR)  ||   ( old_x>x&&(old_x-x)<=FILTER_FACTOR))
                begin
                    // new_high_us<=   high_us+x/1800-xGoal/1800;
                    new_high_us<=   high_us+    x+(x>>3)-xGoal-(xGoal>>3);
                end
            end
        end
    end
    //ct_us,high_us 2 PWM
    always @( posedge clk )
    begin
        if (reset)
        begin
            PWMsteering<=1'b0;
        end
        else
        begin
            if (ct_us<high_us)
            begin
                PWMsteering<=1'b1;

            end
            else
            begin
                PWMsteering<=1'b0;

            end
        end
    end

    //en_us 2 ct_us
    always @( posedge clk )
    begin
        if (reset)
        begin
            ct_us<={WIDTH_ct_us{1'b0}};
        end
        else
        begin
            if (en_us)
            begin
                if (ct_us==UPDATE_INTERVAL_in_us-1)
                begin
                    ct_us<={WIDTH_ct_us{1'b0}};
                end
                else
                begin
                    ct_us<=ct_us+1;
                end
            end
        end
    end







endmodule

