module uart_rx (
    input wire clk, rst,
    input wire rx_tick,
    input wire rx,
    output reg rx_done_tick,
    output reg [7:0] dout,
    output reg framing_error
);
    localparam [1:0] IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= IDLE; s_reg <= 0; n_reg <= 0; b_reg <= 0;
        end else begin
            state_reg <= state_next; s_reg <= s_next; n_reg <= n_next; b_reg <= b_next;
        end
    end

    always @(*) begin
        state_next = state_reg; s_next = s_reg; n_next = n_reg; b_next = b_reg;
        rx_done_tick = 1'b0; framing_error = 1'b0;
        
        case (state_reg)
            IDLE: begin
                if (~rx) begin
                    state_next = START; s_next = 0;
                end
            end
            START: begin
                if (rx_tick) begin
                    if (s_reg == 7) begin // Midpoint check
                        state_next = DATA; s_next = 0; n_next = 0;
                    end else s_next = s_reg + 1;
                end
            end
            DATA: begin
                if (rx_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0; b_next = {rx, b_reg[7:1]};
                        if (n_reg == 7) state_next = STOP;
                        else n_next = n_reg + 1;
                    end else s_next = s_reg + 1;
                end
            end
            STOP: begin
                if (rx_tick) begin
                    if (s_reg == 15) begin
                        state_next = IDLE;
                        rx_done_tick = 1'b1;
                        if (rx == 1'b0) framing_error = 1'b1; // Stop bit error check
                    end else s_next = s_reg + 1;
                end
            end
        endcase
    end
    always @(posedge clk) dout <= b_reg;
endmodule