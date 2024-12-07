class full_duplex_baud_rate_test extends uart_base_test;

  `uvm_component_utils(full_duplex_baud_rate_test)

  uart_full_duplex_sequence uart_seq_lhs;
  uart_full_duplex_sequence uart_seq_rhs;

  int baud_rate_arr[] = {4800, 9600, 19200, 57600, 115200};

  function new(string name = "full_duplex_baud_rate_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  /* Set uart_rhs_agt to PASSIVE mode
    Then no need to start sequence via sequencer of rhs */

  virtual task run_phase (uvm_phase phase);
    phase.raise_objection(this);

    for (int i = 0; i < baud_rate_arr.size(); i++) begin

      assert(uart_lhs_config.randomize() with {
      uart_lhs_config.baud_rate == baud_rate_arr[i];
      uart_lhs_config.parity_mode == uart_configuration::NO_PARITY;
      uart_lhs_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
      uart_lhs_config.data_width == uart_configuration::WIDTH_9;
    });
    else `uvm_error({msg, get_type_name()}, "Randomization failed!");

    assert(uart_rhs_config.randomize() with {
      uart_rhs_config.baud_rate == baud_rate_arr[i];
      uart_rhs_config.parity_mode == uart_configuration::NO_PARITY;
      uart_rhs_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
      uart_rhs_config.data_width == uart_configuration::WIDTH_9;
    });
    else `uvm_error({msg, get_type_name()}, "Randomization failed!");

    // Also send config
    sco_lhs_config = $cast(sco_lhs_config, uart_lhs_config.clone());
    sco_rhs_config = $cast(sco_rhs_config, uart_rhs_config.clone());
    uart_env.uart_sco.config_test_lhs_queue.push_back(sco_lhs_config);
    uart_env.uart_sco.config_test_rhs_queue.push_back(sco_rhs_config);

    fork
      `uvm_info({msg, "[full_duplex_baud_rate_test]", "[LHS Device]"}, "Send transfer TX", UVM_MEDIUM)
      uart_seq_lhs = uart_full_duplex_sequence::type_id::create("uart_seq_lhs");
      uart_seq_lhs.uart_config = uart_lhs_config;
      uart_seq_lhs.start(uart_env.uart_lhs_agt.uart_seqr);
      //uart_env.uart_sco.ref_req_seq_queue.push_back(uart_seq_lhs.req);

      `uvm_info({msg, "[full_duplex_baud_rate_test]", "[RHS Device]"}, "Send transfer TX", UVM_MEDIUM)
      uart_seq_rhs = uart_full_duplex_sequence::type_id::create("uart_seq_rhs");
      uart_seq_rhs.uart_config = uart_rhs_config;
      uart_seq_rhs.start(uart_env.uart_rhs_agt.uart_seqr);
      //uart_env.uart_sco.ref_req_seq_queue.push_back(uart_seq_rhs.req);
    join

    uart_env.uart_sco.req_seq_lhs_queue.push_back(uart_seq_lhs.req);
    uart_env.uart_sco.req_seq_rhs_queue.push_back(uart_seq_rhs.req);

    end

    phase.drop_objection(this);
  endtask: run_phase

endclass