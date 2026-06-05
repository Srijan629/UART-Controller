module baud_rate_gen (
    input wire clk,
    input wire rst,
    output wire baud_tick
);
    reg [9:0] r_reg;
    wire [9:0] r_next;

    always @(posedge clk or posedge rst) begin
        if (rst)
            r_reg <= 0;
        else
            r_reg <= r_next;
    end

    // For a 100MHz clock and 9600 Baud (16x oversampling), we count to 651
    assign r_next = (r_reg == 651) ? 0 : r_reg + 1;
    assign baud_tick = (r_reg == 651);
endmodule