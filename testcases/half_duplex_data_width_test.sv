class half_duplex_data_width_test extends uart_base_test;

uvm_component_utils(half_duplex_data_width_test)

uart_half_duplex_sequence uart_seq_lhs;
uart_half_duplex_sequence uart_seq_rhs;

int data_width_arr[] = {uart_configuration::WIDTH_5, uart_configuration::WIDTH_6, 
uart_configuration::WIDTH_7, uart_configuration::WIDTH_8, uart_configuration::WIDTH_9};

function new(string name = "half_duplex_data_width_test", uvm_component parent);
  super.new(name, parent);
endfunction: new

/* Set uart rhs agt to PASSIVE mode
   Then no need to start sequence via sequencer of rhs */

virtual task run_phase (uvm_phase phase);
  phase.raise_objection(this);

  for (int i = 0; i < data_width_arr.size(); i++) begin
    assert(uart_lhs_config.randomize() with {
      uart_lhs_config.data_width == data_width_arr[i];
      uart_lhs_config.parity_mode == uart_configuration::NO_PARITY;
      uart_lhs_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
      uart_lhs_config.baud_rate == 9600;
    });
    else `uvm_error({msg, get_type_name()}, "Randomization failed!")

    assert(uart_rhs_config.randomize() with {
    uart_rhs_config.data_width == data_width_arr[i];
    uart_rhs_config.parity_mode == uart_configuration::NO_PARITY;
    uart_rhs_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
    uart_rhs_config.baud_rate == 9600;
    });
    else `uvm_error({msg, get_type_name()}, "Randomization failed!");

    uart_seq_lhs = uart_half_duplex_sequence::type_id::create("uart_seq_lhs");
    uart_seq_rhs = uart_half_duplex_sequence::type_id::create("uart_seq_rhs");

    /* Half-duplex transfer, two-way transfer, but single device per trans
      For baud rate test, lhs send transfer 4800, 19200 and 115200 baud
      rhs send 57600 and 19200, transfer one-way per time */

    if ((i == 1) || (i == 3)) begin
      uart_seq_lhs.seq_key.get(1);
      `uvm_info(msg, "[half_duplex_data_width_test]", "[LHS Device]", "Get semaphore key and send transfer TX", UVM_MEDIUM)
      uart_seq_lhs.uart_config = uart_lhs_config;
      uart_seq_lhs.start(uart_env.uart_lhs_agt.uart_seqr);
      uart_env.uart_sco.ref_req_seq_queue.push_back(uart_seq_lhs.req);
    end

    if ((i == 0) || (i == 2) || (i == 4)) begin
      uart_seq_rhs.seq_key.get(1);
      `uvm_info(msg, "[half_duplex_data_width_test]", "[RHS Device]", "Get semaphore key and send transfer TX", UVM_MEDIUM)
      uart_seq_rhs.uart_config = uart_rhs_config;
      uart_seq_rhs.start(uart_env.uart_rhs_agt.uart_seqr);
      uart_env.uart_sco.ref_req_seq_queue.push_back(uart_seq_rhs.req);
    end

    // We want both LHS and RHS send req reference to 1 queue only

    // Also send config
    sco_lhs_config = $cast(sco_lhs_config, uart_lhs_config.clone());
    sco_rhs_config = $cast(sco_rhs_config, uart_rhs_config.clone());
    uart_env.uart_sco.config_test_lhs_queue.push_back(sco_lhs_config);
    uart_env.uart_sco.config_test_rhs_queue.push_back(sco_rhs_config);

    #200;
  end

  phase.drop_objection(this);
endtask: run_phase

endclass