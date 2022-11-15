// `include "clk_counter.v"
// clk_counter  //每计满num_clk_in_1_interval个，en就维持1个clk时长的高电平 
// #(
//     .num_clk_in_1_interval(1000)
// )clk_counter_u   
// (
//     .clk(clk),
//     .reset_asyn(yours) ,
//     .en(yours)
// );
module clk_counter 
#(parameter num_clk_in_1_interval = 1000,
WIDTH_num_clk_in_1_interval = $clog2(num_clk_in_1_interval)
)
(input clk,
input reset_asyn,
output reg en);
    reg [WIDTH_num_clk_in_1_interval-1:0] ct_clk;
    
    always @(posedge clk ) begin
        if (reset_asyn) begin
            ct_clk <= {WIDTH_num_clk_in_1_interval{1'b0}};//or just 1'b0 (padding rule)
        end
        else
        begin
            if (ct_clk == num_clk_in_1_interval-1) begin
                ct_clk <= 1'd0;//padding rule
                
            end
            else
            begin
                ct_clk <= ct_clk+1;
            end
        end
    end
    
    
    always @(posedge clk ) begin
        if (reset_asyn) begin
            en <= 1'b0;
        end
        else
        begin
            if (ct_clk == num_clk_in_1_interval-1) begin
                en <= 1'b1;
                
            end
            else
            begin
                en <= 1'b0;
                
            end
        end
    end
endmodule
