function Q = CubicSphericalBezier(d1, d2, d3, d4, lam, v)
% 三次球面Bezier曲线，di为控制点，lam为区间长度，v为参数

d = zeros(4, 3, 4);
d(1, :, 1) = d1;
d(2, :, 1) = d2;
d(3, :, 1) = d3;
d(4, :, 1) = d4;

v = v / lam;
for j = 1:3
    for k = 1 : 4 - j
        sita = acos(dot(d(k, :, j), d(k + 1, :, j)));
        d(k, :, j + 1) = (d(k, :, j) * sin(sita * (1 - v)) + d(k + 1, :, j) * sin(sita * v)) / sin(sita);
    end
end

Q = d(1, :, 4);