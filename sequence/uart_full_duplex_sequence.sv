class uart_full_duplex_sequence extends uvm_sequence #(uart_transaction);

  `uvm_object_utils(uart_full_duplex_sequence)

  uart_configuration uart_config;

  // Event to wait test trigger for next transfer
  // get (1) and put (1) will get and return permission
  semaphore seq_key = new(1);

  function new(string name = "uart_full_duplex_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    req = uart_transaction::type_id::create("req");
    req.uart_config = this.uart_config;
    start(item(req));

    assert(req.randomize()) else `uvm_error(get_type_name(), "Randomization failed!");
    `uvm_info(get_type_name(), $sformatf("Send req to driver: \n %s", req.sprint()), UVM_HIGH);

    finish_item(req);

    `uvm_info(get_type_name(), "Finish item successful", UVM_MEDIUM);
  endtask: body

endclass: uart_full_duplex_sequence