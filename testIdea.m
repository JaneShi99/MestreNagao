q := 101;
Fq := GF(q);
E := EllipticCurve([Fq!0,0,0,1,1]);  // y^2 = x^3 + x + 1 over F_q

N := #E;              // number of F_q-points (includes O)
t := q + 1 - N;       // trace of Frobenius on H^1
t;