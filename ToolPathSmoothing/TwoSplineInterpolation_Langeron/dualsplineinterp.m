function [CQ, U] = dualsplineinterp(P, splineorder, toollength)
% 采用两条B样条分别拟合刀尖点和刀轴上一参考点的运动轨迹

Q = zeros(size(P, 1), 6);
Q(:, 1:3) = P(:, 1:3);
Q(:, 4:6) = P(:, 1:3) + toollength * P(:, 4:6);

m = size(Q, 1) - 1;
n = m + 1;

dSum = 0;
Ud = zeros(1, m);
Ud(1) = 0;
for i = 1:m
    Ud(i + 1) = sqrt(norm(Q(i, 1:3) - Q(i + 1, 1:3)));
    dSum = dSum + Ud(i + 1);
end

Ub = Ud / dSum;
for i = 1:m + 1
    if i > 1
        Ub(i) = Ub(i) + Ub(i - 1);
    end
end

U = zeros(1, m + splineorder + 2);
U(m + 2: m + splineorder + 2) = 1;

for j = 1:m - splineorder
    U(j + splineorder + 1) = 0;
    for i = j:j + splineorder - 1
        U(j + splineorder + 1) = U(j + splineorder + 1) + Ub(i + 1);
    end
    U(j + splineorder + 1) = U(j + splineorder + 1) / splineorder;
end

N = zeros(n, m + 1);
for i = 0:m
    uIndex = findSpan(m, splineorder, Ub(i + 1), U);
    tempBasisFuns = basisFuns(uIndex, Ub(i + 1), splineorder, U);
    N(i + 1, uIndex - splineorder + 1 : uIndex + 1) = tempBasisFuns;
end

CQ = N \ Q;