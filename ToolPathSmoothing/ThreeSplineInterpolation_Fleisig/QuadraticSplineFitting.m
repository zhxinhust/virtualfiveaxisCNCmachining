function QD = QuadraticSplineFitting(d0, d1, d2, lambda1, lambda2)
% 对三个点进行二次球面Bezier曲线拟合，输出QD为三个控制点

QD(1, :) = d0;
QD(2, :) = d1;
QD(3, :) = d2;

IterativeErr = 10e-8;   % 迭代允许误差

lam = lambda1 + lambda2;
% 设置迭代初始值
B(:, :, 1) = [1, 0, 0;
              0, 1, 0;
              0, 0, 1];
X(1, :) = d1;
F(1, :) = QuadraticSphericalBezier(d0, X(1, :), d2, lam, lambda1) - d1;
deltaX = -B(:, :, 1) \ F(1, :)';

X(2, :) = X(1, :) + deltaX';
X(2, :) = X(2, :) / norm(X(2, :));
F(2, :) = QuadraticSphericalBezier(d0, X(2, :), d2, lam, lambda1) - d1;
deltaF = F(2, :) - F(1, :);
i = 2;
while norm(X(i, :) - X(i - 1, :)) > IterativeErr
    dX = X(i, :) - X(i - 1, :);
    dF = F(i, :) - F(i - 1, :);
    
    B(:, :, i) = B(:, :, i - 1) + (dX' - B(:, :, i - 1)*dF')* dX * B(:, :, i - 1) / (dX *  B(:, :, i - 1) * dF');
    dX = -B(:, :, i) * F(i, :)';
    X(i + 1, :) = X(i, :) + dX';
    X(i + 1, :) = X(i + 1, :) / norm(X(i + 1, :));
    F(i + 1, :) = QuadraticSphericalBezier(d0, X(i + 1, :), d2, lam, lambda1) - d1;
    i = i + 1;
end

QD = X(i, :);

orNum = 1;
for v = 0:0.0001:lam
    orp(orNum, :) = QuadraticSphericalBezier(d0, QD, d2, lam, v);
    orNum = orNum + 1;
end

% figure;
% plot3(orp(:, 1), orp(:, 2), orp(:, 3));
% hold on;
% plot3([d0(1) d1(1) d2(1)]', [d0(2) d1(2) d2(2)]', [d0(3) d1(3) d2(3)]');


