function [Q, U, polycoef, startpiont, sublength, B, W, LW, WQ] = foursplineinterp(data)

curveDegree = 5;

[Q, U, Ub] = positionFitting(data, curveDegree);           % 插值，求得控制点

ParaLenP = nurbsBlockLengthCal(U, curveDegree, Q);      % 用辛普森公式求(u,l)离散点

[polycoef, startpiont, sublength] = nineOrderFittingul( ParaLenP ); % 采用九阶多项式拟合(u,l)点

[B, W, Wb] = OrientationFitting(data, curveDegree);        % 对刀轴矢量进行插值

LW = SeclectLWData(Wb, Ub);     % 获取离散的(lk, wk)数据点

WQ = OrientationReparamterization(LW);

clear KnotVector
clear CP
clear curveDegree