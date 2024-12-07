class simplex_stop_bit_width_test extends uart_base_test;

  `uvm_component_utils(simplex_stop_bit_width_test)

  uart_simplex_sequence uart_seq_lhs;
  uart_simplex_sequence uart_seq_rhs;

  int stop_bit_width_arr[] = {uart_configuration::ONE_STOP_BIT, uart_configuration::TWO_STOP_BIT};

  function new(string name = "simplex_stop_bit_width_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  /* Set uart_rhs_agt to PASSIVE mode
   * Then no need to start sequence via sequencer of rhs */
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    for (int i = 0; i < stop_bit_width_arr.size(); i++) begin
      assert(uart_lhs_config.randomize() with {
        uart_lhs_config.stop_bit_width == stop_bit_width_arr[i];
        uart_lhs_config.baud_rate == 9600;
        uart_lhs_config.parity_mode == uart_configuration::NO_PARITY;
        uart_lhs_config.data_width == uart_configuration::WIDTH_9;
      }) else `uvm_error({msg, get_type_name()}, "Randomization failed!");

      assert(uart_rhs_config.randomize() with {
        uart_rhs_config.stop_bit_width == stop_bit_width_arr[i];
        uart_rhs_config.baud_rate == 9600;
        uart_rhs_config.parity_mode == uart_configuration::NO_PARITY;
        uart_rhs_config.data_width == uart_configuration::WIDTH_9;
      }) else `uvm_error({msg, get_type_name()}, "Randomization failed!");

      uart_seq_lhs = uart_simplex_sequence::type_id::create("uart_seq_lhs");
      uart_seq_lhs.uart_config = uart_lhs_config;
      uart_seq_lhs.start(uart_env.uart_lhs_agt.uart_seqr);

      uart_seq_rhs = uart_simplex_sequence::type_id::create("uart_seq_rhs");
      uart_seq_rhs.uart_config = uart_lhs_config;
      uart_seq_rhs.start(uart_env.uart_rhs_agt.uart_seqr);

      // Send req to scoreboard as queue
      uart_env.uart_sco.ref_req_seq_queue.push_back(uart_seq_lhs.req);
      //uart_env.uart_sco.req_seq_rhs_queue.push_back(uart_seq_rhs.req);

      // Also send config
      $cast(sco_lhs_config, uart_lhs_config.clone());
      $cast(sco_rhs_config, uart_rhs_config.clone());
      uart_env.uart_sco.config_test_lhs_queue.push_back(sco_lhs_config);
      uart_env.uart_sco.config_test_rhs_queue.push_back(sco_rhs_config);

      #200;
      
    end

    #1us;

    phase.drop_objection(this);
    
  endtask: run_phase

endclass: simplex_stop_bit_width_test