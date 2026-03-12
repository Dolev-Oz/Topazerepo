`timescale 1ns/1ps
module calculate_cosine_tb ();

    `include "logging.svh"

    // Parameters
    localparam NUM_WIDTH = 16;

    // Inputs
    logic clk;
    logic rst_n;
    logic cosine_input_valid;
    logic signed [NUM_WIDTH-1:0] cosine_input;

    // Outputs
    logic ready;
    logic valid;
    logic signed [NUM_WIDTH-1:0] cosine_out;

    // Instantiate the DUT
    calculate_cosine #(
        .NUM_WIDTH(NUM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .cosine_input_valid(cosine_input_valid),
        .cosine_input(cosine_input),
        .ready(ready),
        .valid(valid),
        .cosine_out(cosine_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Test procedure
    initial begin
        // Initialize
        rst_n = 0;
        cosine_input_valid = 0;
        cosine_input = 0;
        #20;
        rst_n = 1;

        // Test vector 1: 0
        send_input(0);

        // Test vector 2: 1
        send_input(1);

        // Test vector 3: -1
        send_input(-1);

        // Test vector 4: 2
        send_input(2);

        // Test vector 5: -2
        send_input(-2);

        // Finish simulation
        #50;
        $finish;
    end

    // Task to send input
    task send_input(input signed [NUM_WIDTH-1:0] value);
        begin
            cosine_input = value;
            cosine_input_valid = 1;
            @(posedge clk);
            cosine_input_valid = 0;
            @(posedge clk);
            `LOG_INFO($sformatf("Time=%0t | Input=%0d | Cosine_out=%0d | expected=%0d", $time, value, cosine_out, $cos(cosine_input)));
        end
    endtask

endmodule
