module sample_to_i2s (
    input logic clk,
    input logic rst_n,
    input logic signed [15:0] sample,
    input logic valid,
    output logic ready,
    output logic bclk,
    output logic serial_data,
    output logic lrclk
);

    // Logging levels: 0=OFF, 1=ERROR, 2=WARNING, 3=INFO, 4=DEBUG
    parameter LOG_LEVEL = 4;
    
    `include "logging.svh"

    logic [15:0] shift_reg;
    logic [4:0] bit_count;
    logic shift_reg_valid;

    // assign ready = (bit_count == 5'b0) && (lrclk == 1'b0);

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            shift_reg <= 16'b0;
            bit_count <= 5'b0;
            shift_reg_valid <= 1'b0;
            ready <= 1'b1;
        end else begin
            `LOG_DEBUG($sformatf("valid=%b ready=%b sample=%x bit_count=%d", valid, ready, sample, bit_count));
            if (valid && ready) begin
                `LOG_DEBUG($sformatf("Loading new sample into shift register: %x", sample));
                shift_reg <= sample;
                shift_reg_valid <= 1'b1;
                ready <= 1'b0;
            end
        end    
    end

    // drive BCLK and SD, switch channel (LRCLK) after each sample
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            lrclk <= 1'b0;
            serial_data <= 1'b0;
            bclk <= 1'b0;
        end else begin
            if (shift_reg_valid == 1'b1) begin 
                if (bclk == 1'b1) begin
                    if (lrclk == 1'b1) begin
                        serial_data <= shift_reg[15];
                        shift_reg <= {shift_reg[14:0], 1'b0};
                    end else begin
                        serial_data <= 1'b0;
                    end

                    bit_count <= bit_count + 1;
                    if (bit_count == 5'b01111) begin
                        bit_count <= 5'b0;
                        lrclk <= ~lrclk;
                        if (lrclk == 1'b1) begin
                            shift_reg_valid <= 1'b0;
                            ready <= 1'b1;
                            `LOG_INFO($sformatf("Finished transmitting sample. Ready for next sample."));
                        end
                    end
                end
                bclk <= ~bclk;
            end
        end
    end

endmodule