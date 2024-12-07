// Multi-port analysis import to scoreboard declare
`uvm_analysis_imp_decl(_lhs);
`uvm_analysis_imp_decl(_rhs);

class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard)

  local string msg = "[UART_VIP] [UART_SCOREBOARD]";

  // Coverage properties
  `include "../uart_vip/uart_coverage.sv"

  //uart_group
  bit sfc_enb = 1;
  uart_group_lhs;

  /* TLM analysis import export */
  uvm_analysis_imp_lhs #(uart_transaction, uart_scoreboard) lhs_item_collected_export;
  uvm_analysis_imp_rhs #(uart_transaction, uart_scoreboard) rhs_item_collected_export;

  // Checker properties
  bit checker_enb = 1;

  uart_transaction sco_lhs_queue[$];
  uart_transaction sco_rhs_queue[$];

  uart_transaction sco_lhs_trans;
  uart_transaction sco_rhs_trans;

  uart_transaction req_seq_lhs_queue[$];
  uart_transaction req_seq_rhs_queue[$];

  bit [8:0] req_seq_lhs_data_width_queue[$];
  bit [8:0] req_seq_rhs_data_width_queue[$];

  uart_transaction ref_req_seq_queue[$];
bit [8:0] ref_req_data_width_queue[$];

uart_configuration config_test_lhs_queue[$];
uart_configuration config_test_rhs_queue[$];

function new(string name = "uart_scoreboard", uvm_component parent);
  super.new(name, parent);
  uart_group = new();
endfunction: new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info({msg, "[build_phase]"}, $sformatf("Entered..."), UVM_MEDIUM);

    lhs_item_collected_export = new("lhs_item_collected_export", this);
    rhs_item_collected_export = new("rhs_item_collected_export", this);

    sco_lhs_trans = uart_transaction::type_id::create("sco_lhs_trans");
    sco_rhs_trans = uart_transaction::type_id::create("sco_rhs_trans");

    uart_config_cov = uart_configuration::type_id::create("uart_config_cov");
    uart_trans_cov = uart_transaction::type_id::create("uart_trans_cov");
    //uart_group = new();

    `uvm_info({msg, "[build_phase]"}, $sformatf("Exited..."), UVM_MEDIUM);

  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
  endtask: run_phase

  virtual task check_phase(uvm_phase phase);
  endtask: check_phase

  virtual function void report_phase(uvm_phase phase);

  `uvm_info({msg, "[report_phase]"}, "Report phase implement", UVM_MEDIUM);
  `uvm_info({msg, "[report_phase]"}, "Report test status", UVM_LOW);

  for (int i = 0; i < config_test_lhs_queue.size(); i++) begin
    `uvm_info({msg, "[report_phase]", "[LHS]"}, $sformatf("Report LHS config: \n%s", config_test_lhs_queue[i].sprint()), UVM_LOW);
    $cast(uart_config_cov, config_test_lhs_queue[i]);
    uart_group.sample();
  end

  for (int i = 0; i < config_test_rhs_queue.size(); i++) begin
    `uvm_info({msg, "[report_phase]", "[RHS]"}, $sformatf("Report RHS config: \n%s", config_test_rhs_queue[i].sprint()), UVM_LOW);
    $cast(uart_config_cov, config_test_rhs_queue[i]);
    uart_group.sample();
  end

  for (int i = 0; i < req_seq_lhs_queue.size(); i++) begin
    `uvm_info({msg, "[report_phase]", "[LHS]"}, $sformatf("Report req item: \n%s", req_seq_lhs_queue[i].sprint()), UVM_LOW);

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_5) begin
      req_seq_lhs_data_width_queue.push_back(req_seq_lhs_queue[i].data[4:0]);
    end

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_6) begin
      req_seq_lhs_data_width_queue.push_back(req_seq_lhs_queue[i].data[5:0]);
    end

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_7) begin
      req_seq_lhs_data_width_queue.push_back(req_seq_lhs_queue[i].data[6:0]);
    end

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_8) begin
      req_seq_lhs_data_width_queue.push_back(req_seq_lhs_queue[i].data[7:0]);
    end

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_9) begin
      req_seq_lhs_data_width_queue.push_back(req_seq_lhs_queue[i].data[8:0]);
    end
  end

  for (int i = 0; i < req_seq_rhs_queue.size(); i++) begin
    `uvm_info({msg, "[report_phase]", "[RHS]"}, $sformatf("Report req item: \n%s", req_seq_rhs_queue[i].sprint()), UVM_LOW);

    if (config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_5) begin
      req_seq_rhs_data_width_queue.push_back(req_seq_rhs_queue[i].data[4:0]);
    end

    if (config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_6) begin
      req_seq_rhs_data_width_queue.push_back(req_seq_rhs_queue[i].data[5:0]);
    end

    if (config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_7) begin
      req_seq_rhs_data_width_queue.push_back(req_seq_rhs_queue[i].data[6:0]);
    end

    if (config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_8) begin
      req_seq_rhs_data_width_queue.push_back(req_seq_rhs_queue[i].data[7:0]);
    end

    if (config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_9) begin
      req_seq_rhs_data_width_queue.push_back(req_seq_rhs_queue[i].data[8:0]);
    end
  end

  for (int i = 0; i < ref_req_seq_queue.size(); i++) begin
    `uvm_info({msg, "[report_phase]"}, $sformatf("Report req item: \n%s", ref_req_seq_queue[i].sprint()), UVM_LOW);

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_5 || config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_5) begin
      ref_req_data_width_queue.push_back(ref_req_seq_queue[i].data[4:0]);
    end

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_6 || config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_6) begin
      ref_req_data_width_queue.push_back(ref_req_seq_queue[i].data[5:0]);
    end

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_7 || config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_7) begin
      ref_req_data_width_queue.push_back(ref_req_seq_queue[i].data[6:0]);
    end

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_8 || config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_8) begin
      ref_req_data_width_queue.push_back(ref_req_seq_queue[i].data[7:0]);
    end

    if (config_test_lhs_queue[i].data_width == uart_configuration::WIDTH_9 || config_test_rhs_queue[i].data_width == uart_configuration::WIDTH_9) begin
      ref_req_data_width_queue.push_back(ref_req_seq_queue[i].data[8:0]);
    end
  end

  for (int i = 0; i < sco_lhs_queue.size(); i++) begin
  if (sco_lhs_queue[i].transfer_type == uart_transaction::RX && req_seq_rhs_queue.size() > 0) begin
    // For full-duplex, need to compare TX
    sco_lhs_queue.delete(i); // Delete as this index so the TX element is decrease 1 index
  end
end

  // Cannot pop front because size() will reduce
  // If pop front() then wait for size() = 0 then stop
  // After delete(), size() is reduce
  for (int i = 0; i < sco_lhs_queue.size(); i++) begin
    sco_lhs_trans = sco_lhs_queue.pop_front();

    if (sco_lhs_queue[i].transfer_type == uart_transaction::RX && req_seq_rhs_queue.size() > 0) begin
      // For full-duplex, need to compare TX
      sco_lhs_queue.delete(i); // Delete as this index so the TX element is decrease 1 index
    end

    `uvm_info({msg, "[report_phase]", "[LHS]"}, $sformatf("Report transaction data: \n%s", sco_lhs_queue[i].sprint()), UVM_LOW);
  end

  for (int i = 0; i < sco_rhs_queue.size(); i++) begin
    if (sco_rhs_queue[i].transfer_type == uart_transaction::RX && req_seq_rhs_queue.size() > 0) begin
      // For full-duplex, need to compare TX
      sco_rhs_queue.delete(i); // Delete as this index so the TX element is decrease 1 index
    end

    `uvm_info({msg, "[report_phase]", "[RHS]"}, $sformatf("Report transaction data: \n%s", sco_rhs_queue[i].sprint()), UVM_LOW);
  end

  //------------------------------------------------------------------------------------------
  // Checker Implementation
// Tracking data integrity based on config and transaction
// Perform in queue loop

// Checker Implementation
// Tracking data integrity based on config and transaction
// Perform in queue loop

if (checker_enb) begin
  if (ref_req_seq_queue.size() > 0) begin
    for (int i = 0; i < sco_lhs_queue.size(); i++) begin
      if (sco_lhs_queue[i].data == ref_req_data_width_queue[i] && sco_lhs_queue[i].parity == ref_req_seq_queue[i].parity) begin
        `uvm_info({msg, "[report_phase]", "[LHS]"}, "Successful data integrity compare", UVM_LOW);
      else begin
        `uvm_error(m{sg, "[report_phase]", "[LHS]"}, "Failed data integrity compare");
      end
    end
    end end else if (req_seq_lhs_queue.size() > 0) begin
    for (int i = 0; i < sco_lhs_queue.size(); i++) begin
      if (sco_lhs_queue[i].transfer_type == uart_transaction::RX) begin
        // For full-duplex, need to compare TX
        sco_lhs_queue.delete(i); // Delete as this index so the TX element is decrease 1 index
      end

      if (sco_lhs_queue[i].data == req_seq_lhs_data_width_queue[i] && sco_lhs_queue[i].parity == req_seq_lhs_queue[i].parity) begin
        `uvm_info({msg, "[report_phase]", "[LHS]"}, "Successful data integrity compare", UVM_LOW);
      else begin
        `uvm_error({msg, "[report_phase]", "[LHS]"}, "Failed data integrity compare");
      end
    end
    end end else if (ref_req_seq_queue.size() > 0) begin
    for (int i = 0; i < sco_rhs_queue.size(); i++) begin
      if (sco_rhs_queue[i].data == ref_req_data_width_queue[i] && sco_rhs_queue[i].parity == ref_req_seq_queue[i].parity) begin
        `uvm_info({msg, "[report_phase]", "[RHS]"}, "Successful data integrity compare", UVM_LOW);
      else begin
        `uvm_error({msg, "[report_phase]", "[RHS]"}, "Failed data integrity compare");
      end
    end
    end end

  if (req_seq_rhs_queue.size() > 0) begin
  for (int i = 0; i < sco_rhs_queue.size(); i++) begin
    if (sco_rhs_queue[i].transfer_type == uart_transaction::RX) begin
      // For full-duplex, need to compare TX
      sco_rhs_queue.delete(i); // Delete as this index so the TX element is decrease 1 index
    end

    if (sco_rhs_queue[i].data == req_seq_rhs_data_width_queue[i] && sco_rhs_queue[i].parity == req_seq_rhs_queue[i].parity) begin
      `uvm_info({msg, "[report_phase]", "[RHS]"}, "Successful data integrity compare", UVM_LOW);
    else begin
      `uvm_error({msg, "[report_phase]", "[RHS]"}, "Failed data integrity compare");
    end
  end
  end 
  end
  end
  else begin
    `uvm_info({msg, "[report_phase]"}, "Handling expected errors", UVM_LOW);
    `uvm_info({msg, "[report_phase]"}, "########### TEST PASSED #########", UVM_LOW);
  end

  endfunction: report_phase

  // Multi-export write functions for 2 agents (2 monitors)
  // Via imp decl, sco export understand which agent to get the import to
  // In monitor capture tx or rx -> write to port -> export understand which agents
  // In env, connect 2 agents' monitor to 2 analysis exports corresponding
  // Monitor send packet to analysis port of lhs/rhs, get by according export
  // Argument inside is shared reference, dynamically modified each transfer
  // Need an independent copies to capture corresponding data
  // Using clone deep copy of dynamic transaction then cast them to variants

  extern virtual function void write_lhs(uart_transaction uart_trans_lhs);
  extern virtual function void write_rhs(uart_transaction uart_trans_rhs);

endclass: uart_scoreboard

function void uart_scoreboard::write_lhs(uart_transaction uart_trans_lhs);
  `uvm_info({msg, "[LHS]"}, $sformatf("Get transaction lhs: \n%s", uart_trans_lhs.sprint()), UVM_HIGH);

  $cast(sco_lhs_trans, uart_trans_lhs.clone());
  sco_lhs_queue.push_back(sco_lhs_trans);

  $cast(uart_trans_cov, sco_lhs_trans);
  uart_group.sample();
endfunction: write_lhs

function void uart_scoreboard::write_rhs(uart_transaction uart_trans_rhs);
  `uvm_info({msg, "[RHS]"}, $sformatf("Get transaction rhs: \n%s", uart_trans_rhs.sprint()), UVM_HIGH);

  $cast(sco_rhs_trans, uart_trans_rhs.clone());
  sco_rhs_queue.push_back(sco_rhs_trans);

  $cast(uart_trans_cov, sco_rhs_trans);
  uart_group.sample();
endfunction: write_rhs