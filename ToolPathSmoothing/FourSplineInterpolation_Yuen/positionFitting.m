function [Q, U, Ub] = positionFitting(P, p)
%  [Q, U， Ub] = positionFitting(P, p)对刀尖位置点进行插值，求出控制点
% P为离散的数据点，p为要插值的阶数
% Q为反算出来的控制点，U为节点向量，Ub为向心参数化后得到的参数矢量，在后面求(l,w)离散数据点的时候需要用到

n = size(P, 1) - 1; 

% 向心参数化
Ub = zeros(1, n);
for i = 2:n + 1
    Ub(i) = sqrt(norm(P(i, 1:3) - P(i - 1, 1:3))) + Ub(i - 1);
end
Ub = Ub / Ub(n + 1);

U = zeros(1, n + p + 2);
U(n + 2: n + p + 2) = 1;

% 用均匀化方法得到节点向量
for j = 1:n - p
    for i = j : j + p - 1
        U(j + p + 1) = U(j + p + 1) + Ub(i + 1);
    end
    U(j + p + 1) = U(j + p + 1) / p;
end

% 求系数矩阵。此前参考施法中书中代码写的函数GetBaseFunVal有问题
N = zeros(n + 1, n + 1);
for i = 0:n
    for j = 0:n
        N(i + 1, j + 1) = oneBasisFun(Ub(i + 1), j, p, U);
    end
end

% 求控制点
Q = N\P(:, 1:3);