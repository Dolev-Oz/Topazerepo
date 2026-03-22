module tpz_top_tb;

    // Logging levels: 0=OFF, 1=ERROR, 2=WARNING, 3=INFO, 4=DEBUG
    parameter LOG_LEVEL = 4;

    `include "include/logging.svh"

    parameter NUM_SAMPLES = 2*1000 * 2; // Fs * time * benchmarks

    logic clk = 0;
    logic [15:0] audio_mem [0:NUM_SAMPLES-1];
    logic [31:0] index = 0;
    logic signed [15:0] data = 0;
    logic rst_n = 0;
    logic signed [15:0] out;

    logic valid = 1'b0;
    logic ready;
    logic serial_data;
    logic lrclk;
    logic bclk;

    logic [255:0] sum = 0;
    logic [63:0] sum_count = 0;

    always #5 clk = ~clk;

    // tpz_top dut (
    //     .rst_n(rst_n),
    //     .bclk(bclk),
    //     .serial_data(serial_data),
    //     .lrclk(lrclk),

    //     .out(out)
    // );

    logic energy_valid;
    logic [127:0] energy;

    goertzel dut (
        .clk(clk),
        .rst_n(rst_n),
        .input_valid(valid),
        .sample(data),
        .valid(energy_valid),
        .energy_normalized(energy)
    );

    initial begin
        $readmemh("C:/Users/UserPC/Downloads/Dolev/FPGA/Topazerepo/audio.hex", audio_mem);
        rst_n = 0;
        repeat (10) @ (posedge clk);
        rst_n = 1;

        $display("Starting simulation... audio_mem[0]=%x", audio_mem[0]);

    end

    always @(posedge clk) begin
        if (~rst_n) begin
            index <= 0;
            valid <= 1'b0;
        end else begin
            valid <= 1'b0;
            if (index >= NUM_SAMPLES) begin
                $display("ans=%d", sum/sum_count);
                $finish;
            end
            index <= index + 1;
            data <= audio_mem[index];
            valid <= 1'b1;
            if (energy_valid) begin
                $display("energy=%d", energy);
                sum <= sum + energy;
                sum_count <= sum_count + 1;
            end
        end
    end
endmodule
