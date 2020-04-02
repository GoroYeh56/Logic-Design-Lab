module Top_Servo(
    input wire clk,
    input wire reset, // C btn.
	input [9:0]SW,
    output turn,
    output [6:0]seven_seg,
    output[3:0]AN
);
//Only SW2, SW3,SW5,SW6  works.

parameter freq = 32'd50; //50HZ.
wire rst_debounced, rst_one_pulse;
wire /*clk_50HZ, */clk_display;
debounce  d0(.pb(reset), .clk(clk), .pb_debounced(rst_debounced));
one_pulse op(.pb_debounced(rst_debounced), .clk(clk), .pb_one_pulse(rst_one_pulse));
//clk_divider cd(.clk(clk), .divisor(2000000), .clk_o(clk_50HZ));
clk_divider cd2(.clk(clk), .divisor(2**15), .clk_o(clk_display));

PWM PWM_for_servo(
    .clk(clk),
    .reset(rst_one_pulse),
	.freq(freq),
    .duty(SW),
    .PWM(turn)
);

//Use PWM signal to control output signal to the Servo.
SevenSegment ss(.SW(SW), .seg(seven_seg), .an(AN),.clk(clk_display));

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

module SevenSegment(SW,seg,an,clk);
input [9:0]SW;
input clk;
output reg [6:0]seg;
output reg[3:0]an;

always@(posedge clk)begin
    case(an)
    4'b1110: begin//next 0111.
        if(SW/1000 == 1) seg <= 7'b1111001;
        else seg <= 7'b1000000;
        an <= 4'b0111;
    end
       4'b0111: begin//next1011.
        if((SW/100)%10==0)seg <= 7'b1000000;
        else if((SW/100)%10 == 1) seg <= 7'b1111001;
        else if((SW/100)%10 == 2) seg <= 7'b0100100;
        else if((SW/100)%10 == 3) seg <= 7'b0110000;
        else if((SW/100)%10 == 4) seg <= 7'b0011001;
        else if((SW/100)%10 == 5) seg <= 7'b0010010;
        else if((SW/100)%10 == 6) seg <= 7'b0000010;
        else if((SW/100)%10 == 7) seg <= 7'b1111000;
        else if((SW/100)%10 == 8) seg <= 7'b0000000;
        else if((SW/100)%10 == 9) seg <= 7'b0010000;
        else seg <= 7'b1000000;
        an <= 4'b1011;
    end 
    4'b1011: begin//next 1101.
        if((SW/10)%10==0)seg <= 7'b1000000;
        else if((SW/10)%10 == 1) seg <= 7'b1111001;
        else if((SW/10)%10 == 2) seg <= 7'b0100100;
        else if((SW/10)%10 == 3) seg <= 7'b0110000;
        else if((SW/10)%10 == 4) seg <= 7'b0011001;
        else if((SW/10)%10 == 5) seg <= 7'b0010010;
        else if((SW/10)%10 == 6) seg <= 7'b0000010;
        else if((SW/10)%10 == 7) seg <= 7'b1111000;
        else if((SW/10)%10 == 8) seg <= 7'b0000000;
        else if((SW/10)%10 == 9) seg <= 7'b0010000;
        else seg <= 7'b1000000;
        an <= 4'b1101;
    end
    4'b1101: begin//next 1110.
        if(SW%10==0)seg <= 7'b1000000;
        else if(SW%10 == 1) seg <= 7'b1111001;
        else if(SW%10 == 2) seg <= 7'b0100100;
        else if(SW%10 == 3) seg <= 7'b0110000;
        else if(SW%10 == 4) seg <= 7'b0011001;
        else if(SW%10 == 5) seg <= 7'b0010010;
        else if(SW%10 == 6) seg <= 7'b0000010;
        else if(SW%10 == 7) seg <= 7'b1111000;
        else if(SW%10 == 8) seg <= 7'b0000000;
        else if(SW%10 == 9) seg <= 7'b0010000;
        else seg <= 7'b1000000;
        an <= 4'b1110;
    end
    default:begin
        an <= 4'b1110;
        seg <= 7'b1000000;
    end
    endcase
end //always block.       
endmodule

module clk_divider(input clk, input[31:0]divisor, output reg clk_o);
reg [31:0]count;
wire [31:0]next_count;
always@(posedge clk)begin
    count <= next_count;
end
always@(*)begin
    if(count < divisor/2)
        clk_o = 1'b1;
    else
        clk_o = 1'b0;
  end
assign next_count = (count==divisor)? 32'd0 :  count + 32'd1;
endmodule