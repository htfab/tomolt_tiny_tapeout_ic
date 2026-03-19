/*
* Copyright (c) 2026 Thomas Oltmann
* SPDX-License-Identifier: Apache-2.0
* vim: sts=2 ts=2 sw=2 et
*/

module serial_div #(parameter WIDTH = 10) (
  input wire clk,
  input wire load,
  input wire [WIDTH-1:0] num,
  input wire [WIDTH-1:0] den,
  output wire [WIDTH-1:0] quo,
  output wire [WIDTH-1:0] rem);

  reg [3:0] state;
  reg [2*WIDTH-1:0] accum;

  assign quo = accum[WIDTH-1:0];
  assign rem = accum[2*WIDTH-1:WIDTH];

  always @(posedge clk) begin
    if (load) begin
      accum <= {{WIDTH{1'b0}}, num};
      state <= 0;
    end else begin
      if (state < WIDTH) begin
        if (accum[2*WIDTH-2:WIDTH-1] >= den) begin
          accum <= {accum[2*WIDTH-2:WIDTH-1] - den, accum[WIDTH-2:0], 1'b1};
        end else begin
          accum <= {accum[2*WIDTH-2:0], 1'b0};
        end
        state <= state + 1;
      end
    end
  end

endmodule

