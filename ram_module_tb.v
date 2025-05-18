`timescale 1ns/1ps

module tb_ram_sp_sr_sw;

  // Parameters
  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 8;

  // Signals
  reg clk;
  reg [ADDR_WIDTH-1:0] address;
  reg cs;
  reg we;
  reg oe;
  wire [DATA_WIDTH-1:0] data;

  reg [DATA_WIDTH-1:0] data_tb;
  reg data_drive;
  assign data = data_drive ? data_tb : 8'bz;

  // Instantiate DUT
  ram_sp_sr_sw uut (
    .clk(clk),
    .address(address),
    .data(data),
    .cs(cs),
    .we(we),
    .oe(oe)
  );

  // Clock
  always #5 clk = ~clk;

  // Initialize
  initial begin
    clk = 0;
    cs = 0;
    we = 0;
    oe = 0;
    address = 0;
    data_tb = 0;
    data_drive = 0;

    #10;

    // Case 1: Valid Write
    $display("CASE 1: Valid Write");
    @(posedge clk);
    cs = 1; we = 1; oe = 0;
    address = 8'h01;
    data_tb = 8'hAA;
    data_drive = 1;

    @(posedge clk);
    cs = 0; we = 0; data_drive = 0;

    // Case 2: Valid Read
    $display("CASE 2: Valid Read");
    @(posedge clk);
    cs = 1; we = 0; oe = 1;
    address = 8'h01;

    @(posedge clk);
    #1;
    $display("Read Data = %h (Expect 0xAA)", data);

    // Case 3: Output Disabled (oe=0)
    $display("CASE 3: Output Disabled (Expect Z)");
    @(posedge clk);
    cs = 1; we = 0; oe = 0;
    address = 8'h01;

    @(posedge clk);
    #1;
    $display("Data = %h", data); // should be high impedance (z)

    // Case 4: Chip Not Selected (cs=0)
    $display("CASE 4: Chip Not Selected (Expect Z)");
    @(posedge clk);
    cs = 0; we = 0; oe = 1;
    address = 8'h01;

    @(posedge clk);
    #1;
    $display("Data = %h", data); // should be high impedance (z)

    // Case 5: Invalid Read (we=1)
    $display("CASE 5: Invalid Read During Write Mode (Expect Z)");
    @(posedge clk);
    cs = 1; we = 1; oe = 1;
    address = 8'h01;

    @(posedge clk);
    #1;
    $display("Data = %h", data); // should be high impedance (z)

    $display("All test cases executed.");
    #10 $finish;
  end

endmodule
