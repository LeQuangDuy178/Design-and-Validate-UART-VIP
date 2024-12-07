class parity_vs_data_width_test extends uart_base_test;

  `uvm_component_utils(parity_vs_data_width_test)

  uart_default_sequence uart_seq_lhs;
  uart_default_sequence uart_seq_rhs;

  //uart_configuration uart_config_queue[$];
  // {"uart_lhs_agent", "uart_rhs_agent"}

  function new(string name = "parity_vs_data_width_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase (uvm_phase phase);
    phase.raise_objection(this); // this parity_vs_data_width_test

    /* Set config       And shallow copy sequence> transaction*/
    //set_config(uart_config);
    //uart_seq.uart_config = this.uart_config;

    assert(uart_lhs_config.randomize() with {
      uart_lhs_config.parity_mode == uart_configuration::ODD;
      uart_lhs_config.data_width == uart_configuration::WIDTH_9;
      uart_lhs_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
      uart_lhs_config.baud_rate == 9600;
    }) else uvm_error(msg, "Fail Randomization");

    /* Controlling constraint
                      Disable the constraint of baud rate for this randomization */

    if (uart_rhs_config.baud_rate_constraint.constraint_mode()) begin // If rand mode() is not defined
      uart_rhs_config.baud_rate_constraint.constraint_mode(0);
      uvm_info({msg, get_type_name()}, "Turn off randomization for baud rate", UVM_LOW);
    end

    assert(uart_rhs_config.randomize() with {
      uart_rhs_config.baud_rate == 9600;
      uart_rhs_config.stop_bit_width == uart_configuration::TWO_STOP_BIT;
      uart_rhs_config.data_width == uart_configuration::WIDTH_5;
      uart_rhs_config.parity_mode == uart_configuration::EVEN;
    }) else uvm_error(get_type_name(), "Fail Randomization");

    // Send req to scoreboard as queue
    //uart_env.uart_sco.req_seq_lhs_queue.push_back(uart_seq_lhs.req);
    //uart_env.uart_sco.req_seq_rhs_queue.push_back(uart_seq_rhs.req);

    // Also send config
    sco_lhs_config = $cast(sco_lhs_config, uart_lhs_config.clone());
    sco_rhs_config = $cast(sco_rhs_config, uart_rhs_config.clone());
    uart_env.uart_sco.config_test_lhs_queue.push_back(sco_lhs_config);
    uart_env.uart_sco.config_test_rhs_queue.push_back(sco_rhs_config);

    /* Transfer both lhs and rhs agent
      * Also send config to seq -> seq item */
    fork
      uart_seq_lhs = uart_default_sequence::type_id::create("uart_seq_lhs");
      uart_seq_lhs.uart_config = uart_lhs_config;
      uart_seq_lhs.start(uart_env.uart_lhs_agt.uart_seqr);

      uart_seq_rhs = uart_default_sequence::type_id::create("uart_seq_rhs");
      uart_seq_rhs.uart_config = uart_rhs_config;
      uart_seq_rhs.start(uart_env.uart_rhs_agt.uart_seqr);
    join

    #1us;

    uart_env.uart_sco.req_seq_lhs_queue.push_back(uart_seq_lhs.req);
    uart_env.uart_sco.req_seq_rhs_queue.push_back(uart_seq_rhs.req);

    phase.drop_objection(this);

  endtask: run_phase

endclass