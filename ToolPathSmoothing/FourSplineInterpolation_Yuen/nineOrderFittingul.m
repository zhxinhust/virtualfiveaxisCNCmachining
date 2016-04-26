function [polyFittingCoeff, startL, Length] = nineOrderFittingul( ulData )
%利用九阶多项式拟合U(l)曲线
%   输入ulData为上一步经过辛普森迭代算法求得的u(l)离散点
%   输出为拟合得到的多项式系数和对应的起点

global feedCorrectionFittingErr;    % 拟合允许误差
feedCorrectionFittingErr = 0.001;

global UL;      % 所有的待拟合点
UL = ulData;

global FeedCorrectionCoff;  % 拟合得到的多项式系数
FeedCorrectionCoff = zeros(1, 10);

global FeedCorrectionStartL; % 拟合段的起始L
FeedCorrectionStartL = 0;

global FeedCorrectionLength; % 拟合段的长度S
FeedCorrectionLength = 0;

global FeedCorrectionNum;    % 段编号
FeedCorrectionNum = 1;

startIndex = 1;
endIndex = size(ulData, 1);

[alfa, startL, S] = NineOrderFitting(startIndex, endIndex);         % 先对此段进行拟合
us = CaculateuWhithl(UL(startIndex:endIndex, 2), alfa, startL, S);  % 计算此拟合得到的点
if sum(abs(UL(startIndex:endIndex, 1) - us)) < feedCorrectionFittingErr     % 计算拟合误差，如果满足精度要求则记录此计算结果
    FeedCorrectionCoff(FeedCorrectionNum, :) = alfa;
    FeedCorrectionStartL(FeedCorrectionNum) = startL;
    FeedCorrectionLength(FeedCorrectionNum) = S;
    FeedCorrectionNum = FeedCorrectionNum + 1;
else
    % 否则进行迭代计算
    IterativeNineOrderFitting(startIndex, endIndex);
end

polyFittingCoeff = FeedCorrectionCoff;
startL = FeedCorrectionStartL;
Length = FeedCorrectionLength;


