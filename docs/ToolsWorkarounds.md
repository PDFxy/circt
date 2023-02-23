# EDA Tool Workarounds

This documents various bugs found in EDA tools and their workarounds in circt.
Each but will have a brief description, example code, and the mitigation added
(with links to the commit when possible).  


# Inline Array calculations can cause synthesis failures

## Example
```
module Foo (input clock, input in, output [2:0] out);
  reg [2:0] state;
  wire [7:0][2:0] array = 24'h4 << 6;
  wire [2:0] a = array[state];
  wire [2:0] b = array[state + 3'h1 + 3'h1];
  // works:      array[state + (3'h1 + 3'h1)]
  // works:      array[state + 3'h2]
  always @(posedge clock) state <= in ? a : b;
  assign out = b;
endmodule
```

## Workaround

Flag added to export verilog to force array index calculations to not be inline.

https://github.com/llvm/circt/commit/15a1f95f2d59767f20b459a12ac42338de22bc97

# Memory semantics changed by synthesis

## Example
```
Qux:
  module Qux:
    input clock: Clock
    input addr: UInt<1>
    input r: {en: UInt<1>, flip data: {a: UInt<32>, b: UInt<32>}, addr: UInt<1>}
    input w: {en: UInt<1>, data: {a: UInt<32>, b: UInt<32>}, addr: UInt<1>, mask: {a: UInt<1>, b: UInt<1>}}

    mem m :
      data-type => {a: UInt<32>, b: UInt<32>}
      depth => 1
      reader => r
      writer => w
      read-latency => 0
      write-latency => 1
      read-under-write => undefined

    m.r.clk <= clock
    m.r.en <= r.en
    m.r.addr <= r.addr
    r.data <= m.r.data

    m.w.clk <= clock
    m.w.en <= w.en
    m.w.addr <= w.addr
    m.w.data <= w.data
    m.w.mask <= w.mask
```
Compile with either firtool -repl-seq-mem -repl-seq-mem-file=mem.conf Foo.fir and firrtl -i Foo.fir.