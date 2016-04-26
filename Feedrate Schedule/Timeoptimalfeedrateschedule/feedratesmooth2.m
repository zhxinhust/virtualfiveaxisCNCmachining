function [controlp, knotvector] = feedratesmooth2(feedrate, uvector, splineorder, controlpnum)
% 将离散刀路插值为样条刀路

m = length(feedrate) - 1;    % 要拟合的离散数据点最大下标
n = controlpnum - 1;        % 控制点数量最大下标

Ub = uvector;

U = zeros(1, n + splineorder + 2);

U(n + 1 : end) = 1;

d = (m + 1) / (n - splineorder + 1);
for j = 1 : n - splineorder
	i = round(j * d - 0.5);
	a = j * d - i;
	U(splineorder + j + 1) = (1 - a) * Ub(i) + a * Ub(i + 1);
end

NFul = zeros(m + 1, n + 1);
for i = 1 : m + 1
	for j = 1 : n + 1
		NFul(i, j) = GetBaseFunVal(Ub(i), j - 1, splineorder, U);
	end
end

N = NFul(2:m, 2:n);

Ri = feedrate(2 : m);
for i = 1 : m - 1
	N0pUbi = NFul(i + 1, 1);
    NnpUbi = NFul(i + 1, end);
    Ri(i) = Ri(i) - feedrate(1) * N0pUbi - feedrate(end) * NnpUbi;
end

CQ = (N' * N) \ (N' * Ri);

controlp = zeros(controlpnum, 1);
controlp(1) = feedrate(1);
controlp(2 : end - 1) = CQ(1:end);
controlp(end) = feedrate(end);

knotvector = U;