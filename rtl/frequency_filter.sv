module frequency_filter #(
    parameter SAMPLE_WIDTH = 16
)(
    input logic clk,
    input logic rst_n,
    input logic signed [SAMPLE_WIDTH-1:0] sample_in,
    input logic sample_valid,
    output logic sample_ready,

    output logic signed [SAMPLE_WIDTH-1:0] filtered_out
);

    assign sample_ready = 1'b1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            filtered_out <= 0;
        end else if (sample_valid && sample_ready) begin
            filtered_out <= sample_in;
        end
    end

endmodule
