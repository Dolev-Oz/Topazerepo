module i2s_to_avalon_st #(
    parameter SAMPLE_WIDTH=16
) (
    input logic rst_n,
    input logic bclk,
    input logic serial_data,
    input logic lrclk,

    input logic ready,
    output logic valid,
    output logic signed [SAMPLE_WIDTH-1:0] sample
);

    `include "logging.svh"

    logic [SAMPLE_WIDTH-1:0] shift_reg;
    logic [5:0] bit_count; // Assuming a maximum of 64 bits per sample
    logic lrclk_d; // Delayed version of lrclk for edge detection

`ifdef SIMULATION
    always @(posedge bclk or negedge rst_n) begin
`else
    always_ff @(posedge bclk or negedge rst_n) begin
`endif
        if (~rst_n) begin
            bit_count <= 0;
            shift_reg <= 0;
            lrclk_d <= 0;
        end
        else begin
            lrclk_d <= lrclk; // Delay lrclk for edge detection
            if (lrclk != lrclk_d) begin
                // Start of a new sample
                bit_count <= 0;
            end else if (bit_count < SAMPLE_WIDTH) begin
                // Shift in the serial data
                shift_reg <= {shift_reg[SAMPLE_WIDTH-2:0], serial_data};
                bit_count <= bit_count + 1;
                `LOG_DEBUG($sformatf("Shifting in bit: %b, shift_reg=%b, bit_count=%d", serial_data, shift_reg, bit_count));
            end
        end
    end

    always_ff @(posedge bclk or negedge rst_n) begin
        if (~rst_n) begin
            valid <= 1'b0;
            sample <= 0;
        end
        else begin
            if (bit_count == SAMPLE_WIDTH - 1) begin
                sample <= shift_reg;
                valid <= 1'b1;
                bit_count <= 0;
                `LOG_WARNING($sformatf("Captured sample: %x", shift_reg));
            end else begin
                valid <= 1'b0;
                sample <= 0;
            end
        end
    end

endmodule
