`timescale 1ns / 1ps

module uart_tb();
    reg clk, rst;
    reg [7:0] tx_data;
    reg tx_start;
    wire tx_serial;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_ready;
    wire framing_err;

    // Connect top level design to testbench (Internal loopback: connect tx to rx)
    uart_top uut (
        .clk(clk), .rst(rst), .tx_data(tx_data), .tx_start(tx_start),
        .rx_serial(tx_serial), .tx_serial(tx_serial), .tx_busy(tx_busy),
        .rx_data(rx_data), .rx_ready(rx_ready), .framing_err(framing_err)
    );

    // 100MHz main clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; tx_start = 0; tx_data = 8'h00;
        #20 rst = 0; // Release system reset

        // Test Scenario: Send byte 0xAC (Alternating binary pattern)
        #50;
        tx_data = 8'hAC;
        tx_start = 1;
        #10 tx_start = 0;

        // Wait until receiver confirms reception
        @(posedge rx_ready);
        #100;
        $display("Data Transmitted: 0xAC, Data Received: 0x%h", rx_data);
        $finish;
    end
endmodule