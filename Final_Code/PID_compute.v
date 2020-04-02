module PID_compute(
    input clk, //clk_100MHZ
    input rst,
    input [6-1:0]distance,
//    input [15:0] sw,
    output PWM,
//    output reg [9-1:0]PID_total_mapped,
    ///For seven segment.
    output  [3:0]an,
    output  [6:0]seg,
    output [3:0]LED, // 0-10, 10-20, 20-30, 30+.
    output dp    
);                 

wire clk_20Hz,display_clk, rst_one_pulse,rst_debounced;
clock_divider c20( .clk_in(clk), .divisor(5000000), .clk_out(clk_20Hz));
clock_divider c7( .clk_in(clk), .divisor(2**15), .clk_out(display_clk));

debounce  d0(rst, clk, rst_debounced);
one_pulse op(rst_debounced, clk, rst_one_pulse);
wire [9-1:0]PID_to_duty ; 
SevenSegment s7(.clk(display_clk), .dis(PID_to_duty), .an(an), .seg(seg), .dp(dp));

assign LED[0] = (distance <= 6'd10) ? 1'b1 : 1'b0;
assign LED[1] = (distance >6'd10 && distance <= 6'd25) ? 1'b1 : 1'b0;
assign LED[2] = (distance >6'd25 && distance <= 6'd40) ? 1'b1 : 1'b0;
assign LED[3] = (distance >6'd45) ? 1'b1 : 1'b0;

//Control Parameters.
parameter kp = 8;
parameter ki = 0.2;  //0.2
parameter kd = 2000;
parameter SetPoint = 35;

//For sample count. //Sample period 50ms
reg [36:0]count;
wire [36:0]next_count;
reg [19:0] PID_i, PID_d, PID_p,PID_total;
reg [19:0] next_PID_i, next_PID_d, next_PID_p ,next_PID_total;

//20bit.
reg [19:0]err_difference;
reg [19:0]error;
reg [19:0]last_error, next_last_error;

//Sequential : Update parameters every sample period (50ms)
always@(posedge clk_20Hz)begin
    if(rst_one_pulse)begin
        err_difference <= 20'd0;
        error <= 20'd0;
        last_error <= 20'd0;
        PID_i <= 20'd0;
        PID_p <= 20'd0;
        PID_d <= 20'd0;
        PID_total <= 20'd0;
    end
    else begin
        err_difference <= error - last_error; //error difference.
        error <= SetPoint - distance;
        last_error <= next_last_error;
        PID_i <= next_PID_i; 
        PID_p <= next_PID_p;
        PID_d <= next_PID_d;
        PID_total <= next_PID_total;      
    end
end
//Combinational
always@(*)begin
                next_PID_p = kp * error;
                next_PID_d = kd * (err_difference/period);                
                if( -8<error  &&  error < 8)begin
                    next_PID_i = PID_i + (ki * error);
                end
                else next_PID_i = 0;       
        next_last_error = last_error;      
        if( -2 <= error && error >= 2)
                  next_PID_total = 30; //Let servo motor to zero degree.
        else 
         next_PID_total = next_PID_p + next_PID_d + next_PID_i ;  
end

//For sample period  50ms 
always@(posedge clk)begin
    if(rst) count <= 37'd0;
    else count <= next_count;
end
assign next_count = (count ==  37'd50000000 )? 37'd0 : count + 37'd1;

//From -400 +200  to  duty cycle 26- 126 
assign PID_to_duty = (PID_total + 426)/6 ;

/////////////Control Servo Motor.//////////////////
 //PID should be mapped to 'duty cycle' (26-128) to write servo motor.
parameter freq = 32'd50; //50HZ.
PWM PWM_for_servo(
    .clk(clk),
    .reset(rst_one_pulse),
	.freq(freq),
    .duty(PID_to_duty),
    .PWM(PWM)
);

endmodule


module debounce(pb, clk, pb_debounced);
input pb, clk;
output pb_debounced;

reg [3:0]DFF;

always@(posedge clk)begin
    DFF[3:1] <= DFF[2:0];
    DFF[0] <= pb;
end

assign pb_debounced = (DFF == 4'b1111)? 1'b1 : 1'b0;
endmodule

module one_pulse(pb_debounced, clk, pb_one_pulse);
input pb_debounced, clk;
output reg pb_one_pulse;

reg pb_debounced_delay;

always@(posedge clk)begin
    pb_debounced_delay <= pb_debounced;
    pb_one_pulse <= (!pb_debounced_delay) & pb_debounced;
end
endmodule

module SevenSegment(dis,seg,an,clk,dp);
input [9-1:0]dis; //Distance. 7 bit.
input clk;
output reg [6:0]seg;
output reg[3:0]an;
output reg dp;

    always@(posedge clk)begin
        case(an)
        4'b1110:begin //next : 0111. ?��位數
            case(dis/1000)
            20'd0: seg <= 7'b1000000;
            20'd1: seg <= 7'b1111001;
            20'd2: seg <= 7'b0100100;
            20'd3: seg <= 7'b0110000;
            20'd4: seg <= 7'b0011001;
            20'd5: seg <= 7'b0010010;                       
            20'd6: seg <= 7'b0000010;
            20'd7: seg <= 7'b1111000;
            20'd8: seg <= 7'b0000000;
            20'd9: seg <= 7'b0010010;
            endcase
            an <= 4'b0111;
            dp <= 1'b1;             
        end
        4'b0111:begin
            case(dis/100)
            20'd0: seg <= 7'b1000000;
            20'd1: seg <= 7'b1111001;
            20'd2: seg <= 7'b0100100;
            20'd3: seg <= 7'b0110000;
            20'd4: seg <= 7'b0011001;
            20'd5: seg <= 7'b0010010;                       
            20'd6: seg <= 7'b0000010;
            20'd7: seg <= 7'b1111000;
            20'd8: seg <= 7'b0000000;
            20'd9: seg <= 7'b0010010;
            endcase
            an <= 4'b1011; 
            dp <= 1'b1; 
        end
        4'b1011:begin
            case((dis/10)%10)
            20'd0: seg <= 7'b1000000;
            20'd1: seg <= 7'b1111001;
            20'd2: seg <= 7'b0100100;
            20'd3: seg <= 7'b0110000;
            20'd4: seg <= 7'b0011001;
            20'd5: seg <= 7'b0010010;                       
            20'd6: seg <= 7'b0000010;
            20'd7: seg <= 7'b1111000;
            20'd8: seg <= 7'b0000000;
            20'd9: seg <= 7'b0010010;
            endcase
            an <= 4'b1101;   
            dp <= 1'b1; 
         end          
        4'b1101:begin
            case(dis%10)
            20'd0: seg <= 7'b1000000;
            20'd1: seg <= 7'b1111001;
            20'd2: seg <= 7'b0100100;
            20'd3: seg <= 7'b0110000;
            20'd4: seg <= 7'b0011001;
            20'd5: seg <= 7'b0010010;                       
            20'd6: seg <= 7'b0000010;
            20'd7: seg <= 7'b1111000;
            20'd8: seg <= 7'b0000000;
            20'd9: seg <= 7'b0010010;
            endcase
            an <= 4'b1110;
            dp <= 1'b1;             
        end
        default : begin
            an <= 4'b0111;
            dp <= 1'b1;
         end
        endcase
    end
            
endmodule

module clock_divider ( clk_in, divisor, clk_out);
input clk_in;
input [32-1:0] divisor;
output clk_out;

reg clk_out;
reg next_clk_out;
reg[32-1:0] cnt;
wire[32-1:0] next_cnt;
	
always@(posedge clk_in)begin
    cnt <= next_cnt;
    clk_out <= next_clk_out;
end
always@(*)begin
    if(cnt < divisor/2)begin //if count to the divisor number, reset the counter.
        next_clk_out = 1'b1;
    end
    else begin
        next_clk_out = 1'b0;
     end
end       
    assign next_cnt = (cnt == divisor) ? 32'd0 : cnt + 32'd1;
 endmodule