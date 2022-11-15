module	DDR3_operation
#(
	parameter MEM_DATA_BITS          = 64,
	parameter READ_DATA_BITS         = 16,
	parameter WRITE_DATA_BITS        = 16,
	parameter ADDR_BITS              = 25,
	parameter BUSRT_BITS             = 10,
	parameter BURST_SIZE             = 64
)    
(
	input			rst,
	input			clk,
    

    input                               wr_start,
    input[ADDR_BITS - 1:0]              wr_addr,
    input[ADDR_BITS - 1:0]              wr_len,
    output                              wr_en,
    input[WRITE_DATA_BITS - 1:0]        wr_data,
    output                              wr_finish,


    input                               rd_start,
    input[ADDR_BITS - 1:0]              rd_addr,
    input[ADDR_BITS - 1:0]              rd_len,
    output                              rd_en,
    output[WRITE_DATA_BITS - 1:0]       rd_data,
    output                              rd_finish,



    //write channel control flow
	output reg				        	user_write_req,
	input						    	user_write_req_ack,
	input						    	user_write_finish,
	output [ADDR_BITS - 1:0]	    	user_write_addr,
	output [ADDR_BITS - 1:0]	    	user_write_len,
	output reg						    user_write_en,
	output [WRITE_DATA_BITS - 1:0]  	user_write_data,

    //read channel control flow
	output reg							user_read_req,
	input						    	user_read_req_ack,
	input						    	user_read_finish,
	output [ADDR_BITS - 1:0]			user_read_addr,
	output [ADDR_BITS - 1:0]			user_read_len,
	output reg					    	user_read_en,
	input[READ_DATA_BITS  - 1:0]    	user_read_data,
	input								user_read_empty,


    input[ADDR_BITS - 1:0]              last_wr_addr,
    input[ADDR_BITS - 1:0]              last_rd_addr,

    output[15:0]                        cnt_monitor

);
assign          wr_en       = user_write_en;
assign          wr_finish   = user_write_finish;
assign          rd_en       = user_read_en_d1;
assign          rd_data     = user_read_data;
assign          rd_finish   = user_read_finish;



//外部的写地址、写长度、写数据 调度输入
assign          user_write_addr = wr_addr;
assign          user_write_len = wr_len;
assign          user_write_data = wr_data;

//外部的读地址、读长度 调度输入
assign          user_read_addr = rd_addr;
assign          user_read_len  = rd_len;

/*------------------------------写控制系列------------------------------*/
//写请求控制
reg         wr_start_d1 = 0;
always@(posedge clk)
begin
    wr_start_d1 <= wr_start;
    if(rst)
        user_write_req <= 0;
    else if((~wr_start_d1) && wr_start )begin//检测用户写请求的上升沿
        user_write_req <= 1;
    end
    else if(user_write_req_ack)
        user_write_req <= 0;
end


//写使能、写数据控制
reg             user_write_req_ack_d1;
reg             user_write_req_ack_d2;
reg [15:0]      cnt = 16'd0;
assign    cnt_monitor = cnt;
always@(posedge clk)
begin
    user_write_req_ack_d1 <= user_write_req_ack;
    user_write_req_ack_d2 <= user_write_req_ack_d1;
    if(rst)begin
        cnt <= 16'd0;
        user_write_en <= 0;
        //user_write_data <= 16'd0;
    end
    else if((user_write_req_ack_d2) && (~user_write_req_ack_d1) )begin
        cnt <= 16'd0;
        user_write_en <= 1;
        //user_write_data <= wr_data;
    end
    else if(cnt == wr_len/16-1)begin
        user_write_en <= 0;
        cnt  <= 16'd0;
        //user_write_data <= 16'd0
    end
    else if(user_write_en)begin
        cnt <= cnt + 16'd1;
        //user_write_data <= wr_data;
    end
end







/*------------------------------读控制系列------------------------------*/
//读请求控制
reg         rd_start_d1 = 0;
always@(posedge clk)
begin
    rd_start_d1 <= rd_start;
    if(rst)
        user_read_req <= 0;
    else if(~(rd_start_d1) && rd_start )
        user_read_req <= 1;
    else if(user_read_req_ack)
        user_read_req <= 0;
end

//读使能控制
reg  user_read_en_d1;
always@(posedge clk)
begin
    user_read_en_d1 <= user_read_en;
    if(rst)
        user_read_en <= 0;
    else if(user_read_finish)
        user_read_en <= 1;
    else if(user_read_empty)
        user_read_en <= 0;
end





// parameter     WR_RD_LEN = 25'd8192;
// //test words



// //Loop write and read
// reg  [50:0] loop_cnt;
// reg         test_write_req =0;
// always@(posedge clk)begin
//     if(rst)begin
//         loop_cnt <= 51'd0;
//         test_write_req <= 0;
//     end
//     else if(loop_cnt == 51'd250_000_000)begin
//         loop_cnt <= 51'd0;
//         test_write_req <= 1;
//     end
//     else begin
//         loop_cnt <= loop_cnt + 51'd1;
//         test_write_req <= 0;

//     end
// end
// // always@(posedge clk)begin
// //     if(rst)begin
// //         test_write_req <= 0;
// //     end
// //     else if(loop_cnt == 11'd500)begin
// //         test_write_req <= 1; 
// //     end
// //     else if(user_write_req)
// //         test_write_req <= 0; 
// //     else if(user_write_finish)

// // end



// reg    user_write_req_ack_d0;
// reg [15:0]    cnt = 16'd0;
// always@(posedge clk)begin
//     user_write_req_ack_d0 <= user_write_req_ack;
//     if(rst)begin
//         cnt <= 16'd0;
//         user_write_en <= 0;
//         user_write_data <= 16'd0;
//     end
//     else if((~write_req_d1) &&write_req_d0)begin
//         cnt <= 16'd0;
//         user_write_data <= cnt;
//     end
//     else if((user_write_req_ack_d0)&&(~user_write_req_ack))begin
//         user_write_en <= 1;
//         cnt <= cnt + 16'd1;
//         user_write_data <= cnt;
//     end
//     else if(cnt == WR_RD_LEN/16)begin
//         user_write_en <= 0;
//         cnt <= 16'd0;
//     end
//     else if(user_write_en)begin
//         cnt <= cnt + 16'd1;
//         user_write_data <= cnt;
//     end
// end




// reg write_req_d0;
// reg write_req_d1;
// always@(posedge clk)begin
//     write_req_d0 <= test_write_req;
//     write_req_d1 <= write_req_d0;
//     if(rst)begin
//         user_write_req <= 0;
//     end
//     else if((~write_req_d1) &&write_req_d0)
//         user_write_req <= 1;
//     else if(user_write_req_ack)
//         user_write_req <= 0;
// end



// parameter     user_write_addr_0 = 25'd8_500_000;
// parameter     user_write_addr_1 = 25'd8_600_000;
// parameter     user_write_addr_2 = 25'd8_700_000;
// parameter     user_write_addr_3 = 25'd8_800_000;
// reg [1:0]     user_write_addr_index = 2'd0;
// always@(posedge clk)begin
//     if(rst)begin
//         user_write_addr_index <= 2'd0;
//         user_write_addr       <= 25'd0;
//         user_write_len        <= 25'd0;
//     end
//     else if((~write_req_d1) &&write_req_d0)begin
//         user_write_addr_index <= user_write_addr_index + 2'd1;
//         user_write_len <= WR_RD_LEN;
//         case(user_write_addr_index)
//             2'd0:    user_write_addr <= user_write_addr_0;
//             2'd1:    user_write_addr <= user_write_addr_1;
//             2'd2:    user_write_addr <= user_write_addr_2;
//             2'd3:    user_write_addr <= user_write_addr_3;
//             default: user_write_addr <= user_write_addr_0;
//         endcase
//     end
//     else if(user_write_finish)begin
//         user_write_addr_index <= 2'd0;
//         user_write_addr       <= 25'd0;
//         user_write_len        <= 25'd0;
//     end
// end






// //read control
// always@(posedge clk)begin
//     if(rst)begin
//         user_read_req <= 0;
//         user_read_addr <= 25'd0;
//         user_read_len  <= 25'd0;
//     end
//     else if(user_write_finish)begin
//         user_read_req <= 1;
//         user_read_len <= WR_RD_LEN;
//         case(user_write_addr_index - 2'd1)
//             2'd0:    user_read_addr <= user_write_addr_0;
//             2'd1:    user_read_addr <= user_write_addr_1;
//             2'd2:    user_read_addr <= user_write_addr_2;
//             2'd3:    user_read_addr <= user_write_addr_3;
//             default: user_read_addr <= user_write_addr_0;
//         endcase
//     end
//     else if(user_read_req_ack)
//         user_read_req <= 0;
//     else if(user_read_finish)begin
//         user_read_len  <= 25'd0;
//     end
// end


// always@(posedge clk)begin
//     if(rst)begin
//         user_read_en <= 0;
//     end
//     else if(user_read_finish)begin
//         user_read_en <= 1;
//     end
//     else if(user_read_empty)begin
//         user_read_en <= 0;
//     end
// end

endmodule