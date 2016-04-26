function Q = QuadraticSphericalBezier(d0, d1, d2, lam, v)
% 计算二次球面Bezier曲线，D为三个控制点，v为自变量参数，lam为区间长度
sita01 = acos(dot(d0, d1));
sita11 = acos(dot(d1, d2));

d01 = (d0 * sin((1 - v/lam) * sita01) + d1 * sin(v / lam * sita01)) / sin(sita01);
d11 = (d1 * sin((1 - v/lam) * sita11) + d2 * sin(v / lam * sita11)) / sin(sita11);

sita = acos(dot(d01, d11));

Q = (d01 * sin((1 - v/lam) * sita) + d11 * sin(v / lam * sita)) / sin(sita);