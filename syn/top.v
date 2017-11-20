/*
 * Copyright (c) 2017 Joel Holdsworth <joel@airwebreathe.org.uk>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

module top(input clk_100mhz, output p1_1, output p1_2, output p1_3,
  output p1_4, output p1_7, output p1_8, output p1_9, output p1_10);
parameter ClkFreq = 25000000; // Hz

// Clock Generator
wire clk_25mhz;
wire pll_locked;

SB_PLL40_PAD #(
  .FEEDBACK_PATH("SIMPLE"),
  .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
  .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
  .PLLOUT_SELECT("GENCLK"),
  .FDA_FEEDBACK(4'b1111),
  .FDA_RELATIVE(4'b1111),
  .DIVR(4'b0000),
  .DIVF(7'b0000111),
  .DIVQ(3'b101),
  .FILTER_RANGE(3'b101)
) pll (
  .PACKAGEPIN   (clk_100mhz),
  .PLLOUTGLOBAL (clk_25mhz),
  .LOCK         (pll_locked),
  .BYPASS       (1'b0),
  .RESETB       (1'b1)
);

wire clk = clk_25mhz;

// Reset Generator
reg [3:0] resetn_gen = 0;
reg reset;

always @(posedge clk) begin
  reset <= !&resetn_gen;
  resetn_gen <= {resetn_gen, pll_locked};
end

// PmodOLEDrgb
wire pmodoldedrgb_cs = p1_1;
wire pmodoldedrgb_sdin = p1_2;
assign p1_3 = 0;
wire pmodoldedrgb_sclk = p1_4;
wire pmodoldedrgb_d_cn = p1_7;
wire pmodoldedrgb_resn = p1_8;
wire pmodoldedrgb_vccen = p1_9;
wire pmodoldedrgb_pmoden = p1_10;

wire frame_begin;

pmodoledrgb_controller #(ClkFreq) pmodoled_controller(clk_25mhz, reset,
  frame_begin, pmodoldedrgb_cs, pmodoldedrgb_sdin, pmodoldedrgb_sclk,
  pmodoldedrgb_d_cn, pmodoldedrgb_resn, pmodoldedrgb_vccen,
  pmodoldedrgb_pmoden);

endmodule
