function uls = CaculateuDerls(u)
% 计算边界条件

global KnotVector;  % 节点向量
global CP;      % 控制点
global curveDegree; % 曲线阶数

bspline.controlp = CP;
bspline.knotvector = KnotVector;
bspline.splineorder = curveDegree;

CDerus= DeBoorCoxNurbsCal( u, bspline, 3); % 计算u处的型值点、一阶二阶三阶导矢

% plot(u, norm(CDerus(4, :)), '*');

fu = norm(CDerus(2, :));
fu1 = dot(CDerus(2, :), CDerus(3, :)) / fu;
fu2 = (dot(CDerus(3, :), CDerus(3, :)) + dot(CDerus(2, :), CDerus(4, :)) - fu1^2) / fu;

ul = 1/fu;
ul2 = -fu1 / fu^3;
ul3 = (3*fu1^2 - fu2*fu) / fu^5;

uls = [ul ul2 ul3]';

