module GPbit(
    input logic a, b, cin,
    output logic g, p, cout);

    assign p = a | b;
    assign g = a & b;
    assign cout = g | (p & cin);

endmodule

module GPblk(
    input logic Gik, Gkj, Pik, Pkj, cin,
    output logic Gij, Pij, cout);

    assign Gij = Gik | (Gkj & Pik);
    assign Pij = Pik & Pkj;
    assign cout = Gij | (Pij & cin);

endmodule

module SUMbit(
    input logic a, b, cin,
    output logic s);

    assign s = a ^ b ^ cin;

endmodule

module Hierarchical_CLA(
    input logic [15:0] A, B,
    input logic cin,
    output logic cout,
    output logic [15:0] Sum);

    logic p0, g0, cout0;
    logic p1, g1, cout1;
    logic p2, g2, cout2;
    logic p3, g3, cout3;
    logic p4, g4, cout4;
    logic p5, g5, cout5;
    logic p6, g6, cout6;
    logic p7, g7, cout7;
    logic p8, g8, cout8;
    logic p9, g9, cout9;
    logic pa, ga, couta;
    logic pb, gb, coutb;
    logic pc, gc, coutc;
    logic pd, gd, coutd;
    logic pe, ge, coute;
    logic pf, gf, coutf;

    logic p10, g10, cout10;
    logic p32, g32, cout32;
    logic p54, g54, cout54;
    logic p76, g76, cout76;
    logic p98, g98, cout98;
    logic p1110, g1110, cout1110;
    logic p1312, g1312, cout1312;
    logic p1514, g1514, cout1514;

    logic g30, p30, cout30;
    logic g74, p74, cout74;
    logic g118, p118, cout118;
    logic g1512, p1512, cout1512;

    logic g70, p70, cout70;
    logic g158, p158, cout158;

    logic g150, p150, cout150;

    SUMbit sum0(A[0], B[0], cin, Sum[0]);
    SUMbit sum1(A[1], B[1], cout0, Sum[1]);
    SUMbit sum2(A[2], B[2], cout10, Sum[2]);
    SUMbit sum3(A[3], B[3], cout2, Sum[3]);
    SUMbit sum4(A[4], B[4], cout30, Sum[4]);
    SUMbit sum5(A[5], B[5], cout4, Sum[5]);
    SUMbit sum6(A[6], B[6], cout54, Sum[6]);
    SUMbit sum7(A[7], B[7], cout6, Sum[7]);
    SUMbit sum8(A[8], B[8], cout70, Sum[8]);
    SUMbit sum9(A[9], B[9], cout8, Sum[9]);
    SUMbit sum10(A[10], B[10], cout98, Sum[10]);
    SUMbit sum11(A[11], B[11], couta, Sum[11]);
    SUMbit sum12(A[12], B[12], cout118, Sum[12]);
    SUMbit sum13(A[13], B[13], coutc, Sum[13]);
    SUMbit sum14(A[14], B[14], cout1312, Sum[14]);
    SUMbit sum15(A[15], B[15], coute, Sum[15]);

    GPbit gpbit0(A[0], B[0], cin, g0, p0, cout0);
    GPbit gpbit1(A[1], B[1], 1'b0, g1, p1, cout1);
    GPbit gpbit2(A[2], B[2], cout10, g2, p2, cout2);
    GPbit gpbit3(A[3], B[3], 1'b0, g3, p3, cout3);
    GPbit gpbit4(A[4], B[4], cout30, g4, p4, cout4);
    GPbit gpbit5(A[5], B[5], 1'b0, g5, p5, cout5);
    GPbit gpbit6(A[6], B[6], cout54, g6, p6, cout6);
    GPbit gpbit7(A[7], B[7], 1'b0, g7, p7, cout7);
    GPbit gpbit8(A[8], B[8], cout70, g8, p8, cout8);
    GPbit gpbit9(A[9], B[9], 1'b0, g9, p9, cout9);
    GPbit gpbit10(A[10], B[10], cout98, ga, pa, couta);
    GPbit gpbit11(A[11], B[11], 1'b0, gb, pb, coutb);
    GPbit gpbit12(A[12], B[12], cout118, gc, pc, coutc);
    GPbit gpbit13(A[13], B[13], 1'b0, gd, pd, coutd);
    GPbit gpbit14(A[14], B[14], cout1312, ge, pe, coute);
    GPbit gpbit15(A[15], B[15], 1'b0, gf, pf, coutf);

    GPblk gpblk10(g1, g0, p1, p0, cin, g10, p10, cout10);
    GPblk gpblk32(g3, g2, p3, p2, 1'b0, g32, p32, cout32);
    GPblk gpblk54(g5, g4, p5, p4, cout30, g54, p54, cout54);
    GPblk gpblk76(g7, g6, p7, p6, 1'b0, g76, p76, cout76);
    GPblk gpblk98(g9, g8, p9, p8, cout70, g98, p98, cout98);
    GPblk gpblk1110(gb, ga, pb, pa, 1'b0, g1110, p1110, cout1110);
    GPblk gpblk1312(gd, gc, pd, pc, cout118, g1312, p1312, cout1312);
    GPblk gpblk1514(gf, ge, pf, pe, 1'b0, g1514, p1514, cout1514);

    GPblk gpblk30(g32, g10, p32, p10, cin, g30, p30, cout30);
    GPblk gpblk74(g76, g54, p76, p54, 1'b0, g74, p74, cout74);
    GPblk gpblk118(g1110, g98, p1110, p98, cout70, g118, p118, cout118);
    GPblk gpblk1512(g1514, g1312, p1514, p1312, 1'b0, g1512, p1512, cout1512);

    GPblk gpblk70(g74, g30, p74, p30, cin, g70, p70, cout70);
    GPblk gpblk158(g1512, g118, p1512, p118, 1'b0, g158, p158, cout158);

    GPblk gpblk150(g158, g70, p158, p70, cin, g150, p150, cout150);

    assign cout = cout150;

endmodule
