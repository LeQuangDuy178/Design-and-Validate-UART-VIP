module testbench:
  import uvm_pkg::*;
  import uart_pkg::*;
  import test_pkg::*;

  // Instantiate UART Interface
  uart_if lhs_if();
  uart_if rhs_if();

  // Interconnect
  uart_dut dut(.tx_lhs(lhs_if.rx),
               .rx_lhs(lhs_if.tx),
               .tx_rhs(rhs_if.rx),
               .rx_rhs(rhs_if.tx));

  // Set the VIP interface on the environment
  // Hierarchy: "root.uvm_test_top.lhs_vif"
  // Hierarchy: "root.uvm_test_top.rhs_vif"
  initial begin
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(), "uvm_test_top", "lhs_vif", lhs_if);
    uvm_config_db#(virtual uart_if)::set(uvm_root::get(), "uvm_test_top", "rhs_vif", rhs_if);

    uvm_top.check_config_usage(); // Check config db status

    // Start the UVM test
    run_test();
  end

  // Perform SVA
  // Tracking behavior of TX and RX in START, PARITY and STOP
  // Of both LHS and RHS

  // TX - START - LHS
  /*
  sequence seq_start_tx;
    lhs_if.tx ##0;
  endsequence

  property prop_start_tx;
    @(negedge lhs_if.tx) |-> seq_start_tx;
  endproperty

  assert property (prop_start_tx) else $error("Error SVA");
  */
endmodule