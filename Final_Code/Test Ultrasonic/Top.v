module TOP(clk, rst, trigger, echo,/* distance */an, seg, LED, dp);
input clk, rst,echo;
output trigger;
///For seven segment.
output  [3:0]an;
output  [6:0]seg;
output [3:0]LED; // 0-10, 10-20, 20-30, 30+.
output dp;
wire [20-1:0]distance;
wire clk_1MHZ, display_clk, rst_one_pulse;
wire rst_debounced;

clock_divider c0( .clk_in(clk), .divisor(100) , .clk_out(clk_1MHZ));
clock_divider c7( .clk_in(clk), .divisor(2**15), .clk_out(display_clk));

debounce  d0(rst, clk, rst_debounced);
one_pulse op(rst_debounced, clk, rst_one_pulse);


Trigger T0(.clk(clk_1MHZ),.rst(rst_one_pulse),.trigger(trigger));
echo e0(.clk(clk_1MHZ),.rst(rst_one_pulse),.echo(echo),.distance(distance));

SevenSegment s7(.clk(display_clk), .dis(distance), .an(an), .seg(seg), .dp(dp));

assign LED[0] = (distance <= 20'd10) ? 1'b1 : 1'b0;
assign LED[1] = (distance >20'd10 && distance <= 20'd20) ? 1'b1 : 1'b0;
assign LED[2] = (distance >20'd20 && distance <= 20'd30) ? 1'b1 : 1'b0;
assign LED[3] = (distance >20'd30) ? 1'b1 : 1'b0;

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
input [19:0]dis; //Distance.
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