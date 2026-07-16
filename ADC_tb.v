`timescale 1ns/1ns

module adc_tb;

    // Inputs
    reg CLK_IN;
    reg rst;
    real Va;

    // Outputs
    wire [3:0] D_out;
    wire Vc;
    real Vdac;

    // Instantiate ADC
    adc DUT (
        .CLK_IN(CLK_IN),
        .rst(rst),
        .Va(Va),
        .D_out(D_out),
        .Vdac(Vdac),
        .Vc(Vc)
    );

    // Clock Generation (10 ns period)
    initial begin
        CLK_IN = 0;
        always #5 CLK_IN = ~CLK_IN;
    end



    // Test Sequence
    initial begin

        // Initialize
        rst = 1;
        Va  = 2.75;      // Analog input voltage

        #20;
        rst = 0;

        // Allow conversion to complete
        #300;

        $finish;

    end

    // Monitor
    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, adc_tb);
       
    end

endmodule