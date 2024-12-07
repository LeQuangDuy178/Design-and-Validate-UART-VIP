class uart_base_test extends uvm_test;

  `uvm_component_utils(uart_base_test)
  //`uvm_component_utils(uart_configuration)

  virtual uart if lhs_vif;
  virtual uart if rhs_vif;

  uart_error_catcher err_catcher;

  uart_environment uart_env;

  uart_configuration uart_lhs_config;
  uart_configuration uart_rhs_config;

  uart_configuration sco_lhs_config;
  uart_configuration sco_rhs_config;

  /*
  uart_simplex_sequence simplex_seq_ref;
  uart_half_duplex_sequence half_duplex_seq_ref;
  uart_full_duplex_sequence full_duplex_seq_ref;
  */

  function new(string name = "uart_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  string msg = "[UART_TEST]"; // If local then no other class can access

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(msg, "[build_phase]", $sformatf("Entered..."), UVM_MEDIUM);

    // Get virtual interface from testbench via uvm_config_db
    // Hierarchy: "uvm_test_top.lhs_vif"
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "lhs_vif", lhs_vif))
      uvm_fatal(get_type_name(), $sformatf("Cannot get virtual interface"));
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "rhs_vif", rhs_vif))
      uvm_fatal(get_type_name(), $sformatf("Cannot get virtual interface"));

    // Create environment and configuration objects
    uart_env = uart_environment::type_id::create("uart_env", this);
    uart_lhs_config = uart_configuration::type_id::create("uart_lhs_config", this);
    uart_rhs_config = uart_configuration::type_id::create("uart_rhs_config", this);
    sco_lhs_config = new("sco_lhs_config");
    sco_rhs_config = new("sco_rhs_config");
    err_catcher = uart_error_catcher::type_id::create("err_catcher");
    uvm_report_cb::add(null, err_catcher);

    // Create sequence objects
    simplex_seq_ref = uart_simplex_sequence::type_id::create("simplex_seq_ref");
    half_duplex_seq_ref = uart_half_duplex_sequence::type_id::create("half_duplex_seq_ref");
    full_duplex_seq_ref = uart_full_duplex_sequence::type_id::create("full_duplex_sequence");

    // Set virtual interface to environment via uvm_config_db
    // Hierarchy: "uvm_test_top.uart_env.lhs_vif"
    uvm_config_db #(virtual uart_if)::set(this, "uart_env", "lhs_vif", lhs_vif);
    uvm_config_db #(virtual uart_if)::set(this, "uart_env", "rhs_vif", rhs_vif);

    // Assert configuration randomization
    assert(uart_lhs_config.randomize()) else `uvm_error(msg, "Fail");
    assert(uart_rhs_config.randomize()) else `uvm_error(get_type_name(), "Fail");

    // Set configuration to env -> agent -> driver/monitor
    // Also set configuration to transaction by shallow copy
    // Hierarchy: "uvm_test_top.uart_env.lhs/rhs_config"
    uvm_config_db #(uart_configuration)::set(this, "uart_env", "lhs_config", uart_lhs_config);
    uvm_config_db #(uart_configuration)::set(this, "uart_env", "rhs_config", uart_rhs_config);

    `uvm_info(get_type_name(), get_full_name(), UVM_NONE);

    `uvm_info({msg, "[build_phase]"}, $sformatf("Exited..."), UVM_MEDIUM);

  endfunction: build_phase

  virtual function void final_phase(uvm_phase phase);

  // Get report server database to track fatal and error
  uvm_report_server svr;

  super.final_phase(phase);
  `uvm_info(msg, "[final_phase]", "Entered...", UVM_HIGH);

  svr = uvm_report_server::get_server();

  // If global counts of uvm fatal and error detected
  // Then test fails, later can handle error by report catcher
  if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(`uvm_error) > 0) begin
    $display("########################################################################");
    $display("######################    DETECT FATAL OR ERROR       ##################");
    $display("######################    STATUS: TEST FAILED         ##################");
    $display("########################################################################");
    end
  else begin
    $display("########################################################################");
    $display("######################     NO FATAL OR ERROR          ##################");
    $display("######################     STATUS: TEST PASSED        ##################");
    $display("########################################################################");
    end

  `uvm_info({msg, "[final_phase]"}, "Exited...", UVM_HIGH);

endfunction: final_phase

//virtual function void set_config(uart_configuration uart_config);
//extern virtual function void send_req_sco(uart_transaction req);

endclass: uart_base_test