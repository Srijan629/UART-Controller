module uart_top (
    input wire clk, rst,
    input wire [7:0] tx_data,
    input wire tx_start,
    input wire rx_serial,
    output wire tx_serial,
    output wire tx_busy,
    output wire [7:0] rx_data,
    output wire rx_ready,
    output wire framing_err
);
    wire tick;

    baud_rate_gen u_baud (
        .clk(clk), .rst(rst), .baud_tick(tick)
    );

    uart_tx u_tx (
        .clk(clk), .rst(rst), .tx_tick(tick),
        .tx_start(tx_start), .din(tx_data),
        .tx(tx_serial), .tx_busy(tx_busy)
    );

    uart_rx u_rx (
        .clk(clk), .rst(rst), .rx_tick(tick),
        .rx(rx_serial), .rx_done_tick(rx_ready),
        .dout(rx_data), .framing_error(framing_err)
    );
endmodule