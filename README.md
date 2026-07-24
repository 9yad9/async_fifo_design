# Asynchronous FIFO Design with Gray-Code CDC Synchronization

A modular, parameterizable Asynchronous FIFO (First-In, First-Out) implemented in pure Verilog. Designed for Clock Domain Crossing (CDC) scenarios where data must safely transfer between two independent, unsynchronized clock domains without metastablity or data corruption.

## 📌 Architecture & Design Features

* **Dual Unsynchronized Clock Domains:** Separate Write Clock (`w_clk`) and Read Clock (`r_clk`).
* **Metastability Mitigation:** Dual-flop synchronizers (`sync_write_2_read` & `sync_read_2_write`) for cross-domain pointer transfer.
* **Gray Code Pointer Encoding:** Converts binary read/write pointers to Gray code before crossing clock domains to ensure only 1 bit changes per clock cycle.
* **Block RAM Memory Model:** Parameterizable data width (`DATA_SIZE`) and address depth (`ADDR_SIZE`).
* **Full & Empty Flag Generation:**
  * `w_full` generated in write domain to prevent overflow.
  * `user_empty` generated in read domain to prevent underflow.

## 📁 Project Directory Hierarchy

```text
async_fifo_design/
├── .gitignore          # Excludes Vivado simulation/synthesis logs
├── README.md           # Documentation
├── rtl/                # Verilog RTL source files
│   ├── fifotop.v       # Top-level wrapper module
│   ├── fifomem.v       # Dual-port RAM memory core
│   ├── write_logic.v   # Write pointer & full flag generation
│   ├── read_logic.v    # Read pointer & empty flag generation
│   ├── sync_w2r.v      # 2-flop synchronizer (Write to Read)
│   └── sync_r2w.v      # 2-flop synchronizer (Read to Write)
├── tb/                 # Verification environment
│   └── tb_async_fifo.v # Self-checking Verilog testbench
└── constraints/        # Synthesis constraints
    └── constraints.xdc # Timing & CDC false path constraints