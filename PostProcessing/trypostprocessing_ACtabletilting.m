function [ka, kc] = trypostprocessing_ACtabletilting(pathpoints, rotarytable, offsets, axesranges)
% 尝试进行反解，根据选择一组合适的解
% 输入： pathpoints 五轴刀位点
% rotarytable：双转台参数
% offsets：当刀尖点处于工件坐标系原点时，各轴的位置
% axesranges：各轴运动范围
% 输出
% ka，A = ka * arccos(k), ka = 1 或 -1
% kc, C = arctan(i / j) - kc * pi, kc = -1, 0, 1

n = size(pathpoints, 1);
A = zeros(n, 2);
C = zeros(n, 3);

X = zeros(n, 6);
Y = zeros(n, 6);
Z = zeros(n, 6);

for i = 1:size(pathpoints, 1)
    A(i, 1) = acos(pathpoints(i, 6));
    A(i, 2) = -arccos(pathpoints(i, 6));
    
    C(i, 1:3) = atan(pathpoints(i, 4) / pathpoints(i, 5)) - (-1:1) * pi;
    
    for aa = 1:2
        for cc = 1:3
            X(i, (aa - 1) * 3 + cc) = pathpoints(i, 1) * cos(C(i, cc)) + (rotarytable.Ly - pathpoints(i, 2)) * sin(C(i, cc));
            Y(i, (aa - 1) * 3 + cc) = pathpoints(i, 1) * cos(A(i, aa)) * sin(C(i, cc)) + (pathpoints(i, 2) - rotarytable.Ly) * cos(A(i, aa)) * cos(C(i, cc)) + (rotarytable.Lz - pathpoints(i, 3)) * sin(A(i, aa)) + rotarytable.Ly;
            Z(i, (aa - 1) * 3 + cc) = (pathpoints(i, 1) - rotarytable.Ly) * sin(A(i, aa)) * sin(C(i, cc)) + pathpoints(i, 2) * sin(A(i, aa)) * cos(C(i, cc)) + (pathpoints(i, 3) - rotarytable.Lz) * cos(A(i, aa)) + rotarytable.Lz;
        end
    end
end

A = A + offsets(1);
C = C + offsets(2);
X = X + offsets(3);
Y = Y + offsets(4);
Z = Z + offsets(5);



