module tb;

    logic bclk = 0;
    logic [15:0] audio_mem [0:1000000];
    logic [31:0] index = 0;
    logic data = 0;
    logic rst_n = 0;
    logic out;


    always #5 bclk = ~bclk;

    tpz_top dut (
        .rst_n(rst_n),
        .bclk(bclk),
        .serial_data(data),
        .lrclk(bclk),    

        .out(out)
    );

    initial begin
         $readmemh("audio.hex", audio_mem);
         rst_n = 0;
         repeat (10) @ (posedge  bclk);
         rst_n = 1;

    end

    always_ff @(posedge bclk) begin
        if (~rst_n)
            index <= 0;
        else begin
            index <= index + 1;
            data <= audio_mem[i];
            $display("Index=%d  out=%b", index, out);    
        end
    end
endmodule