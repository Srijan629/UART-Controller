# Multi-Channel UART Controller

A hardware implementation of a **UART (Universal Asynchronous Receiver-Transmitter) Controller** designed in synthesizable Verilog HDL and verified using Xilinx Vivado. This core enables reliable asynchronous serial communication between digital systems.

## 🛠️ Architecture & Design Features

The architecture is divided into independent, modular blocks to optimize timing closure and maintain clean separation of concerns:

* **Baud Rate Generator:** Implements a clock divider circuit generating a 16x oversampling clock tick to accurately sample incoming asynchronous data and minimize clock drift effects.
* **Transmitter Module (UART Tx):** Driven by an algorithmic Finite State Machine (FSM) that coordinates parallel-to-serial conversion, handles start/stop framing bits, and manages transmission data lines.
* **Receiver Module (UART Rx):** Utilizes a robust 16x oversampling verification strategy to sample incoming serial bits precisely at the midpoint of their pulse widths, mitigating noise and metastability.
* **Top Level Wrapper (`uart_top`):** Integrates the sub-modules seamlessly with added status registers to interface with external system buses.

## 📂 Project Structure

```text
├── RTL/
│   ├── uart_top.v       # Top-level integration module
│   ├── uart_tx.v        # Transmitter FSM logic
│   ├── uart_rx.v        # Receiver oversampling logic
│   └── baud_rate_gen.v  # Clock divider circuit
├── TESTBENCH/
│   └── uart_tb.v        # Self-checking testbench for verification
└── waveform.png         # Behavioral simulation timing diagram
