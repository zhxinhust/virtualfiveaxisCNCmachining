function [L, C] = positionQuinticSplineFitting( P )
%对刀尖点位置曲线进行五阶多项式拟合
%   输入P为刀路离散数据点，输出l为分段后每段长度，C为系数矩阵

pCount = size(P, 1);    % 点总数
n = pCount - 1;         % 对应论文中的最大下标值

% 计算弦长，作为初始值，以求三次样条曲线
chordLength = zeros(1, pCount - 1);
for i = 1:pCount - 1
    chordLength(i) = norm(P(i + 1, 1:3) - P(i, 1:3));
end

L = zeros(1, pCount - 1);
iterErr = 0.1;
iteNum = 0;
while abs(sum(L) - sum(chordLength)) > iterErr

    if iteNum > 0
        chordLength = L;
    end
    % 求三次样条曲线时用到的系数矩阵
    N = zeros(n + 1, n + 1);    
    for i = 2:n
        N(i, i - 1) = chordLength(i - 1) / 6;
        N(i, i) = (chordLength(i - 1) + chordLength(i)) / 3;
        N(i, i + 1) = chordLength(i) / 6;
    end
    N(1, 1) = chordLength(1) / 3;
    N(1, 2) = chordLength(1) / 6;
    N(n + 1, n) = chordLength(n) / 6;
    N(n + 1, n + 1) = chordLength(n) / 3;

    % 求等号右边
    t1 = 4*P(2, 1:3) - P(3, 1:3) - 3*P(1, 1:3);
    p1u = t1 / norm(t1);

    tnp1 = 3*P(n + 1, 1:3) + P(n - 1, 1:3) - 4*P(n, 1:3);
    pnp1u = tnp1 / norm(tnp1);

    b = zeros(n + 1, 3);
    b(1, :) = (P(2, 1:3) - P(1, 1:3)) / chordLength(1) - p1u;
    b(n + 1, :) = pnp1u - (P(n + 1, 1:3) - P(n, 1:3)) / chordLength(n);
    for i = 2:n
        b(i, :) = (P(i + 1, 1:3) - P(i, 1:3)) / chordLength(i)...
                    - (P(i, 1:3) - P(i - 1, 1:3)) / chordLength(i - 1);
    end

    puu = N \ b;    % 求解得到各点二阶切矢

    cubicCoeff = zeros(4, 3, n);
    for i = 1:n
        cubicCoeff(1, :, i) = (puu(i + 1, :) - puu(i, :)) / (6 * chordLength(i));
        cubicCoeff(2, :, i) = puu(i, :) / 2;
        cubicCoeff(3, :, i) = (P(i + 1, 1:3) - P(i, 1:3)) / chordLength(i) - chordLength(i) *( puu(i + 1, :) + 2*puu(i, :)) / 6;
        cubicCoeff(4, :, i) = P(i, 1:3);
    end

    % 求得初始的p, pu, puu
    for i = 1:n
        pi(i, :) = P(i, 1:3);
        pui(i, :) = cubicCoeff(3, :, i) / norm(cubicCoeff(3, :, i));
        puui(i, :) = 2 * cubicCoeff(2, :, i);
    end
    pi(n + 1, :) = P(n + 1, 1:3);

    putemp = 3 * cubicCoeff(1, :, n) * chordLength(i)^2 + 2 * cubicCoeff(2, :, n) * chordLength(i) + cubicCoeff(3, :, n);
    puutemp = 6 * cubicCoeff(1, :, n) * chordLength(i) + 2 * cubicCoeff(2, :, n);

    % 按照Feisig论文中方法改进
    pui(n + 1, :) = putemp / norm(putemp);
    puui(n + 1, :) = (dot(putemp,  putemp) * puutemp - dot(putemp, puutemp) * putemp) / dot(putemp, putemp)^2;

    % 五次多项式求解Li所需要用到的系数
    EquationCoef = zeros(n, 5);
    L = zeros(1, n);    % 每段长度，这里用牛顿迭代法求解出。
    C = zeros(6, 3, n);
    for i = 1:n
        c1 = pi(i + 1, :) - pi(i, :);
        c2 = pui(i + 1, :) + pui(i, :);
        c3 = puui(i + 1, :) - puui(i, :);

        % 按照F-C Wang论文中的式(20)求得系数
        EquationCoef(i, 1) = dot(c3, c3);
        EquationCoef(i, 2) = -28 * dot(c3, c2);
        EquationCoef(i, 3) = 196 * dot(c2, c2) + 120 * dot(c1, c3) - 1024;
        EquationCoef(i, 4) = -1680 * dot(c1, c2);
        EquationCoef(i, 5) = 3600 * dot(c1, c1);

        % 以弦长为初始值，利用牛顿迭代法求解Li，即Wang论文中的式（16）
        L(i) = newtonIterativeSolveEquation(EquationCoef(i, :), chordLength(i));
        
        C(1, :, i) = pi(i, :);
        C(2, :, i) = pui(i, :);
        C(3, :, i) = puui(i, :) / 2;
        C(4, :, i) = 10 * (pi(i + 1, :) - pi(i, :)) / L(i)^3 - 2 * (2 * pui(i + 1, :) + 3 * pui(i, :)) / L(i)^2 + (puui(i + 1, :) - 3*puui(i, :)) / (2 * L(i));
        C(5, :, i) = -15 * (pi(i + 1, :) - pi(i, :)) / L(i)^4 + (7 * pui(i + 1, :) + 8 * pui(i, :)) / L(i)^3 - (2*puui(i + 1, :) - 3*puui(i, :)) / (2 * L(i)^2);
        C(6, :, i) = 6 * (pi(i + 1, :) - pi(i, :)) / L(i)^5 - 3 * c2 / L(i)^4 + c3 / (2 * L(i) ^ 3);
    end
    iteNum = iteNum + 1;
end

% for i = 1:n
%     C(1, :, i) = pi(i, :);
%     C(2, :, i) = pui(i, :);
%     C(3, :, i) = puui(i, :) / 2;
%     C(4, :, i) = 10 * (pi(i + 1, :) - pi(i, :)) / L(i)^3 - 2 * (2 * pui(i + 1, :) + 3 * pui(i, :)) / L(i)^2 + (puui(i + 1, :) - 3*puui(i, :)) / (2 * L(i));
%     C(5, :, i) = -15 * (pi(i + 1, :) - pi(i, :)) / L(i)^4 + (7 * pui(i + 1, :) + 8 * pui(i, :)) / L(i)^3 - (2*puui(i + 1, :) - 3*puui(i, :)) / (2 * L(i)^2);
%     C(6, :, i) = 6 * (pi(i + 1, :) - pi(i, :)) / L(i)^5 - 3 * c2 / L(i)^4 + c3 / (2 * L(i) ^ 3);
% end

% %% ***********************  以下为调试用  *****************************%% 
% pNum = 1;
% quiNum = 1;
% for i = 1:n
% %     for u = 0:0.01:chordLength(i)
% %         cubicSplineP(pNum, :) = cubicCoeff(1, :, i) * u^3 + cubicCoeff(2, :, i) * u^2 + cubicCoeff(3, :, i) * u + cubicCoeff(4, :, i);
% % %         cubicSplinePu(pNum, :) = 3 * cubicCoeff(1, :, i) * u^2 + 2 * cubicCoeff(2, :, i) * u + cubicCoeff(3, :, i);
% % %         cubicSplinePuu(pNum, :) = 6 * cubicCoeff(1, :, i) * u + 2 * cubicCoeff(2, :, i);
% %         pNum = pNum + 1;
% %     end
%     
%     for u = 0:0.01:L(i)
%         quinticSplineP(quiNum, :) = C(1, :, i) + C(2, :, i) * u + C(3, :, i) * u^2 + C(4, :, i) * u^3 + C(5, :, i) * u^4 + C(6, :, i) * u^5;
%         quiNum = quiNum + 1;
%     end
% end
% 
% 
% figure(1);
% % plot3(cubicSplineP(:, 1), cubicSplineP(:, 2), cubicSplineP(:, 3), 'r');
% 
% plot3(P(:, 1), P(:, 2), P(:, 3), '*');
% hold on;
% plot3(quinticSplineP(:, 1), quinticSplineP(:, 2), quinticSplineP(:, 3), 'b');



