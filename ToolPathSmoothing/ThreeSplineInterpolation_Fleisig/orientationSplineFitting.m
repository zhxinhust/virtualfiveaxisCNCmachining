function [V, D] = orientationSplineFitting(P)
% 对刀轴矢量进行球面五次多项式拟合

q = P(:, 4:6);  % 获取刀具路径离散点刀轴矢量部分数据

n = size(q, 1) - 1; % 获取刀具路径点数量

Lambda = zeros(1, n);
for i = 1:n
    Lambda(i) = acos(dot(q(i, :), q(i + 1, :)));
end

Lambda1 = zeros(1, n);
IteratNum = 0;
 while abs(sum(Lambda1) - sum(Lambda)) > 0.4 || IteratNum == 0
    
    for i = 1:n - 1
        qd(i, :) = QuadraticSplineFitting(q(i, :), q(i + 1, :), q(i + 2, :), Lambda(i), Lambda(i + 1));
    end


    % 求各点处切矢
    % 前两点

    qv = zeros(n + 1, 3);
    sita = acos(dot(q(1, :), qd(1, :)));
    qv(1, :) = 2 * sita * (qd(1, :) - q(1, :) * cos(sita)) / ((Lambda(1) + Lambda(2)) * sin(sita));
    sita = acos(dot(q(2, :), qd(2, :)));
    qv(2, :) = 2 * sita * (qd(2, :) - q(2, :) * cos(sita)) / ((Lambda(2) + Lambda(3)) * sin(sita));

    for i = 3:n + 1
        sita = acos(dot(qd(i - 2, :), q(i, :)));
        qv(i, :) = 2 * sita * (q(i, :) * cos(sita) - qd(i - 2, :)) / ((Lambda(i - 2) + Lambda(i - 1)) * sin(sita));
    end

    % 利用二阶球面Bezier多项式构造三次球面Bezier多项式
    cubicControlP2 = zeros(n, 3);
    cubicControlP3 = zeros(n, 3);

    for i = 1:n
        % 求三阶球面Bezier中间的两个控制点
        cubicControlP2(i, :) = q(i, :) * cos(Lambda(i) * norm(qv(i, :)) / 3) + qv(i, :) * sin(Lambda(i) * norm(qv(i, :)) / 3) / norm(qv(i, :));
        cubicControlP3(i, :) = q(i + 1, :) * cos(Lambda(i) * norm(qv(i + 1, :)) / 3) - qv(i + 1, :) * sin(Lambda(i) * norm(qv(i + 1, :)) / 3) / norm(qv(i + 1, :));
    end

    qQv = zeros(n + 1, 3);  % 三次球面Bezier曲线切矢
    qQvv = zeros(n + 1, 3);
    for i = 1:n
        % 为下面书写方便
        d1 = q(i, :);
        d2 = cubicControlP2(i, :);
        d3 = cubicControlP3(i, :);
        d4 = q(i + 1, :);

        % 求切矢
        sita = acos(dot(d3, d2));
        sita1 = acos(dot(d1, d2));
        % 求一阶导矢，Fleisig论文中的式（A1）
        qQv(i, :) = 3 * sita1 * (d2 - d1 * cos(sita1)) / (Lambda(i) * sin(sita1));
        qQv(i, :) = qQv(i, :) / norm(qQv(i, :)); % 按照Fleisig 论文中的（12）式进行处理

        % 按照Fleisig论文中的式(A5)求二阶导矢
        sita2 = acos(dot(d2, d3));

        B22dv0 = 2 * sita2 * (d3 - d2 * cos(sita2)) / sin(sita2);
        B21dv0 = 2 * sita1 * (d2 - d1 * cos(sita1)) / sin(sita1);
        B11dv0 = sita1 * (d2 - d1 * cos(sita1)) / sin(sita1);
        B11dv1 = sita1 * (d2 * cos(sita1) - d1) / sin(sita1);
        sitab = - (dot(d1, B22dv0) + dot(d2, B21dv0)) / sin(sita1);
        qQvv(i, :) = 3 / Lambda(i) ^ 2 * (sita / sin(sita) * (B22dv0 - B21dv0 * cos(sita)) + sita1 ^ 2 * d1 + sitab * (B11dv0 / sita1 - B11dv1 / sin(sita1)));

        % 按照Fleisig论文中的式（14）进行处理
        qQvv(i, :) = (dot(qQv(i, :),qQv(i, :)) * qQvv(i, :) - dot(qQv(i, :), qQvv(i, :)) * qQv(i, :)) / (dot(qQv(i, :), qQv(i, :)))^2;   
    end

    % 计算最后一个点的一二阶导矢
    d1 = q(n, :);
    d2 = cubicControlP2(i, :);
    d3 = cubicControlP3(i, :);
    d4 = q(n + 1, :);

    sita = acos(dot(d3, d4));
    qQv(n + 1, :) = 3 * sita * (d4 * cos(sita) - d3) / (Lambda(n) * sin(sita));
    qQv(n + 1, :) = qQv(n + 1, :) / norm(qQv(n + 1, :));

    sita2 = acos(dot(d2, d3));
    cn = -sita * sin(sita) + dot(d4, sita2 * (cos(sita2) * d3 - d2)/sin(sita2));
    h1n = sita * (d4 - cos(sita) * d3) / sin(sita) - (cos(sita) * d4 - d3);
    h2n = -sita2 * (d3 * cos(sita2) - d2) / sin(sita2) + cos(sita) * sita2 * (cos(sita2)*d4 - d3) / sin(sita);
    qQvv(n + 1, :) = -3 * sita^2 * d4 + 6 * cn * h1n / (sin(sita))^2 + 6 * sita * h2n / sin(sita);

    qQvv(n + 1, :) = (dot(qQv(n + 1, :),qQv(n + 1, :)) * qQvv(n + 1, :) - dot(qQv(n + 1, :), qQvv(n + 1, :)) * qQv(n + 1, :)) / (dot(qQv(n + 1, :), qQv(n + 1, :)))^2;

    quinticControlP2 = zeros(n, 3);
    quinticControlP3 = zeros(n, 3);
    quinticControlP4 = zeros(n, 3);
    quinticControlP5 = zeros(n, 3);

    for i = 1:n
        L0 = Lambda(i);
        Lm = L0;
        [d1, quinticControlP2(i, :), quinticControlP3(i, :), quinticControlP4(i, :), quinticControlP5(i, :), d6] = ...
            QuinticSplineFitting(q(i, :), q(i + 1, :), qQv(i, :), qQv(i + 1, :), qQvv(i, :), qQvv(i + 1, :), L0);
        dQdv = QuiticSplineDer(d1, quinticControlP2(i, :), quinticControlP3(i, :), quinticControlP4(i, :), quinticControlP5(i, :), d6, Lm, L0 / 2);
        y0 = norm(dQdv) - 1;
        minabs = abs(y0);
        minL = L0;

        if abs(y0) < 10^(-2)
            D(i) = L0;
            continue;
        end

        direct = 1;
        % 找到解所在的区间
        while 1 && direct < 20
            if mod(direct, 2) == 1
                L1 = (1 + 0.1 * round((direct + 1))) * L0;
                dQdv1 = QuiticSplineDer(d1, quinticControlP2(i, :), quinticControlP3(i, :), quinticControlP4(i, :), quinticControlP5(i, :), d6, Lm, L1 / 2);
                y1 = norm(dQdv1) - 1;
                if y0 * y1 < 0 
                    break;
                end
                if abs(y1) < minabs
                    minabs = abs(y1);
                    minL = L1;
                end

            else
                L1 = (1 - 0.1 * round((direct + 1) / 2)) * L0;
                dQdv1 = QuiticSplineDer(d1, quinticControlP2(i, :), quinticControlP3(i, :), quinticControlP4(i, :), quinticControlP5(i, :), d6, Lm, L1 / 2);
                y1 = norm(dQdv1) - 1;
                if y0 * y1 < 0 
                    tempL = L0;
                    tempdq = dQdv;
                    L0 = L1;
                    dQdv = dQdv1;
                    L1 = tempL;
                    dQdv1 = tempdq;
                    break;
                end

                if abs(y1) < minabs
                    minabs = abs(y1);
                    minL = L1;
                end
            end

            direct = direct + 1;
        end

        if direct == 20
            D(i) = minL;
        end

        while L1 - L0 > 0.0001
            L2 = (L1 + L0) / 2;
            dQdv2 = QuiticSplineDer(d1, quinticControlP2(i, :), quinticControlP3(i, :), quinticControlP4(i, :), quinticControlP5(i, :), d6, Lm, L2 / 2);
            if (norm(dQdv) - 1) * (norm(dQdv2) - 1) < 0
                L1 = L2;
                dQdv1 = dQdv2;
            else
                L0 = L2;
                dQdv = dQdv2;
            end
        end
        D(i) = (L1 + L0) / 2;
        
%         V(1, :, i) = d1;
%         V(2, :, i) = quinticControlP2(i, :);
%         V(3, :, i) = quinticControlP3(i, :);
%         V(4, :, i) = quinticControlP4(i, :);
%         V(5, :, i) = quinticControlP5(i, :);
%         V(6, :, i) = d6;
    end
    Lambda1 = Lambda;
    Lambda = D;
    IteratNum = IteratNum + 1;
 end
 
 V = zeros(6, 3, n);
 
for i = 1:n
    V(1, :, i) = q(i, :);
    V(2, :, i) = quinticControlP2(i, :);
    V(3, :, i) = quinticControlP3(i, :);
    V(4, :, i) = quinticControlP4(i, :);
    V(5, :, i) = quinticControlP5(i, :);
    V(6, :, i) = q(i + 1, :);
end
 
%  
% 
% % %% 查看结果
% cubicNum = 1;
% for i = 1:n
%     for v = 0:0.0001:Lambda(i)
%         cubicOrP(cubicNum, :) = CubicSphericalBezier(q(i, :), cubicControlP2(i, :), cubicControlP3(i, :), q(i + 1, :), Lambda(i), v);
%         cubicNum = cubicNum + 1;
%     end
% end
% 
% orNum = 1;
% for i = 1:n - 1
%     for v = 0:0.0001:Lambda(i)
%         orientation(orNum, :) = QuadraticSphericalBezier(q(i, :), qd(i, :), q(i + 2, :), Lambda(i) + Lambda(i + 1), v);
%         orNum = orNum + 1;
%     end
% end
% 
% quiNum = 1;
% for i = 1:n
%     for v = 0:0.0001:Lambda(i)
%         quinticP(quiNum, :) = QuinticSphericalBezier(q(i, :), quinticControlP2(i, :), quinticControlP3(i, :), quinticControlP4(i, :), quinticControlP5(i, :), q(i + 1, :), Lambda(i), v);
%         quiNum = quiNum + 1;
%     end
% end
% 
% figure;
% plot3(orientation(:, 1), orientation(:, 2), orientation(:, 3), 'k');
% hold on;
% 
% % figure;
% plot3(q(:, 1), q(:, 2), q(:, 3), '*');
% hold on;
% plot3(cubicOrP(:, 1), cubicOrP(:, 2), cubicOrP(:, 3), 'g');
% plot3(quinticP(:, 1), quinticP(:, 2), quinticP(:, 3), 'r');
% [x, y, z] = sphere;
% mesh(x, y, z);

