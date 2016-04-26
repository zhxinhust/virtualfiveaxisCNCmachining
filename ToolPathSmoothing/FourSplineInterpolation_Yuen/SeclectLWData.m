function LW = SeclectLWData(Wb, Ub)
% 选取LW数据点(lk, wk)

%% 先对全局变量进行初始化，以清除之前计算得到的结果
global simpsonVector;       % 用来保存用辛普森公式迭代计算出来的(u, l)值
simpsonVector = zeros(1, 2);

global simpsonVectorIndex;  % 此变量为上数据点的数量
simpsonVectorIndex = 2;

global iterativeNumber; % 迭代次数
iterativeNumber = 0;

%% 初始化局部变量
n = length(Wb);
LW = zeros(n, 2);
LW(:, 2) = Wb';

%% 进行分段计算lk
for i = 2:n
    startPoint = Ub(i - 1);
    endPoint = Ub(i);
    midPoint = (startPoint + endPoint) / 2;
    
    IterativeCalArcLength( startPoint, midPoint, endPoint);
    LW(i, 1) = sum(simpsonVector(:, 2));
end