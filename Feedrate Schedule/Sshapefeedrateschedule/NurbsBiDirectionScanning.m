function [biScannedFeed] = NurbsBiDirectionScanning(subSegmentUPara, subSegmentFeedPeakSmall, arcLengthVector)
% 对Nurbs曲线进行双向扫描

global maxJerk;	% 全局变量，最大跃度
global maxAcc;		% 全局变量，最大加速度

n = length(arcLengthVector);

% 对速度极值初始化
biScannedFeed = zeros(1, n);

% 先进行反向扫描
for i = n - 1 : -1 : 2
	if i == n - 1
		% 如果是最后一段，则直接计算出速度极值
		feedrateConstr = (arcLengthVector(i)^2 * maxJerk) ^ (1 / 3);
	else
		% 否则进行迭代计算
		iteratNow = biScannedFeed(i + 1);
		iteratLast = 0;
		k1 = 4 * iteratNow;
		k2 = k1 * iteratNow;
		k3 = arcLengthVector(i)^2 * maxJerk;
		
		while abs(iteratLast - iteratNow) > 10^(-6)
			iteratLast = iteratNow;
			iteratNow = iteratLast - (iteratLast^3 + k1 * iteratLast^2 + k2 * iteratLast - k3) /...
			(3 * iteratLast^2 + 2 * k1 * iteratLast + k2);
		end
		
		feedrateConstr = iteratNow + biScannedFeed(i + 1);
	end
	
	% 由于subSegmentFeedPeakSmall中的速度是考虑了弓高误差、最大加速度及跃度约束而得到的，这里直接取最小值即可
	biScannedFeed(i) = min([feedrateConstr, subSegmentFeedPeakSmall(i), maxAcc^2 / maxJerk + biScannedFeed(i + 1)]);
end

%% 正向扫描
biScannedFeed(1) = 0;
for i = 2:n - 1
	% 对于第一段，直接求解，无需迭代
	if i == 2
		feedrateConstr = (arcLengthVector(i - 1)^2 * maxJerk) ^ (1 / 3);
	else
		iteratNow = biScannedFeed(i - 1);
		iteratLast = 0;
		k1 = 4 * iteratNow;
		k2 = k1 * iteratNow;
		k3 = arcLengthVector(i - 1)^2 * maxJerk;
		
		while abs(iteratLast - iteratNow) > 10^(-6)
			iteratLast = iteratNow;
			iteratNow = iteratLast - (iteratLast^3 + k1 * iteratLast^2 + k2 * iteratLast - k3) /...
			(3 * iteratLast^2 + 2 * k1 * iteratLast + k2);
		end
		feedrateConstr = iteratNow + biScannedFeed(i - 1);
	end
	biScannedFeed(i) = min(feedrateConstr, subSegmentFeedPeakSmall(i));
end