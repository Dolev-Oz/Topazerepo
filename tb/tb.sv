module tpz_top_tb;

    // Logging levels: 0=OFF, 1=ERROR, 2=WARNING, 3=INFO, 4=DEBUG
    parameter LOG_LEVEL = 4;

    `include "logging.svh"

    parameter NUM_SAMPLES = 3;

    logic clk = 0;
    logic [15:0] audio_mem [0:100000];
    logic [31:0] index = 0;
    logic signed [15:0] data = 0;
    logic rst_n = 0;
    logic signed [15:0] out;

    logic valid = 1'b0;
    logic ready;
    logic serial_data;
    logic lrclk;
    logic bclk;


    always #5 clk = ~clk;

    tpz_top dut (
        .rst_n(rst_n),
        .bclk(bclk),
        .serial_data(serial_data),
        .lrclk(lrclk),

        .out(out)
    );

    sample_to_i2s sample_to_i2s_i (
        .clk(clk),
        .rst_n(rst_n),
        .sample(data),
        .valid(valid),
        .ready(ready),
        .bclk(bclk),
        .serial_data(serial_data),
        .lrclk(lrclk)
    );

    initial begin
        $readmemh("audio.hex", audio_mem);
        rst_n = 0;
        repeat (10) @ (posedge clk);
        rst_n = 1;

        `LOG_INFO($sformatf("Starting simulation... audio_mem[0]=%x", audio_mem[0]));

    end

    always @(posedge clk) begin
        if (~rst_n) begin
            index <= 0;
            valid <= 1'b0;
        end else begin
            valid <= 1'b0;
            if (index >= NUM_SAMPLES) begin
                `LOG_INFO("Reached end of samples. Stopping simulation.");
                $finish;
            end
            if (ready) begin
                index <= index + 1;
                data <= audio_mem[index];
                `LOG_INFO($sformatf("Index=%d  out=%x data=%x", index, out, data));
                valid <= 1'b1;
            end
            `LOG_DEBUG($sformatf("serial_data=%b lrclk=%b bclk=%b", serial_data, lrclk, bclk));
        end
    end
endmodule
