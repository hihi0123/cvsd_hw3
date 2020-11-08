module sort3 (
	  input   [ 7 : 0 ]   A,
    input   [ 7 : 0 ]   B,
    input   [ 7 : 0 ]   C,

	  output	[ 7 : 0 ]   max,
    output	[ 7 : 0 ]   mid,
    output	[ 7 : 0 ]   min
);

reg     [7:0]   max_w, min_w, mid_w;

assign max = max_w;
assign mid = mid_w;
assign min = min_w;

always@(*) begin
    if(A>=B) begin
        if(B>=C) begin
            max_w = A;
            mid_w = B;
            min_w = C;
        end
        else begin
            if(A>=C) begin
                max_w = A;
                mid_w = C;
                min_w = B;
            end
            else begin
                max_w = C;
                mid_w = A;
                min_w = B;
            end
        end
    end
    else begin
        if(A>=C) begin
            max_w = B;
            mid_w = A;
            min_w = C;
        end
        else begin
            if(B>=C) begin
                max_w = B;
                mid_w = C;
                min_w = A;
            end
            else begin
                max_w = C;
                mid_w = B;
                min_w = A;
            end
        end
    end

end


endmodule




/*##########################################################*/

module sort33 (
	  input   [ 7 : 0 ]   x11,
    input   [ 7 : 0 ]   x21,
    input   [ 7 : 0 ]   x31,

    input   [ 7 : 0 ]   x12,
    input   [ 7 : 0 ]   x22,
    input   [ 7 : 0 ]   x32,

    input   [ 7 : 0 ]   x13,
    input   [ 7 : 0 ]   x23,
    input   [ 7 : 0 ]   x33,

	  output	[ 7:0]	    o11,
    output	[ 7:0]	    o21,
    output	[ 7:0]	    o31,

    output	[ 7:0]	    o12,
    output	[ 7:0]	    o22,
    output	[ 7:0]	    o32,

    output	[ 7:0]	    o13,
    output	[ 7:0]	    o23,
    output	[ 7:0]	    o33
);

wire        [7:0]       maxa, mida, mina;
wire        [7:0]       maxb, midb, minb;
wire        [7:0]       maxc, midc, minc;

sort3 s3a(
	  .A(x11),
    .B(x21),
    .C(x31),

	  .max(maxa),
    .mid(mida),
    .min(mina)
);
sort3 s3(
	  .A(x12),
    .B(x22),
    .C(x32),

	  .max(maxb),
    .mid(midb),
    .min(minb)
);
sort3 s3c(
	  .A(x13),
    .B(x23),
    .C(x33),

	  .max(maxc),
    .mid(midc),
    .min(minc)
);


assign  o11 = maxa;
assign  o21 = mida;
assign  o31 = mina;

assign  o12 = maxb;
assign  o22 = midb;
assign  o32 = mina;

assign  o13 = maxc;
assign  o23 = midc;
assign  o33 = minc;



endmodule

/*##########################################################*/

module mid9 (
	  input   [ 7 : 0 ]   x11,
    input   [ 7 : 0 ]   x21,
    input   [ 7 : 0 ]   x31,

    input   [ 7 : 0 ]   x12,
    input   [ 7 : 0 ]   x22,
    input   [ 7 : 0 ]   x32,

    input   [ 7 : 0 ]   x13,
    input   [ 7 : 0 ]   x23,
    input   [ 7 : 0 ]   x33,

  	output	[ 7:0]	    ans
);
wire        [7:0]       t11,t21, t31;
wire        [7:0]       t12,t22, t32;
wire        [7:0]       t13,t23, t33;

wire        [7:0]       max1,max2, max3;
wire        [7:0]       mid1,mid2, mid3;
wire        [7:0]       min1,min2, min3;

wire        [7:0]       max, mid, min;

sort33 sort33_1(
	  .x11(x11),
    .x21(x21),
    .x31(x31),

    .x12(x12),
    .x22(x22),
    .x32(x32),

    .x13(x13),
    .x23(x23),
    .x33(x33),

  	.o11(t11),
    .o21(t21),
    .o31(t31),

    .o12(t12),
    .o22(t22),
    .o32(t32),

    .o13(t13),
    .o23(t23),
    .o33(t33)
);

sort33 sort33_2(
	  .x11(t11),
    .x21(t12),
    .x31(t13),

    .x12(t21),
    .x22(t22),
    .x32(t23),

    .x13(t31),
    .x23(t32),
    .x33(t33),

	  .o11(max1),
    .o21(max2),
    .o31(max3),

    .o12(mid1),
    .o22(mid2),
    .o32(mid3),

    .o13(min1),
    .o23(min2),
    .o33(min3)
);
sort3 s3a(
  	.A(max3),
    .B(mid2),
    .C(min1),

  	.max(max),
    .mid(mid),
    .min(min)
);




assign ans = mid; 


endmodule