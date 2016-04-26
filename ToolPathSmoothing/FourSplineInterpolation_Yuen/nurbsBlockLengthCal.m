function ParaLenP = nurbsBlockLengthCal( U, p, P)
%ParaLenP = nurbsBlockLengthCal( U, p, P) 计算参数和弧长参数关系数据点
%   此函数利用辛普森公式迭代进行计算，最终得到一系列参数u和弧长l对应的离散点

global simpsonErr;
simpsonErr = 10^(-4);  % 定义的辛普森公式迭代计算精度

global simpsonVector;       % 用来保存用辛普森公式迭代计算出来的(u, l)值
simpsonVector = zeros(1, 2);

global simpsonVectorIndex;  % 此变量为上数据点的数量
simpsonVectorIndex = 2;

global KnotVector;  % 节点向量
KnotVector = U;    

global CP;      % 控制点
CP = P;

global curveDegree; % 曲线阶数
curveDegree = p;   

global iterativeNumber; % 迭代次数
iterativeNumber = 0;

startPoint = 0;                         % 起始点
endPoint = 1;                           % 终点
midPoint = (startPoint + endPoint) / 2; % 中间点

% 将此段曲线分成两段进行计算并与一段计算得到的弧长进行比较
arcLengthUpperHalf = ArcLengthSimpson(startPoint, midPoint);
arcLengthLowerHalf = ArcLengthSimpson(midPoint, endPoint);
arcLengthTotal = ArcLengthSimpson(startPoint, endPoint);

% 如果拆分计算和一段计算结果在误差范围内，则说明结果可以接受，将此设为计算结果
if abs(arcLengthUpperHalf + arcLengthLowerHalf - arcLengthTotal) < simpsonErr
    simpsonVector(simpsonVectorIndex, 1) = 1;
    simpsonVector(simpsonVectorIndex, 2) = arcLengthTotal;
    simpsonVectorIndex = simpsonVectorIndex + 1;
else
    % 否则进行迭代计算
    iterativeNumber = iterativeNumber + 1;
    IterativeCalArcLength(startPoint, midPoint, endPoint);
end

% 将各子段长度进行累加
for i = 1:simpsonVectorIndex - 1
    if i > 1
        simpsonVector(i, 2) = simpsonVector(i, 2) + simpsonVector(i - 1, 2);
    end
end

ParaLenP = simpsonVector;

end

