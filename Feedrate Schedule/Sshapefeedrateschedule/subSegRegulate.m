function [ReSubSegmentUPara, ReSubSegmentFeedPeakSmall, ReSubSegmentFeedPeakBig, ReArcLengthVector] = subSegRegulate(subSegmentUPara, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, arcLengthVector)
% 对分段进行调整，将长度非常小的段合并起来

n = length(arcLengthVector) - 1;    % 由于最后一段保存着刀路总长度，因此要去掉

% 设定允许的长度阈值，如果小于这个长度则会进行合并
lengthThres = 3;

ReSubSegmentUPara(1:2) = subSegmentUPara(1:2);
ReSubSegmentFeedPeakSmall(1:2) = subSegmentFeedPeakSmall(1:2);
ReSubSegmentFeedPeakBig(1:2) = subSegmentFeedPeakBig(1:2);
ReArcLengthVector(1) = arcLengthVector(1);

lengthSum = 0;				% 从上一分割点到此点处弧长累积长度
segMinFeed = 10^10;			% 从上一分割点到此点处，进给速度最小值
segMaxFeed = 0;				% 从上一分割点到此点处，进给速度最大值

splitPointNum = 3;	% 分割点编号

i = 2;
while i <= n
	if arcLengthVector(i) + lengthSum < lengthThres && i < n
		% 小于阈值，则不作为一段，进行合并
		lengthSum = lengthSum + arcLengthVector(i);	% 弧长进行累加
		
		% 保存最大最小速度值
		segMaxFeed = max(segMaxFeed, subSegmentFeedPeakBig(i + 1));
		segMinFeed = min(segMinFeed, subSegmentFeedPeakSmall(i + 1));
		
    else
        % 对于累积长度大于阈值
        if i < n
            if arcLengthVector(i + 1) < 0.5
                ReArcLengthVector(splitPointNum - 1) = lengthSum + arcLengthVector(i) + arcLengthVector(i + 1);
                ReSubSegmentFeedPeakBig(splitPointNum) = max([segMaxFeed, subSegmentFeedPeakBig(i + 1), subSegmentFeedPeakBig(i + 2)]);
                ReSubSegmentFeedPeakSmall(splitPointNum) = min([segMinFeed, subSegmentFeedPeakSmall(i + 1), subSegmentFeedPeakSmall(i + 2)]);
                ReSubSegmentUPara(splitPointNum) = subSegmentUPara(i + 2);
                i = i + 2;
                
                lengthSum = 0;				% 从上一分割点到此点处弧长累积长度
                segMinFeed = 10^10;			% 从上一分割点到此点处，进给速度最小值
                segMaxFeed = 0;				% 从上一分割点到此点处，进给速度最大值
		
                splitPointNum = splitPointNum + 1;
                continue;
            end
        end
		ReArcLengthVector(splitPointNum - 1) = lengthSum + arcLengthVector(i);
		ReSubSegmentFeedPeakBig(splitPointNum) = max(segMaxFeed, subSegmentFeedPeakBig(i + 1));
		ReSubSegmentFeedPeakSmall(splitPointNum) = min(segMinFeed, subSegmentFeedPeakSmall(i + 1));
		ReSubSegmentUPara(splitPointNum) = subSegmentUPara(i + 1);
		
		lengthSum = 0;				% 从上一分割点到此点处弧长累积长度
		segMinFeed = 10^10;			% 从上一分割点到此点处，进给速度最小值
		segMaxFeed = 0;				% 从上一分割点到此点处，进给速度最大值
		
		splitPointNum = splitPointNum + 1;
    end
    i = i + 1;
end

ReArcLengthVector(splitPointNum - 1) = arcLengthVector(n + 1);
