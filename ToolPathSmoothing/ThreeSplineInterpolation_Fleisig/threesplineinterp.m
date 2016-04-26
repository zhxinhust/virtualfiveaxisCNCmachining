function [L, C, V, D, u, h] = threesplineinterp(pathData)

% 进行刀尖位置点五阶多项式拟合
[L, C] = positionQuinticSplineFitting(pathData);

% 进行刀轴矢量五阶多项式拟合
[V, D] = orientationSplineFitting(pathData);

% 重新参数化
[u, h] = OrientationReparameterization(D, L);