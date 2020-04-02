//This .v file is to handle the Servo motor task.
//SG90 datasheet: 50 HZ 
    //  Power:4.8-5 V.
/*
    0 degree : 1.5ms pulse.
    +90(Right): 2 ms
    -90(Left): -1 ms
*/

//1/50 = 0.02s = 20ms. so 2 ms means 2/20 = 1/10 duty cycle (10%)

module Servo(
    input wire clk,
    input wire reset,
    input [10-1:0]SW,
	input PWM,
    output turn //connect to signal.
);

parameter IDLE = 1'b0;
parameter MOVING = 1'b1;
reg state, next_state;
 reg has_moved=1'b0;
 reg next_has_moved;
always@(posedge clk)begin
    if(reset)begin
        state <= IDLE;
         has_moved <= 1'b0;
    end
    else begin 
        state <= next_state; 
         has_moved <= next_has_moved;
     end
end

always@(*)begin
//    if(SW != last_SW)begin
    case(state)
    IDLE: begin
        if(PWM)begin
            next_state = MOVING;
             next_has_moved = 1'b1;
        end
        else begin
            next_state = IDLE;
             next_has_moved = 1'b0;
        end
    end
    MOVING:begin
        if(has_moved== 1'b1)begin
            next_state = IDLE;
             next_has_moved = 1'b0;
        end
        else begin
            next_state = state;
             next_has_moved = has_moved;
        end
    end
    endcase
end

assign turn = (state==MOVING) ? PWM : 1'b0;

endmodule