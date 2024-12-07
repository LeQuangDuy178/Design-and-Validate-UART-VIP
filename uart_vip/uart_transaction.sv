Here's the code from the image, formatted for readability:

Verilog
class uart_transaction extends uvm_sequence_item;

  // uvm_object_utils(uart_transaction);

  function new(string name = "uart_transaction");
    super.new(name);
  endfunction: new

  /* Instance uart_configuration
   * Then uart_configuration should be compiled first
   * No need object created, just assign attributes to the properties
   * Later set value to configuration -> affect these properties as well*/
  //uart_configuration uart_config = new("uart_config");
  uart_configuration uart_config;

  /* UART properties
   * UART Start bit: 1 bit
   * UART Data: 5 to 9 bits
   * UART Parity bit: 1 bit (opt)
   * UART Baud Rate: 4800, 9600, 19200, 57600 and 115200 integer
   * UART Stop bit: 1 or 2 high bits
   * Enum type for Parity mode
   * Note: Transaction is sent each transfer -> get rid of 1-time configuration
   * Configuration includes parity_mode, baud_rate, stop_bit, data_width
   * All properties is randomized with constraints
   * Data packet need to send: data and parity*/

  rand bit [8:0] data; // Data with dynamic memory access and modify
  rand bit parity; // Value of parity

  // UVM Field register to object factory utilities via field macro

  // Enum transfer_type
  typedef enum bit [1:0] {UNKNOWN = 0, TX = 1, RX = 2} transfer_type_enum;
  transfer_type_enum transfer_type;

  `uvm_object_utils_begin (uart_transaction)
    //`uvm_field_int  (start, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int  (data, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int  (parity, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum (transfer_type_enum, transfer_type, UVM_ALL_ON | UVM_HEX)
    //`uvm_field_int  (stop, UVM_ALL_ON | UVM_HEX)
  `uvm_object_utils_end

  // Constraint
  // * Start high -> IDLE, start low -> TRANSFER
  // * Parity
  //bit [1:0] parity_mode_temp = 0;
constraint parity_constraint {
  if (uart_config.parity_mode == uart_configuration::ODD) {
    if (uart_config.data_width == uart_configuration::WIDTH_5) {
        parity == ~^data[4:0]; // "Not" "bitwise XOR of data with itself"
    } else if (uart_config.data_width == uart_configuration::WIDTH_6) {
        parity == ~^data[5:0]; // "Not" "bitwise XOR of data with itself"
    } else if (uart_config.data_width == uart_configuration::WIDTH_7) {
        parity == ~^data[6:0]; // "Not" "bitwise XOR of data with itself"
    } else if (uart_config.data_width == uart_configuration::WIDTH_8) {
        parity == ~^data[7:0]; // "Not" "bitwise XOR of data with itself"
    } else if (uart_config.data_width == uart_configuration::WIDTH_9) {
        parity == ~^data[8:0]; // "Not" "bitwise XOR of data with itself"
    }
  } else if (uart_config.parity_mode == uart_configuration::EVEN) {
    if (uart_config.data_width == uart_configuration::WIDTH_5) {
        parity == ^data[4:0]; // Data 8'h04 8'h04 0000 -> EVEN
    } else if (uart_config.data_width == uart_configuration::WIDTH_6) {
        parity == ^data[5:0];
    } else if (uart_config.data_width == uart_configuration::WIDTH_7) {
        parity == ^data[6:0];
    } else if (uart_config.data_width == uart_configuration::WIDTH_8) {
        parity == ^data[7:0];
    } else if (uart_config.data_width == uart_configuration::WIDTH_9) {
        parity == ^data[8:0];
    }
  } else {
    parity == 1'b0;
  }
}

endclass: uart_transaction