function Q = QuinticSphericalBezier(d1, d2, d3, d4, d5, d6, lam, v)
% 三次球面Bezier曲线，di为控制点，lam为区间长度，v为参数

d = zeros(6, 3, 6);
d(1, :, 1) = d1;
d(2, :, 1) = d2;
d(3, :, 1) = d3;
d(4, :, 1) = d4;
d(5, :, 1) = d5;
d(6, :, 1) = d6;

v = v / lam;
for j = 1:5
    for k = 1 : 6 - j
        sita = acos(dot(d(k, :, j), d(k + 1, :, j)));
        d(k, :, j + 1) = (d(k, :, j) * sin(sita * (1 - v)) + d(k + 1, :, j) * sin(sita * v)) / sin(sita);
    end
end

Q = d(1, :, 6);