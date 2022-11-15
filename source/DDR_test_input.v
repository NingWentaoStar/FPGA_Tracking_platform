module DDR_test_input
#(
    parameter MEM_DATA_BITS          = 64,
    parameter READ_DATA_BITS         = 16,
    parameter WRITE_DATA_BITS        = 16,
    parameter ADDR_BITS              = 25,
    parameter BUSRT_BITS             = 10,
    parameter BURST_SIZE             = 64
)   
(
    input                                     clk,
    input                                     rst,


    output reg                                wr_start,
    output reg[ADDR_BITS - 1:0]               wr_addr,
    output reg[ADDR_BITS - 1:0]               wr_len,
    input                                     wr_en,
    output reg[WRITE_DATA_BITS - 1:0]         wr_data,
    input                                     wr_finish,


    output reg                                rd_start,
    output reg[ADDR_BITS - 1:0]               rd_addr,
    output reg[ADDR_BITS - 1:0]               rd_len,
    input                                     rd_en,
    input[WRITE_DATA_BITS - 1:0]              rd_data,
    input                                     rd_finish,

    output reg[WRITE_DATA_BITS - 1:0]         received_data
);
parameter  WR_RD_LEN = 25'd4096;

//循环读写计数器
reg[ADDR_BITS - 1:0]   wr_addr_0 = 25'd0;
reg[ADDR_BITS - 1:0]   wr_addr_1 = 25'd100_000;
reg[ADDR_BITS - 1:0]   wr_addr_2 = 25'd200_000;
reg[ADDR_BITS - 1:0]   wr_addr_3 = 25'd300_000;
reg[1:0]               wr_addr_index = 2'd0;               


reg   [49:0]loop_cnt = 0;
always@(posedge clk)
begin
    if(rst)begin
        wr_start <= 0;
        loop_cnt <= 50'd0;
    end
    else if(loop_cnt == 50'd200_000_000)begin
        loop_cnt <= 50'd0;
        wr_start <= 1;
    end
    else if(loop_cnt == 50'd150_000_000)begin
        wr_start <= 0;
        loop_cnt <= loop_cnt + 50'd1;
    end
    else  
        loop_cnt <= loop_cnt + 50'd1;
end

always@(posedge clk)
begin
    if(rst)begin
        //wr_start <= 0;
        wr_addr <= 25'd0;
        wr_len <= 25'd0;
        wr_data <= 16'd0;
    end
    else if(loop_cnt == 50'd200_000_000)begin
        //wr_start <= 1;
        case(wr_addr_index)
            2'd0:   wr_addr <= wr_addr_0;
            2'd1:   wr_addr <= wr_addr_1;
            2'd2:   wr_addr <= wr_addr_2;
            2'd3:   wr_addr <= wr_addr_3;
        endcase
        wr_addr_index <= wr_addr_index + 2'd1; 
        wr_len <= WR_RD_LEN;
        wr_data <= 16'd1;
    end
    else if(wr_finish)begin
        //wr_start <= 0;
        wr_addr <= 25'd0;
        wr_len <= 25'd0;
        wr_data <= 16'd0;
    end
    else if(wr_en)begin
        wr_data <= wr_data + 16'd1;
    end
end



always@(posedge clk)
begin
    if(rst)begin
        rd_start <= 0;
        rd_addr <= 25'd0;
        rd_len <= 25'd0;
    end
    else if(loop_cnt == 50'd200_000_000)begin
        rd_start <= 1;
        case(wr_addr_index - 2'd1)
            2'd0:   rd_addr <= wr_addr_0;
            2'd1:   rd_addr <= wr_addr_1;
            2'd2:   rd_addr <= wr_addr_2;
            2'd3:   rd_addr <= wr_addr_3;
        endcase
        rd_len <= WR_RD_LEN;
    end
    else if(rd_finish)begin
        rd_start <= 0;
        rd_addr <= 25'd0;
        rd_len  <= 25'd0;
        received_data <= 16'd0;
    end
    else if(rd_en)
        received_data <= rd_data;

end



endmodule