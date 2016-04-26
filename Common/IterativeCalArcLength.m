function IterativeCalArcLength( startPoint, midPoint, endPoint)
% 定义用于迭代计算弧长的函数
% startPoint, midPoint, endPoint分别为要进行迭代的起点、中点和终点。
% 迭代最后的结果保存在全局变量simpsonVector中。

global simpsonErr;
global simpsonVector;       % 用来保存用辛普森公式迭代计算出来的(u, l)值
global simpsonVectorIndex;  % 此变量为上数据点的数量
global iterativeNumber;     % 迭代次数

%% 先计算前一半段曲线
subStartPoint = startPoint;
subMidPoint = (startPoint + midPoint) / 2;
subEndPoint = midPoint;

subArcLengthUpperHalf = ArcLengthSimpson(subStartPoint, subMidPoint);
subArcLengthLowerHalf = ArcLengthSimpson(subMidPoint, subEndPoint);
totalArcLength = ArcLengthSimpson(subStartPoint, subEndPoint);

iterativeNumber = iterativeNumber + 1;

if abs(subArcLengthUpperHalf + subArcLengthLowerHalf - totalArcLength) < simpsonErr
    simpsonVector(simpsonVectorIndex, 1) = subEndPoint;
    simpsonVector(simpsonVectorIndex, 2) = totalArcLength;
    simpsonVectorIndex = simpsonVectorIndex + 1;
else
    IterativeCalArcLength(subStartPoint, subMidPoint, subEndPoint);
end

%% 计算后半段曲线
subStartPoint = midPoint;
subMidPoint = (endPoint + midPoint) / 2;
subEndPoint = endPoint;

subArcLengthUpperHalf = ArcLengthSimpson(subStartPoint, subMidPoint);
subArcLengthLowerHalf = ArcLengthSimpson(subMidPoint, subEndPoint);
totalArcLength = ArcLengthSimpson(subStartPoint, subEndPoint);

if abs(subArcLengthUpperHalf + subArcLengthLowerHalf - totalArcLength) < simpsonErr
    simpsonVector(simpsonVectorIndex, 1) = subEndPoint;
    simpsonVector(simpsonVectorIndex, 2) = totalArcLength;
    simpsonVectorIndex = simpsonVectorIndex + 1;
else
    IterativeCalArcLength(subStartPoint, subMidPoint, subEndPoint);
end

end

