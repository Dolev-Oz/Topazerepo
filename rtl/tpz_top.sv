module tpz_top # (
    parameter SAMPLE_WIDTH = 16
) (
    input logic rst_n,
    input logic bclk,
    input logic serial_data,
    input logic lrclk,
    
    output logic signed [SAMPLE_WIDTH-1:0] out
); 

    // ready, data, valid,rst

    logic signed [15:0] sample;
    logic sample_valid;
    logic sample_ready;

    i2s_to_avalon_st #(.SAMPLE_WIDTH(SAMPLE_WIDTH))
     i_i2s_to_avalon_st(
        .rst_n(rst_n),
        .bclk(bclk),
        .serial_data(serial_data),
        .lrclk(lrclk),
        .ready(sample_ready),
        .sample(sample),
        .valid(sample_valid)
    );

    frequency_filter #(.SAMPLE_WIDTH(SAMPLE_WIDTH))
     i_frequency_filter(
        .clk(bclk),
        .rst_n(rst_n),
        .sample_in(sample),
        .sample_valid(sample_valid),
        .sample_ready(sample_ready),
        .filtered_out(out)
    );


endmodule
