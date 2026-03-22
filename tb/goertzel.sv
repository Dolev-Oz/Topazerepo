module goertzel #(
    parameter NUM_WIDTH = 32
) (
    input logic clk,
    input logic rst_n,

    input logic input_valid,
    input logic signed [15:0] sample,

    output logic valid,
    output logic signed [4*NUM_WIDTH-1:0] energy_normalized
);

    localparam signed [4*NUM_WIDTH-1:0] coeff = 'd1518500249; // coeff = round(2*cos(2πf/Fs) * 2^30) where f is the target freq and Fs is mic rate
    localparam [31:0] N = 'd128; // min cycels
    
    logic signed [4*NUM_WIDTH-1:0] s0, s1, s2;
    logic [31:0] cycle_count;
    logic [4*NUM_WIDTH-1:0] RMS;

    // logic signed [2*NUM_WIDTH-1:0] energy;

    // assign energy = s1*s1 + s2*s2 - (coeff*s1*s2 >>> 30);

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            s0 <= 0;
            s1 <= 0;
            s2 <= 0;
            energy_normalized <= 0;
            valid <= 0;
            cycle_count <= 0;
            RMS <= 0;            
        end else begin
            if (input_valid) begin
                s0 <= ((sample + ((coeff * s1) >>> 30) - s2));
                s1 <= s0;
                s2 <= s1;
                // $display("CALC: s0=%d, s1=%d, s2=%d, RMS=%d", s0, s1, s2, RMS);
                RMS <= RMS + sample*sample;

                cycle_count <= cycle_count + 1;
                

                if (cycle_count == N) begin 
                    valid <= 1;
                    $display("s1=%d, s2=%d, RMS=%d", s1, s2, RMS);
                    energy_normalized <= (((s1*s1 + s2*s2 - (coeff*s1*s2 >>> 30))))/RMS;
    
                    s0 <= sample;
                    s1 <= 0;
                    s2 <= 0;                    
                    cycle_count <= 1;
                    RMS <= sample*sample;
                end else begin
                    valid <= 0;
                end
            end

        end

    end
endmodule
