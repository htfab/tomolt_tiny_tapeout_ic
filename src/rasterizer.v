/*
 * Copyright (c) 2026 Thomas Oltmann
 * SPDX-License-Identifier: Apache-2.0
 * vim: sts=2 ts=2 sw=2 et
 */

module rasterizer(clk, reset, hsync, vsync, rgb);
  input clk, reset;
  output hsync, vsync;
  output reg [2:0] rgb;
  wire display_on;

  wire [9:0] hpos;
  wire [9:0] vpos;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  reg [4:0] permut_1;
  reg [4:0] permut_2;

  reg permut_1_dir;
  reg permut_2_dir;

  // Animate the geometry just a tiny bit to make it more interesting.
  always @(posedge vsync, posedge reset) begin
    if (reset) begin
      permut_1 <= 0;
      permut_1_dir <= 1;
      permut_2 <= 0;
      permut_2_dir <= 1;
    end else begin
      if (permut_1_dir) begin
        if (permut_1 == 5'b11111) begin
          permut_1_dir <= 0;
        end else begin
          permut_1 <= permut_1 + 1;
        end
      end else begin
        if (permut_1 == 5'b00000) begin
          permut_1_dir <= 1;
        end else begin
          permut_1 <= permut_1 - 1;
        end
      end

      if (permut_2_dir) begin
        if (permut_2 == 5'b11101) begin
          permut_2_dir <= 0;
        end else begin
          permut_2 <= permut_2 + 1;
        end
      end else begin
        if (permut_2 == 5'b00001) begin
          permut_2_dir <= 1;
        end else begin
          permut_2 <= permut_2 - 1;
        end
      end
    end
  end

  wire [59:0] geometry_1 = {
    10'd100 + {6'b000000, permut_1[4:1]}, 10'd1,
    10'd150 + {5'b00000, permut_2}, 10'd100,
    10'd200, 10'd60 + {5'b00000, permut_1}
  };

  wire [59:0] geometry_2 = {
    10'd500, 10'd120,
    10'd350, 10'd220,
    10'd600, 10'd320
  };

  wire [59:0] geometry_3 = {
    10'd300, 10'd350,
    10'd150, 10'd400,
    10'd250, 10'd440
  };

  reg [2:0] geometry_sel;

  always @(posedge clk, posedge reset) begin
    if (reset || hpos == 640) begin
      if (vpos+1 < geometry_2[49:40]) begin
        geometry_sel <= 3'b001;
      end else if (vpos+1 < geometry_3[49:40]) begin
        geometry_sel <= 3'b010;
      end else begin
        geometry_sel <= 3'b100;
      end
    end
  end

  wire [59:0] geometry = (geometry_sel[0] ? geometry_1 : (geometry_sel[1] ? geometry_2 : geometry_3));

  wire fill;

  triscan tscan(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .hpos(hpos),
    .vpos(vpos),
    .geometry(geometry),
    .fill(fill)
  );

  wire [2:0] value = fill ? geometry_sel : 3'b000;

  assign rgb = display_on ? value : 0;

endmodule

