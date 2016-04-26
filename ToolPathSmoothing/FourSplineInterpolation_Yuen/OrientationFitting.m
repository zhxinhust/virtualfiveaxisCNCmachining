function [B, W, Wb] = OrientationFitting(P, p)
% 采用B样条曲线插值刀轴矢量

n = size(P, 1) - 1;

Angle = zeros(n + 1, 2);

% 将刀轴矢量转换为角度
for i = 1 : n + 1
    Angle(i, 1) = acos(P(i, 6));
    Angle(i, 2) = atan(P(i, 5) / P(i, 4));
    
    if sin(Angle(i, 1)) * cos(Angle(i, 2)) * P(i, 4) < 0 && sin(Angle(i, 1)) * sin(Angle(i, 2)) * P(i, 5) < 0
        Angle(i, 1) = -Angle(i, 1);
    elseif sin(Angle(i, 1)) * cos(Angle(i, 2)) * P(i, 4) < 0 && sin(Angle(i, 1)) * sin(Angle(i, 2)) * P(i, 5) > 0
        Angle(i, 2) = pi - Angle(i, 2);
    elseif sin(Angle(i, 1)) * cos(Angle(i, 2)) * P(i, 4) > 0 && sin(Angle(i, 1)) * sin(Angle(i, 2)) * P(i, 5) < 0
        Angle(i, 2) = -Angle(i, 2);
    end
    
    if i > 1
        if abs(Angle(i, 1) - Angle(i - 1, 1)) > 2 * pi - 0.5
            if Angle(i, 1) >= Angle(i - 1, 1)
                Angle(i, 1) = Angle(i, 1) - 2 * pi;
            else
                Angle(i, 1) = Angle(i, 1) + 2 * pi;
            end
        end
        
        if abs(Angle(i, 2) - Angle(i - 1, 2)) > pi - 0.5
            if Angle(i, 2) >= Angle(i - 1, 2)
                Angle(i, 2) = Angle(i, 2) - pi;
            else
                Angle(i, 2) = Angle(i, 2) + pi;
            end
        end
    end
    
    if sin(Angle(i, 1)) * cos(Angle(i, 2)) * P(i, 4) < 0
        Angle(i, 1) = -Angle(i, 1);
    end
    
end



Wb = zeros(1, n + 1);
for i = 2:n + 1
    Wb(i) = sqrt(acos(dot(P(i, 4:6), P(i - 1, 4:6)))) + Wb(i - 1);
end
Wb = Wb / Wb(n + 1);

W = zeros(1, n + p + 2);
W(n + 2: n + p + 2) = 1;
% 如果m = n 使用均匀化方法得到节点矢量
for j = 1:n - p
    for i = j : j + p - 1
        W(j + p + 1) = W(j + p + 1) + Wb(i + 1);
    end
    W(j + p + 1) = W(j + p + 1) / p;
end

N = zeros(n + 1, n + 1);
for i = 0:n
    for j = 0:n
        N(i + 1, j + 1) = oneBasisFun(Wb(i + 1), j, p, W);
    end
end

B = N \ Angle;

% pNum = 1;
% for u = 0:0.001:1
%     Ori(pNum, :) = curvePoint(p, W, B, u);
%     pNum = pNum + 1;
% end
