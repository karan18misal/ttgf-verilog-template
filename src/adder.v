module prefix_add_8(
    input  cin,
    input  [7:0] A,
    input  [7:0] B,
    output [7:0] y,
    output Cout
);

wire [7:0] g;
wire [7:0] p;
wire [7:0] P;
wire [7:0] G;

wire c1, c2, c3, c4, c5, c6, c7;

assign g = A & B;
assign p = A ^ B;

assign P[0] = p[0];
assign P[1] = p[0] & p[1];
assign P[2] = p[0] & p[1] & p[2];
assign P[3] = p[0] & p[1] & p[2] & p[3];
assign P[4] = p[0] & p[1] & p[2] & p[3] & p[4];
assign P[5] = p[0] & p[1] & p[2] & p[3] & p[4] & p[5];
assign P[6] = p[0] & p[1] & p[2] & p[3] & p[4] & p[5] & p[6];
assign P[7] = p[0] & p[1] & p[2] & p[3] & p[4] & p[5] & p[6] & p[7];

assign G[0] = g[0];
assign G[1] = g[1] | (g[0] & p[1]);
assign G[2] = g[2] | (g[1] & p[2]) | (g[0] & p[1] & p[2]);
assign G[3] = g[3] | (g[2] & p[3]) | (g[1] & p[2] & p[3]) | (g[0] & p[1] & p[2] & p[3]);

assign G[4] = g[4] | (g[3] & p[4]) | (g[2] & p[3] & p[4]) |
              (g[1] & p[2] & p[3] & p[4]) | (g[0] & p[1] & p[2] & p[3] & p[4]);

assign G[5] = g[5] | (g[4] & p[5]) | (g[3] & p[4] & p[5]) |
              (g[2] & p[3] & p[4] & p[5]) | (g[1] & p[2] & p[3] & p[4] & p[5]) |
              (g[0] & p[1] & p[2] & p[3] & p[4] & p[5]);

assign G[6] = g[6] | (g[5] & p[6]) | (g[4] & p[5] & p[6]) |
              (g[3] & p[4] & p[5] & p[6]) | (g[2] & p[3] & p[4] & p[5] & p[6]) |
              (g[1] & p[2] & p[3] & p[4] & p[5] & p[6]) |
              (g[0] & p[1] & p[2] & p[3] & p[4] & p[5] & p[6]);

assign G[7] = g[7] | (g[6] & p[7]) | (g[5] & p[6] & p[7]) |
              (g[4] & p[5] & p[6] & p[7]) | (g[3] & p[4] & p[5] & p[6] & p[7]) |
              (g[2] & p[3] & p[4] & p[5] & p[6] & p[7]) |
              (g[1] & p[2] & p[3] & p[4] & p[5] & p[6] & p[7]) |
              (g[0] & p[1] & p[2] & p[3] & p[4] & p[5] & p[6] & p[7]);

assign y[0] = p[0] ^ cin;
assign c1 = G[0] | (P[0] & cin);

assign y[1] = p[1] ^ c1;
assign c2 = G[1] | (P[1] & cin);

assign y[2] = p[2] ^ c2;
assign c3 = G[2] | (P[2] & cin);

assign y[3] = p[3] ^ c3;
assign c4 = G[3] | (P[3] & cin);

assign y[4] = p[4] ^ c4;
assign c5 = G[4] | (P[4] & cin);

assign y[5] = p[5] ^ c5;
assign c6 = G[5] | (P[5] & cin);

assign y[6] = p[6] ^ c6;
assign c7 = G[6] | (P[6] & cin);

assign y[7] = p[7] ^ c7;
assign Cout = G[7] | (P[7] & cin);

endmodule


module CarrySelectAdderCarryGenerator (
    input cl,
    input ch_0,
    input ch_1,
    output wire c_h
);

    wire y;
    assign y = cl | ch_0;
    assign c_h = y & ch_1;

endmodule

module CarrySelectAdderMux_8bit(
    input [7:0] in0,
    input [7:0] in1,
    input C_mux_in,
    output reg [7:0] C_mux_out
);
    always @* begin
        C_mux_out = C_mux_in ? in1 : in0;
    end
endmodule


module modifiedAdder_16bit(
    input Cin,
    input [15:0] A,
    input [15:0] B,
    output [15:0] Sum,
    output Cout
);

    wire [7:0] mux_in0_15_8, mux_in1_15_8;
    wire c8, c16_0, c16_1;

     prefix_add_8  ksa0_7_x(Cin, A[7:0], B[7:0], Sum[7:0], c8);
     prefix_add_8  ksa15_8_0(1'b0, A[15:8], B[15:8], mux_in0_15_8, c16_0);
     prefix_add_8  ksa15_8_1(1'b1, A[15:8], B[15:8], mux_in1_15_8, c16_1);
    CarrySelectAdderMux_8bit mux15_8(mux_in0_15_8, mux_in1_15_8, c8, Sum[15:8]);
    CarrySelectAdderCarryGenerator CG16(c8, c16_0, c16_1, Cout);

endmodule


module CarrySelectAdderMux_16bit(
    input [15:0] in0,
    input [15:0] in1,
    input C_mux_in,
    output reg [15:0] C_mux_out
);
    always @* begin
        C_mux_out = C_mux_in ? in1 : in0;
    end
endmodule


module modifiedAdder_32bit(
    input Cin,
    input [31:0] A,
    input [31:0] B,
    output [31:0] Sum,
    output Cout
);

    wire [15:0] mux_in0_31_16, mux_in1_31_16;
    wire c16, c32_0, c32_1;

    modifiedAdder_16bit ma16_15_0_x(Cin, A[15:0], B[15:0], Sum[15:0], c16);
    modifiedAdder_16bit ma16_31_16_0(1'b0, A[31:16], B[31:16], mux_in0_31_16, c32_0);
    modifiedAdder_16bit ma16_31_16_1(1'b1, A[31:16], B[31:16], mux_in1_31_16, c32_1);
    CarrySelectAdderMux_16bit mux31_16(mux_in0_31_16, mux_in1_31_16, c16, Sum[31:16]);
    CarrySelectAdderCarryGenerator CG32(c16, c32_0, c32_1, Cout);

endmodule


module CarrySelectAdderMux_32bit(
    input [31:0] in0,
    input [31:0] in1,
    input C_mux_in,
    output reg [31:0] C_mux_out
);
    always @* begin
        C_mux_out = C_mux_in ? in1 : in0;
    end
endmodule


module modifiedAdder_64bit(
    input Cin,
    input [63:0] A,
    input [63:0] B,
    output [63:0] Sum,
    output Cout
);

    wire [31:0] mux_in0_63_32, mux_in1_63_32;
    wire c32, c64_0, c64_1;

    modifiedAdder_32bit ma32_31_0_x(Cin, A[31:0], B[31:0], Sum[31:0], c32);
    modifiedAdder_32bit ma32_63_32_0(1'b0, A[63:32], B[63:32], mux_in0_63_32, c64_0);
    modifiedAdder_32bit ma32_63_32_1(1'b1, A[63:32], B[63:32], mux_in1_63_32, c64_1);
    CarrySelectAdderMux_32bit mux63_32(mux_in0_63_32, mux_in1_63_32, c32, Sum[63:32]);
    CarrySelectAdderCarryGenerator CG64(c32, c64_0, c64_1, Cout);

endmodule

module CarrySelectAdderMux_64bit(
    input [63:0] in0,
    input [63:0] in1,
    input C_mux_in,
    output reg [63:0] C_mux_out
);
    always @* begin
        C_mux_out = C_mux_in ? in1 : in0;
    end
endmodule


module modifiedAdder_128bit(
    input Cin,
    input [127:0] A,
    input [127:0] B,
    output [127:0] Sum,
    output Cout
);

    wire [63:0] mux_in0_127_64, mux_in1_127_64;
    wire c64, c128_0, c128_1;

    // Lower 64 bits
    modifiedAdder_64bit ma64_63_0 (
        .Cin(Cin),
        .A(A[63:0]),
        .B(B[63:0]),
        .Sum(Sum[63:0]),
        .Cout(c64)
    );

    // Upper 64 bits assuming carry-in = 0
    modifiedAdder_64bit ma64_127_64_0 (
        .Cin(1'b0),
        .A(A[127:64]),
        .B(B[127:64]),
        .Sum(mux_in0_127_64),
        .Cout(c128_0)
    );

    // Upper 64 bits assuming carry-in = 1
    modifiedAdder_64bit ma64_127_64_1 (
        .Cin(1'b1),
        .A(A[127:64]),
        .B(B[127:64]),
        .Sum(mux_in1_127_64),
        .Cout(c128_1)
    );

    // Select correct upper sum
    CarrySelectAdderMux_64bit mux127_64 (
        .in0(mux_in0_127_64),
        .in1(mux_in1_127_64),
        .C_mux_in(c64),
        .C_mux_out(Sum[127:64])
    );

    // Select correct carry-out
    CarrySelectAdderCarryGenerator CG128 (
        .Cin(c64),
        .Cout0(c128_0),
        .Cout1(c128_1),
        .Cout(Cout)
    );

endmodule