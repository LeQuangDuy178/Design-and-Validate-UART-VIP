// Project : UART VIP

// Filename : seq_pkg.sv
// Author   : Huy Nguyen
// Company  : NO
// Date     : 20-Dec-2021

// Description :

`ifndef GUARD_UART_SEQ_PKG_SV
`define GUARD_UART_SEQ_PKG_SV

package seq_pkg;

  import uvm_pkg::*;
  import uart_pkg::*;

  // Include your file
  include "uart_default_sequence.sv"
  include "uart_simplex_sequence.sv"
  include "uart_half_duplex_sequence.sv"
  include "uart_full_duplex_sequence.sv"

endpackage: seq_pkg

`endif