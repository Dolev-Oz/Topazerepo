module calculate_cosine #(
    parameter NUM_WIDTH = 16
) (
    input logic clk,
    input logic rst_n,

    input logic cosine_input_valid,
    input logic signed [NUM_WIDTH-1:0] cosine_input,

    output logic ready,
    output logic valid,
    output logic signed [NUM_WIDTH-1:0] cosine_out
);

    
    logic signed [NUM_WIDTH-1:0] num;
    logic signed [NUM_WIDTH-1:0] num_pow_2;
    logic signed [NUM_WIDTH-1:0] num_pow_4;
    logic signed [NUM_WIDTH-1:0] num_pow_6;
    logic signed [NUM_WIDTH-1:0] num_pow_8;
    logic signed [NUM_WIDTH-1:0] result_multiplied;
    logic signed [NUM_WIDTH-1:0] result;

    // cosine(x): (8! - (8!/2)x^2 + (8!/24)x^4 - (8!/6!)x^6 + x^8) / 8!

    // localparam signed [NUM_WIDTH-1:0] factorial_4 = 'd24;
    // localparam signed [NUM_WIDTH-1:0] factorial_6 = 'd720;
    localparam signed [NUM_WIDTH-1:0] factorial_8 = 'd40320;

    localparam signed [NUM_WIDTH-1:0] coefficient_0 = 'd40320;
    localparam signed [NUM_WIDTH-1:0] coefficient_2 = -'d20160;
    localparam signed [NUM_WIDTH-1:0] coefficient_4 = 'd1680;
    localparam signed [NUM_WIDTH-1:0] coefficient_6 = -'d56;
    localparam signed [NUM_WIDTH-1:0] coefficient_8 = 'd1;
    
    assign num = cosine_input;
    assign num_pow_2 = num * num;
    assign num_pow_4 = num_pow_2 * num_pow_2;
    assign num_pow_6 = num_pow_4 * num_pow_2;
    assign num_pow_8 = num_pow_4 * num_pow_4;

    assign result_multiplied = (coefficient_0 +
        coefficient_2 * num_pow_2 +
        coefficient_4 * num_pow_4 +
        coefficient_6 * num_pow_6 +
        coefficient_8 * num_pow_8);

    assign result = result_multiplied / factorial_8;
    // assign result = cosine_input;

    assign valid = cosine_input_valid;
    assign ready = 1'b1;
    assign cosine_out = result;

endmodule
