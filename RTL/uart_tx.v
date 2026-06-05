module uart_tx (
    input wire clk, rst,
    input wire tx_tick,
    input wire tx_start,
    input wire [7:0] din,
    output reg tx,
    output reg tx_busy
);
    localparam [1:0] IDLE  = 2'b00, START = 2'b01, DATA  = 2'b10, STOP  = 2'b11;
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next; // Tracks 16 oversampling ticks
    reg [2:0] n_reg, n_next; // Tracks 8 data bits
    reg [7:0] b_reg, b_next; // Holds data byte
    reg tx_reg, tx_next;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= IDLE; s_reg <= 0; n_reg <= 0; b_reg <= 0; tx_reg <= 1'b1;
        end else begin
            state_reg <= state_next; s_reg <= s_next; n_reg <= n_next; b_reg <= b_next; tx_reg <= tx_next;
        end
    end

    always @(*) begin
        state_next = state_reg; s_next = s_reg; n_next = n_reg; b_next = b_reg; tx_next = tx_reg;
        tx_busy = 1'b1;
        
        case (state_reg)
            IDLE: begin
                tx_busy = 1'b0; tx_next = 1'b1;
                if (tx_start) begin
                    state_next = START; s_next = 0; b_next = din;
                end
            end
            START: begin
                tx_next = 1'b0;
                if (tx_tick) begin
                    if (s_reg == 15) begin
                        state_next = DATA; s_next = 0; n_next = 0;
                    end else s_next = s_reg + 1;
                end
            end
            DATA: begin
                tx_next = b_reg[0];
                if (tx_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0; b_next = b_reg >> 1;
                        if (n_reg == 7) state_next = STOP;
                        else n_next = n_reg + 1;
                    end else s_next = s_reg + 1;
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (tx_tick) begin
                    if (s_reg == 15) begin
                        state_next = IDLE;
                    end else s_next = s_reg + 1;
                end
            end
        endcase
    end
    always @(posedge clk) tx <= tx_reg;
endmodule