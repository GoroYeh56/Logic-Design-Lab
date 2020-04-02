module echo(clk,rst,echo,distance);
input clk, rst, echo; // 1MHZ, 1micro sec.
output [19:0]distance; //wire

parameter IDLE = 2'b00;
parameter START_COUNT = 2'b01;
parameter FINISH_COUNT = 2'b10;

reg now_echo, last_echo;
reg [20-1:0] count ,next_count; //counter to record time and transform to distance.
reg [20-1:0] measure_time, next_measure_time;
reg [1:0] state, next_state;

always@(posedge clk)begin
    if(rst)begin
        state <= IDLE;
        now_echo <= 1'b0;
        last_echo <= 1'b0;
        count <= 20'd0;
        measure_time <= 20'd0;
    end
    else begin
        state <= next_state;
        now_echo <= echo; //input.
        last_echo <= now_echo;
        count <= next_count;
        measure_time <= next_measure_time;
    end 
end

always@(*)begin
    case(state)
    IDLE:begin
        if(now_echo == 1'b1 && last_echo == 1'b0)begin
            next_state = START_COUNT;
            next_count = 1'b1;
        end
        else begin
            next_state = state;
            next_count = count;
        end
        next_measure_time = measure_time;
    end
    START_COUNT:begin
        if(now_echo == 1'b0 && last_echo == 1'b1)begin
            next_state = FINISH_COUNT;
            next_count = count;
        end
        else begin
            next_state = state;
            next_count = count + 20'd1;
        end
        next_measure_time = measure_time;
    end
    FINISH_COUNT:begin
        next_state = IDLE;
        next_count = 20'd0; //reset counter.
        next_measure_time = count; //update.  
    end
    default:begin
        next_state = state;
        next_count = count;
        next_measure_time = measure_time;
    end
    endcase
end

assign distance = (measure_time) / 58 ; //??�到小數第�?��??
        //cm * 100 => include two digits cm. (0.01cm)

endmodule