function [QIterat, ErrCL, ErrRL, U3, dominantPAf, NFul] = iterativeFitting(Q, U, Ub, DQ, p, P, dominantPIndex, IteratErrLimit, NFul)
%对曲线进行迭代拟合。先计算出拟合误差，在超过误差限的地方增加特征点
%   此处显示详细说明

global toolLength;
global wkDominant; % 特征点权重系数


global p0;  % 定义的0号点

% 求出对应参数u下的Q，从而得到刀尖点和刀具参考点的坐标
pNum = 1;
% 将刀尖点和刀具参考点进行齐次坐标表示
p1 = p0;
p1(1, 4) = 1;

dominantPi = 1;  % 当前点所在特征点的段，及i在[dominantPIndex(dominantPi), dominantPIndex(dominantPi + 1))中
dominantNum = 1; % 当前特征点总数
maxErr = 0;     % 两特征点间的最大误差
maxErrIndex = dominantPIndex(dominantPi); % 最大误差所对应的索引值
ChangedFlag = 0;    % 特征点改变标志，此标志为0则表示特征点没有修改，无需重新计算，为1则表示要进行重新计算

pCount = size(P, 1);

ErrCL = zeros(1, pCount);   % 刀尖点误差
ErrRL = zeros(1, pCount);   % 刀轴参考点误差

% 这里求出刀尖点位置与拟合出来的曲线的误差
for i = 1:pCount
    % 先找到当前点所在特征点段, i在[dominantPIndex(dominantPi), dominantPIndex(dominantPi + 1))

    % 计算误差
%     Qtemp = curvePoint(p, U, Q, Ub(i));
    Qtemp = NFul(i, :) * Q;     % 直接利用系数矩阵相乘得到插值点，减少计算量

    pFit = TransformViaQ(p1(1:3), Qtemp);
    
    ErrCL(i) = norm(P(i, 1:3) - pFit(1:3));
% 	ErrRL(i) = acos(dot((p2Fit - pFit) / norm((p2Fit - pFit)), P(i, 4:6) / norm(P(i, 4:6)))) * 180 / pi;	% 计算刀轴矢量的角度偏差
    % ErrRL(i) = norm(P(i, 1:3) + toolLength * P(i, 4:6)  - p2Fit(1:3));
    
    % 找到超过误差限的最大误差对应的点
    if ErrCL(i) > maxErr && ErrCL(i) > IteratErrLimit && i ~= dominantPIndex(dominantPi) && i~= dominantPIndex(dominantPi + 1)
        maxErr = ErrCL(i);
        maxErrIndex = i;
    end
    
    % 说明此段已经搜索完毕
    if i == dominantPIndex(dominantPi + 1)
        % 保存起点
        dominantP(dominantNum) = dominantPIndex(dominantPi);
        dominantNum = dominantNum + 1;
        % 如果最大误差超过误差限，则将此索引值保存起来
        if maxErr ~= 0 && maxErrIndex ~= dominantPIndex(dominantPi)
            ChangedFlag = 1;
            dominantP(dominantNum) = maxErrIndex;
            dominantNum = dominantNum + 1;
        end
        
        dominantPi = dominantPi + 1;
        maxErr = 0;
        maxErrIndex = dominantPIndex(dominantPi);
    end
end
dominantP(dominantNum) = dominantPIndex(dominantPi);    % 保存最后的一个特征点

if ChangedFlag ~= 0

    % 如果特征点发生变化，则要进行重新拟合
    n = length(dominantP) - 1;
  %  m = size(P, 1) - 1;
    m = n;
    Ubb = Ub(dominantP);
    
    % 求节点向量
    U2 = zeros(1, n + p + 2);  
    if m == n
        for j = 0 : n + p + 1
            if j <= p
                U2(j + 1) = 0;
            elseif j >= n + 1
                U2(j + 1) = 1;
            else
                for i = 1:p
                    U2(j + 1) = U2(j + 1) + Ubb(j - i + 1);
                end
                U2(j + 1) = U2(j + 1) / p;
            end
        end
    else
        for j = 1:n - p
            c = (m + 1) / (n - p + 1);
            i = round(j * c - 0.5);
            alfa = j * c - i;
            U2(j + p + 1) = (1 - alfa) * Ub(i) + alfa * Ub(i + 1);
        end
    end
    
%     % 求系数矩阵
%     for i = 1 : pCount - 2
%         for j = 1 : n - 1
%             N(i, j) = GetBaseFunVal(Ub(i + 1), j, p, U2);
%         end
%     end
    
    % 计算系数矩阵
    NFul = zeros(pCount, n + 1);

    for i = 1:pCount
        for j = 1:n + 1
            NFul(i, j) = GetBaseFunVal(Ub(i), j - 1, p, U2);
        end
    end
    N = NFul(2:pCount - 1, 2:n);    % 最小二乘实际上只用到其中的一部分

    
    wk = ones(1, pCount);
    wk(dominantP) = wkDominant;
    
    Ri = DQ(2 : pCount - 1, :);
    for i = 1:pCount - 2
        N0pUbi = GetBaseFunVal(Ub(i + 1), 0, p, U2);
        NnpUbi = GetBaseFunVal(Ub(i + 1), n, p, U2);
        Ri(i, :) = Ri(i, :) - DQ(1, :) * N0pUbi - DQ(pCount, :) * NnpUbi;
        Ri(i, :) = Ri(i, :) * wk(i + 1);
    end
    
    wkN = N;
    for i = 1:pCount - 2
        wkN(i, :) = wk(i + 1) * N(i, :);
    end
    
    Q = zeros(n + 1, 8);
    Q(1, :) = DQ(1, :);
    Q(n + 1, :) = DQ(pCount, :);
    % 根据是否进行优化标志位的设置选择是否进行优化

    Q(2:n, :) = (N'*wkN) \ (N'*Ri);    % 求解线性方程组，得到控制点
    
    
%     Q1 = (N'*wkN)\(N'*Ri);
% 
% %     Q1 = SolveLeastSquaresLinearFunctions(N, Ri);
%     Q(1, :) = DQ(1, :);
%     Q(2:n, :) = Q1;
%     Q(n + 1, :) = DQ(pCount, :);
%     
%     % 根据是否进行优化标志位的设置选择是否进行优化
%     if OptimizeDualPartFlag == 1
%         Q(:, 5:8) = OptimizeDualPart(Q, P, NFul, dominantP);
%     end
    
%     Q = NormalizeControlQuaternion(Q);
    % 进行迭代计算
    [QIterat, ErrCL, ErrRL, U3, dominantPAf, NFul] = iterativeFitting(Q, U2, Ub, DQ, p, P, dominantP, IteratErrLimit, NFul);

else 
    % 如果误差满足要求，则将原来的数据输出;
    QIterat = Q;
    U3 = U;
    dominantPAf = dominantP;
end


