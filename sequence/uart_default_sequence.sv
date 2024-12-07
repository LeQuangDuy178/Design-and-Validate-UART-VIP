class uart_default_sequence extends uvm_sequence #(uart_transaction);

  `uvm_object_utils(uart_default_sequence)

  uart_configuration uart_config;

  function new(string name = "uart_default_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    // Create default uart_transaction
    // Randomize 5-bit data and parity
    // Data is directly created
    req = uart_transaction::type_id::create("req");

    req.uart_config = this.uart_config; // Shallow copy uart_config get from tests and pass to transaction
    start(item(req));

    assert(req.randomize() with {req.data == 'h124;}) else `uvm_error(get_type_name(), "Randomization failed!");
    `uvm_info(get_type_name(), $sformatf("Send req to driver: \n %s", req.sprint()), UVM_LOW);

    finish_item(req);
    // Blocking until item_done() is called from driver to exit finish_item()

    `uvm_info(get_type_name(), "Finish item successful", UVM_LOW);

    #100;
  endtask: body

endclass: uart_default_sequence