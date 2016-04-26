function [CQ, U, Ubb, NFul] = BSplineMotionFitting(p, P, dominantPIndex, Q, parameterizationmethod)
% 进行有理运动拟合

pCount = size(P, 1);
n = length(dominantPIndex) - 1;
m = n;

global wkDominant; % 特征点权重系数

%% 按照刀尖点进行向心参数化
Ub = zeros(1, pCount);

% 按照对偶四元数进行向心参数化
for i = 2:pCount
%     Ub(i) = sqrt(norm(P(i, 1:3) - P(i - 1, 1:3))); % 只考虑刀尖点的参数化
%     Ub(i) = sqrt(norm(P(i, 1:3) - P(i - 1, 1:3))) + 3 * sqrt(acos((dot(P(i, 4:6), P(i - 1, 4:6))) / norm(P(i, 4:6)) / norm(P(i - 1, 4:6))));  % 综合考虑刀轴矢量和刀尖点位置进行参数化
    if parameterizationmethod == 1
        Ub(i) = sqrt(norm(Q(i, :) - Q(i - 1, :)));
    elseif parameterizationmethod == 2
        Ub(i) = norm(Q(i, :) - Q(i - 1, :));  % 直接利用对偶四元数进行参数化
    elseif parameterizationmethod == 3
        Ub(i) = sqrt(norm(P(i, 1:3) - P(i - 1, 1:3))); % 只考虑刀尖点的参数化
    elseif parameterizationmethod == 4
        Ub(i) = norm(P(i, 1:3) - P(i - 1, 1:3)); % 只考虑刀尖点的参数化
    end
    
    Ub(i) = Ub(i) + Ub(i - 1);
    
end

Ub = Ub / Ub(pCount);
Ubb = Ub;
Ub = Ub(dominantPIndex); % 只取特征点对应的值

% 配置节点向量
U = zeros(1, n + p + 2);
U(1:p + 1) = 0;
U(n + 2:n + p + 2) = 1;
if m == n
    % 如果m = n 使用均匀化方法得到节点矢量
    for j = 0: n + p + 1
         if j <= p
            U(j + 1) = 0;
        elseif j >= n + 1
            U(j + 1) = 1;
        else
            for i = 1:p
                U(j + 1) = U(j + 1) + Ub(j - i + 1);
            end
            U(j + 1) = U(j + 1) / p;
         end
    end
else
    % 否则使用节点配置技术
    for j = 1:n - p
        c = (m + 1) / (n - p + 1);
        i= round(j*c - 0.5);
        alfa = j*c - i;
        U(j + p + 1) = (1 - alfa)*Ubb(i) + alfa*Ubb(i + 1);
    end
end

wk = ones(1, pCount);
wk(dominantPIndex) = wkDominant;

%% 进行最小二乘拟合

% 计算系数矩阵
NFul = zeros(pCount, n + 1);

for i = 1:pCount
    for j = 1:n + 1
        NFul(i, j) = GetBaseFunVal(Ubb(i), j - 1, p, U);
    end
end
N = NFul(2:pCount - 1, 2:n);    % 最小二乘实际上只用到其中的一部分

Ri = Q(2 : pCount - 1, :);
for i = 1:pCount - 2
    N0pUbi = GetBaseFunVal(Ubb(i + 1), 0, p, U);
    NnpUbi = GetBaseFunVal(Ubb(i + 1), n, p, U);
    Ri(i, :) = Ri(i, :) - Q(1, :) * N0pUbi - Q(pCount, :) * NnpUbi;
    Ri(i, :) = Ri(i, :) * wk(i + 1);
end

Q1 = zeros(n + 1, 8);
wkN = N;
for i = 1:pCount - 2
    wkN(i, :) = wk(i + 1) * N(i, :);
end

CQ = zeros(n + 1, 8);
CQ(1, :) = Q(1, :);
CQ(n + 1, :) = Q(pCount, :);

CQ(2:n, :) = (N'*wkN) \ (N'*Ri);    % 求解线性方程组，得到控制点
