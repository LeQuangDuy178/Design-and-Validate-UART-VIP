class diff_baud_rate_err_test extends uart_base_test;

  `uvm_component_utils(diff_config_err_test)

  uart_half_duplex_sequence uart_seq_lhs;
  uart_half_duplex_sequence uart_seq_rhs;

  //int parity_mode_arr[] = {uart_configuration:: NO_PARITY, uart_configuration:: ODD, uart_configuration:: EVEN};

  function new(string name = "diff_config_err_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  /* Set uart_rhs_agt to PASSIVE mode
    Then no need to start sequence via sequencer of rhs */

  virtual task run_phase (uvm_phase phase);
    phase.raise_objection(this);

    /* Randomizing all configs, excepting baud rate
      Using half_duplex transfer*/

    err_catcher.add_error_catcher_msg("Failed data integrity compare");

    for (int i = 0; i < 4; i++) begin
    assert(uart_lhs_config.randomize() with {
      uart_lhs_config.parity_mode == parity_mode_arr[i];
      //uart_lhs_config.baud_rate == 9600;
      uart_lhs_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
      uart_lhs_config.data_width == uart_configuration::WIDTH_9;
    });
    else `uvm_error({msg, get_type_name()}, "Randomization failed!");

    assert(uart_rhs_config.randomize() with {
      uart_rhs_config.parity_mode == parity_mode_arr[i];
      //uart_rhs_config.baud_rate == 9600;
      uart_rhs_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
      uart_rhs_config.data_width == uart_configuration::WIDTH_9;
    });
    else `uvm_error({msg, get_type_name()}, "Randomization failed!");

    uart_seq_lhs = uart_half_duplex_sequence::type_id::create("uart_seq_lhs");
    uart_seq_rhs = uart_half_duplex_sequence::type_id::create("uart_seq_rhs");

    /* Half-duplex transfer, two-way transfer, but single device per trans
      For baud rate test, lhs send transfer 4800, 19200 and 115200 baud
      rhs send 57600 and 19200, transfer one-way per time */

    if ((i == 1) || (i == 2)) begin
      uart_seq_lhs.seq_key.get(1);
      `uvm_info({msg, "[diff_config_err_test]", "[LHS Device]"}, "Get semaphore key and send transfer TX", UVM_MEDIUM)
      uart_seq_lhs.uart_config = uart_lhs_config;
      uart_seq_lhs.start(uart_env.uart_lhs_agt.uart_seqr);
      uart_env.uart_sco.ref_req_seq_queue.push_back(uart_seq_lhs.req);
    end

      if ((i == 0) || (i == 1) || (i == 3)) begin
      uart_seq_rhs.seq_key.get(1);
      uart_seq_rhs.uart_config = uart_rhs_config;
      uart_seq_rhs.start(uart_env.uart_rhs_agt.uart_seqr);
      uart_env.uart_sco.ref_req_seq_queue.push_back(uart_seq_rhs.req);
    end

    // Also send config
    sco_lhs_config = $cast(sco_lhs_config, uart_lhs_config.clone());
    sco_rhs_config = $cast(sco_rhs_config, uart_rhs_config.clone());
    uart_env.uart_sco.config_test_lhs_queue.push_back(sco_lhs_config);
    uart_env.uart_sco.config_test_rhs_queue.push_back(sco_rhs_config);

    // Disable checker since error will be captured
    //uart_env.uart_sco.checker_enb = 0;

    #200;
  end

  phase.drop_objection(this);

  endtask: run_phase

endclass

