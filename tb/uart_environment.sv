class uart_environment extends uvm_env;

  `uvm_component_utils(uart_environment)

  virtual uart_if lhs_vif;
  virtual uart_if rhs_vif;

  uart_scoreboard uart_sco;
  uart_agent uart_lhs_agt;
  uart_agent uart_rhs_agt;

  uart_configuration uart_lhs_config;
  uart_configuration uart_rhs_config;

  local string msg = "[UART_TEST][UART_ENVIRONMENT]";

  function new(string name = "uart_environment", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info({msg, "[build_phase]"}, $sformatf("Entered..."), UVM_MEDIUM);

    /* Get virtual interface from uvm_test_top via uvm_config_db
      * Hierarchy: "uvm_test_top.uart_env.lhs_vif" */

    if (!uvm_config_db #(virtual uart_if)::get(this, "", "lhs_vif", lhs_vif))
      `uvm_info(get_type_name(), $sformatf("cannot get interface via config_db"));
    else
      `uvm_info(get_type_name(), "Get lhs_vif successful", UVM_FULL);

    if (!uvm_config_db #(virtual uart_if)::get(this, "", "rhs_vif", rhs_vif))
      `uvm_info(msg, "Cannot get virtual interface via uvm_config_db");
    else
      `uvm_info(get_type_name(), "Get rhs_vif successful", UVM_FULL);

    /* Before getting config via config_db, need to create obj via instance */
    //uart_lhs_config = new("uart_lhs_config");
    //uart_rhs_config = new("uart_rhs_config");
    //uart_lhs_config = uart_configuration::type_id::create("uart_lhs_config");
    //uart_rhs_config = uart_configuration::type_id::create("uart_rhs_config");

    `uvm_info(msg, this.get_full_name(), UVM_FULL);
    if (!uvm_config_db #(uart_configuration)::get(this, "", "lhs_config", uart_lhs_config))
      `uvm_info(msg, {"Cannot get lhs config from ", get_full_name()});

    if (!uvm_config_db #(uart_configuration)::get(this, "", "rhs_config", uart_rhs_config))
      `uvm_info(msg, {"cannot get rhs config from ", get_full_name()});

    // Register component's object to uvm factory
    uart_sco = uart_scoreboard::type_id::create("uart_sco", this);
    uart_lhs_agt = uart_agent::type_id::create("uart_lhs_agt", this);
    uart_rhs_agt = uart_agent::type_id::create("uart_rhs_agt", this);
    //uart_lhs_config = uart_configuration::type_id::create("uart_lhs_config");
    //uart_rhs_config = uart_configuration::type_id::create("uart_rhs_config");

    // Set rhs agent to PASSIVE mode
    // Can use $test$plusargs to adjust mode in command
    //uart_lhs_agt.is_active = UVM_PASSIVE;
    //uart_rhs_agt.is_active = UVM_PASSIVE;

    // Set virtual interface to agent via uvm_config_db
    // Hierarchy: "uvm_test_top.uart_env.uart_lhs_agt.lhs_vif"
    // 3rd argument act as a sempahore key -> "uvm_test_top.uart_env.uart_rhs_agt.rhs_vif"
    // set() and get() 3rd argument must equal to access data
    uvm_config_db #(virtual uart_if)::set(this, "uart_lhs_agt", "vif", lhs_vif);
    uvm_config_db #(virtual uart_if)::set(this, "uart_rhs_agt", "vif", rhs_vif);

    uvm_config_db #(uart_configuration)::set(this, "uart_lhs_agt", "config", uart_lhs_config);
    uvm_config_db #(uart_configuration)::set(this, "uart_rhs_agt", "config", uart_rhs_config);

    `uvm_info({msg, "[build_phase]"}, $sformatf("Exited..."), UVM_MEDIUM);

  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    `uvm_info({msg, "[connect_phase]"}, $sformatf("Entered..."), UVM_MEDIUM);

    // Connect analysis port of monitor in agent to analysis export of scoreboard
    uart_lhs_agt.uart_mon.item_observed_port.connect(uart_sco.lhs_item_collected_export);
    uart_rhs_agt.uart_mon.item_observed_port.connect(uart_sco.rhs_item_collected_export);

    `uvm_info({msg, "[connect_phase]"}, $sformatf("Exited..."), UVM_MEDIUM);

  endfunction: connect_phase

endclass: uart_environment