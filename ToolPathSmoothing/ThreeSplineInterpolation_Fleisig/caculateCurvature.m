function curvatureArr = caculateCurvature(L, C)
% 计算曲率

n = length(L);  % 获取曲线段数
stepIndex = 1;
du = 0.001;

for i = 1:n
    c1 = C(1, :, i);
    c2 = C(2, :, i);
    c3 = C(3, :, i);
    c4 = C(4, :, i);
    c5 = C(5, :, i);
    c6 = C(6, :, i);
    for u = 0:du:L(i)
        der1 = c2 + 2*c3*u + 3*c4*u^2 + 4*c5*u^3 + 5*c6*u^4;
        der2 = 2*c3 + 6*c4*u + 12*c5*u^2 + 20*c6*u^3;
        curvatureArr(stepIndex) = norm(cross(der1, der2)) / norm(der1)^3;
        stepIndex = stepIndex + 1;
    end
end
