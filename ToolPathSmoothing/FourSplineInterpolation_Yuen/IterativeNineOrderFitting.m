function IterativeNineOrderFitting(startIndex, endIndex)

global feedCorrectionFittingErr;    % 拟合允许误差

global UL;      % 所有的待拟合点

global FeedCorrectionCoff;  % 拟合得到的多项式系数

global FeedCorrectionStartL; % 拟合段的起始L

global FeedCorrectionLength; % 拟合段的长度S

global FeedCorrectionNum;    % 段编号

%% 对前半段进行拟合
subStartIndex = startIndex;
subEndIndex = round((startIndex + endIndex) / 2);

[polyFittingCoeff, startL, Length] = NineOrderFitting(subStartIndex, subEndIndex);  % 对前半段进行拟合

us = CaculateuWhithl(UL(subStartIndex:subEndIndex, 2), polyFittingCoeff, startL, Length);  % 计算此拟合得到的点

% 进行分成两段进行拟合，如果满足精度要求，或者点数少于等于9则退出，并保留拟合结果
if sum(abs(UL(subStartIndex:subEndIndex, 1) - us)) < feedCorrectionFittingErr || subEndIndex - subStartIndex <= 19
    FeedCorrectionCoff(FeedCorrectionNum, :) = polyFittingCoeff;
    FeedCorrectionStartL(FeedCorrectionNum) = startL;
    FeedCorrectionLength(FeedCorrectionNum) = Length;
    FeedCorrectionNum = FeedCorrectionNum + 1;
else
    % 如果不满足精度要求，则再次进行迭代
    IterativeNineOrderFitting(subStartIndex, subEndIndex);
end

%% 对后半段进行拟合
subStartIndex = subEndIndex;
subEndIndex = endIndex;

[polyFittingCoeff, startL, Length] = NineOrderFitting(subStartIndex, subEndIndex);  % 对后半段进行拟合

us = CaculateuWhithl(UL(subStartIndex:subEndIndex, 2), polyFittingCoeff, startL, Length);  % 计算此拟合得到的点

% 如果满足精度要求，或者点数少于等于9则退出，并保留拟合结果
if sum(abs(UL(subStartIndex:subEndIndex, 1) - us)) < feedCorrectionFittingErr || subEndIndex - subStartIndex <= 19
    FeedCorrectionCoff(FeedCorrectionNum, :) = polyFittingCoeff;
    FeedCorrectionStartL(FeedCorrectionNum) = startL;
    FeedCorrectionLength(FeedCorrectionNum) = Length;
    FeedCorrectionNum = FeedCorrectionNum + 1;
else
    IterativeNineOrderFitting(subStartIndex, subEndIndex);
end
