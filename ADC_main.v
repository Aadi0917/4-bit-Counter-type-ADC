// starting with a 4 bit async. up counter using D flip flops
module d_flipflop (
    input  D,
    input  clk,
    input  rst,      
    output reg Q,
    output QB
);
    always @(negedge clk or posedge rst) begin
        if (rst)
            Q <= 1'b0;
        else
            Q <= D;
    end

    assign QB = ~Q;
endmodule

module async_counter_4bit (
    input  CLK_OUT,       
    input  rst,
    output [3:0] Q
);
    wire QB0, QB1, QB2, QB3;

    
    d_flipflop ff0 (
        .D(QB0),
        .clk(CLK_OUT),
        .rst(rst),
        .Q(Q[0]),
        .QB(QB0)
    );

    d_flipflop ff1 (
        .D(QB1),
        .clk(QB0),
        .rst(rst),
        .Q(Q[1]),
        .QB(QB1)
    );

    
    d_flipflop ff2 (
        .D(QB2),
        .clk(QB1),
        .rst(rst),
        .Q(Q[2]),
        .QB(QB2)
    );

    
    d_flipflop ff3 (
        .D(QB3),
        .clk(QB2),
        .rst(rst),
        .Q(Q[3]),
        .QB(QB3)
    );

endmodule

// Now the output of counter is connected to a 4-bit Weighted Resistor DAC to convert the digital count to an analog voltage

module dac_4bit (
    input  [3:0] Q,        // Q3,Q2,Q1,Q0 from counter, Q3=MSB and Q0 =LSB
    output real Vdac
);
    parameter real VREF = 5.0;
    parameter real R1   = 1000;   // MSB = Q3
    parameter real R2   = 2000;   // Q2
    parameter real R4   = 4000;   // Q1
    parameter real R8   = 8000;   // LSB = Q0
    parameter real RF   = 1600;   // feedback resistor

    
    
    assign Vdac = (Q[3]*VREF*RF/R1)
                + (Q[2]*VREF*RF/R2)
                + (Q[1]*VREF*RF/R4)
                + (Q[0]*VREF*RF/R8);
    
endmodule

// Now the output of DAC is connected to a comparator to compare the analog voltage with a reference voltage

module comparator (
    input  real Va,      // non-inverting input
    input  real Vdac,    // inverting input
    output reg  Vc       // comparator output
);
    parameter real V_high = 1.0;   
    parameter real V_low = 0.0;   

    always @(*) begin
        if (Va > Vdac)
            Vc = V_high;
        else
            Vc = V_low;
    end
endmodule

module and_gate(
    input Vc,
    input CLK_IN,
    output  CLK_OUT);

    
    assign  CLK_OUT = Vc & CLK_IN; //Now the output of AND gate is connected to the clock input of the counter 
    

    

endmodule



// Now Instantiating the ADC module block

module adc(
    input        CLK_IN,
    input        rst,
    input  real  Va,

    output [3:0] D_out,
    output real  Vdac,
    output        Vc
);

    wire CLK_OUT;
    wire [3:0] Q;

    // AND Gate
    and_gate U1(
        .Vc(Vc),
        .CLK_IN(CLK_IN),
        .CLK_OUT(CLK_OUT)
    );

    // 4-bit Async. Counter
    async_counter_4bit U2(
        .CLK_OUT(CLK_OUT),
        .rst(rst),
        .Q(Q)
    );

    // DAC
    dac_4bit U3(
        .Q(Q),
        .Vdac(Vdac)
    );

    // Comparator
    comparator U4(
        .Va(Va),
        .Vdac(Vdac),
        .Vc(Vc)
    );

    
    assign D_out = Q; //ADC Digital Output

endmodule








