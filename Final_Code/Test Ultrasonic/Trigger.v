module Trigger(clk,rst,trigger);
input clk;//period : 1s. every micro second interrupt, so divide by 100. //10^6 = 1000000 = 1sec, 999990
input rst; //100ms, when 100000 => 99999
output reg trigger; // High for 10us, Low for 999990 us.

wire [20-1:0]next_count;
reg [20-1:0]count;

always@(posedge clk)begin
    if(rst) count <= 20'd0;
    else    count <= next_count;
end

always@(*)begin
    if(count < 20'd10)begin
        trigger = 1'b1;
    end
    else trigger = 1'b0;
end

assign next_count = (count == 20'd99999) ? 20'd0 : count + 20'd1;

endmodule