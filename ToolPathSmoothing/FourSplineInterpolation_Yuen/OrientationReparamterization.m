function WQ = OrientationReparamterization(LW)
% 对（l, w）数据点进行7次多项式拟合。拟合的时候需要进行优化求解

global N;
N = size(LW, 1) - 1;

% LW(:, 1) = LW(:, 1) / LW(N + 1, 1);

global LWData;
LWData = LW;

AeqTemp = [-1 0 0 0 0 0;
           1 -1 0 0 0 0;
           0 1 -1 0 0 0;
           0 0 1 -1 0 0;
           0 0 0 1 -1 0;
           0 0 0 0 1 -1;
           0 0 0 0 0 1];
       
%不等式约束
Aeq = zeros(1, 6 * N);
beq = zeros(1, 1);

% 等式约束
A = zeros(1, 6 * N);
b = zeros(1, 1);

mindeta = 10000;
deta = 0;

% 建立约束矩阵和向量
for k = 1:N
    % 不等式约束
    A(7 * (k - 1) + 1 : 7 * k, 6 * (k - 1) + 1 : 6 * k) = AeqTemp;
    b(7 * (k - 1) + 1) = -LW(k, 2);
    b(7 * k) = LW(k + 1, 2);
    
    % 等式约束
    if k < N
        dlkp1 = LW(k + 2, 1) - LW(k + 1, 1);
        dlk = LW(k + 1, 1) - LW(k, 1);
    
        wk = LW(k + 1, 2);
        
        Aeq(3 * (k - 1) + 1, 6 * (k - 1) + 1 : 6 * (k - 1) + 7) = [0 0 0 0 0 dlkp1 dlk];
        Aeq(3 * (k - 1) + 2, 6 * (k - 1) + 1 : 6 * (k - 1) + 8) = [0 0 0 0 -dlkp1^2 2*dlkp1^2 -2*dlk^2 dlk^2];
        Aeq(3 * (k - 1) + 3, 6 * (k - 1) + 1 : 6 * (k - 1) + 9) = [0 0 0 dlkp1^3 -3*dlkp1^3 3*dlkp1^3 3*dlk^3 -3*dlk^3 dlk^3];
        
        beq(3 * (k - 1) + 1) = wk * (dlkp1 + dlk);
        beq(3 * (k - 1) + 2) = wk * (dlkp1^2 - dlk^2);
        beq(3 * (k - 1) + 3) = wk * (dlkp1^3 + dlk^3);

    end
    
    deta = (LW(k + 1, 2) - LW(k, 2)) / (7 * (LW(k + 1, 1) - LW(k, 1)));
    if deta < mindeta
        mindeta = deta;
    end
end

% 初始条件
Q0 = zeros(6 * N, 1);
for k = 1:N
    detak = (LW(k + 1, 1) - LW(k, 1)) * mindeta;
    
    Q0(6*(k - 1) + 1) = LW(k, 2) + detak;
    Q0(6*(k - 1) + 2) = LW(k, 2) + 2*detak;
    Q0(6*(k - 1) + 3) = LW(k, 2) + 3*detak;
    Q0(6*(k - 1) + 4) = LW(k + 1, 2) - 3*detak;
    Q0(6*(k - 1) + 5) = LW(k + 1, 2) - 2*detak;
    Q0(6*(k - 1) + 6) = LW(k + 1, 2) - detak;
end

options = optimset('LargeScale', 'off');
[Q16, fval] = fmincon(@OrientationObjectiveFunction, Q0, A, b, Aeq, beq);

WQ = zeros(8 * N, 1);
for k = 1:N
    WQ(8 * (k - 1) + 1) = LW(k, 2);
    WQ(8 * (k - 1) + 2: 8 * k - 1) = Q16(6*(k - 1) + 1 : 6 * k);
    WQ(8 * k) = LW(k + 1, 2);
end

% 清除全局变量
clear LWData
clear N
clear Q1
clear Q2
clear Q3
clear Q4
clear Q5
clear Q6
clear wk_1
clear wk