// Project : UART VIP
// Filename : env_pkg.sv
// Author   : Duy Le
// Company  : NO
// Date     : 20-Nov-2024

// Description :

`ifndef GUARD_UART_ENV_PKG_SV
`define GUARD_UART_ENV_PKG_SV

package env_pkg;

  import uvm_pkg::*;
  import uart_pkg::*;

  // Include your file
  include "uart_scoreboard.sv"
  include "uart_environment.sv"

endpackage: env_pkg

`endif