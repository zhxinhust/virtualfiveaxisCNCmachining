function derSqrtSumSqrt = ArcLengthDerivative(u)
% 定义用于计算弧长对于曲线参数u的导矢值的函数，亦即ds/du=√(x'^2+y'^2+z'^2)

global KnotVector;  % 节点向量
global CP;      % 控制点
global curveDegree; % 曲线阶数
global p0;

bspline.controlp = CP;
bspline.knotvector = KnotVector;
bspline.splineorder = curveDegree;

DeBoorP= DeBoorCoxNurbsCal( u, bspline, 2); % 计算u处的型值点、一阶二阶三阶导矢

m = size(CP, 2);

if m == 3
    % 说明是三维空间中的样条曲线
    derSqrtSumSqrt = norm(DeBoorP(2, :));    % 求切矢长度
elseif m == 8
    % 说明是对偶四元数格式的曲线
    [der1, der2] = DerCalFromQ(p0, DeBoorP(2, :), DeBoorP(3, :), DeBoorP(1, :));
    derSqrtSumSqrt = norm(der1);
end

