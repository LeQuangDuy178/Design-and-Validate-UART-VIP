`ifndef GUARD_UART_TEST_PKG_SV
`define GUARD_UART_TEST_PKG_SV

package test_pkg;

  import uvm_pkg::*;
  import uart_pkg::*;
  import seq_pkg::*;
  import env_pkg::*;

  // Include your file
  `include "uart_error_catcher.sv"

  `include "uart_base_test.sv"
  `include "uart_default_test.sv"

  `include "simplex_baud_rate_test.sv"
  `include "simplex_parity_mode_test.sv"
  `include "simplex_stop_bit_width_test.sv"
  `include "simplex_data_width_test.sv"

  `include "half_duplex_baud_rate_test.sv"
  `include "half_duplex_parity_mode_test.sv"
  `include "half_duplex_stop_bit_width_test.sv"
  `include "half_duplex_data_width_test.sv"

  `include "full_duplex_baud_rate_test.sv"
  `include "full_duplex_parity_mode_test.sv"
  `include "full_duplex_stop_bit_width_test.sv"
  `include "full_duplex_data_width_test.sv"
  `include "parity_vs_data_width_test.sv"

  `include "diff_config_err_test.sv"
  `include "diff_baud_rate_err_test.sv"

endpackage: test_pkg

`endif