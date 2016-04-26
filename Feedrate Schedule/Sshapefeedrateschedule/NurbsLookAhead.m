function [AccT, DecT, ContT, SType, finishT, subSegmentFeedPeakSmall, subSegmentFeedPeakBig] = NurbsLookAhead(subSegmentUPara, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, arcLengthVector)
% 进行速度前瞻处理，加减速S型规划
% 运行输出的为加加速度时间、减话加速度时间、恒速时间以及S型曲线类型

global maxAcc;
global maxJerk;

% 插补频率，及插补周期Ts = 0.5ms
global interpolationFrequence;
global interpolationPeriod;

subSegmentNum = length(subSegmentUPara) - 1;	% 子段数

maxAccVel = maxAcc^2 / maxJerk;

% 首段处理
if (sqrt(subSegmentFeedPeakSmall(2) / maxJerk) * subSegmentFeedPeakSmall(2) > arcLengthVector(1))
	% 如果满足条件，则说明从0速加到末速，增加距离超过弧长长度，速度不可达，需减小末端的速度大小
	subSegmentFeedPeakSmall(2) = (arcLengthVector(1)^2 * maxJerk)^(1 / 3);
	subSegmentFeedPeakBig(2) = subSegmentFeedPeakSmall(2);
end

% 末端处理
if sqrt(subSegmentFeedPeakSmall(subSegmentNum) / maxJerk) * subSegmentFeedPeakSmall(subSegmentNum) > arcLengthVector(subSegmentNum)
	% 满足条件则说明减速长度不够，需修改末段的起始速度
	subSegmentFeedPeakSmall(subSegmentNum) = (arcLengthVector(subSegmentNum)^2 * maxJerk)^(1 / 3);
	subSegmentFeedPeakBig(subSegmentNum + 1) = subSegmentFeedPeakSmall(subSegmentNum);
end

% 循环判断各子段的最大速度是否满足运动学约束
for i = 1:subSegmentNum
	if (subSegmentFeedPeakBig(i + 1) > subSegmentFeedPeakSmall(i) + maxAccVel) 
		% 如果不满足，则说明子段最大速度在跃度有限的约束下不可达到，需要调整最大速度
		subSegmentFeedPeakBig(i + 1) = min(subSegmentFeedPeakSmall(i), subSegmentFeedPeakSmall(i + 1)) + maxAccVel;
	end
end

% 循环对每段进行加减速规划
for i = 1:subSegmentNum
	% 对本子段的起止点速度、最大速度、弧长幅值
	Vstr = subSegmentFeedPeakSmall(i);
	Vend = subSegmentFeedPeakSmall(i + 1);
	Vmax = subSegmentFeedPeakBig(i + 1);
	Len = arcLengthVector(i);
	
	if Vstr == Vend
		if Vstr == Vmax
			% 如果满足条件，则为恒速段，Type1
			[AccT(i), DecT(i), ContT(i), SType(i)] = SprofilePlanType1(Vstr, Vend, Vmax, Len);
		else
			[AccT(i), DecT(i), ContT(i), SType(i), subSegmentFeedPeakSmall, subSegmentFeedPeakBig] = AccDecProfilePlan(Vstr, Vend, Vmax, Len, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, i);
        end 
    elseif Vstr > Vend
        % 判断初始速度和最大速度之间的关系
        if Vstr == Vmax
            Lr4 = (Vstr + Vend) * sqrt((Vstr - Vend) / maxJerk);
            if abs(Lr4 - Len) < 10^(-6)
                % 如果满足条件，则说明是直接减速的情况，按照减速规划
                [AccT(i), DecT(i), ContT(i), SType(i)] = SprofilePlanType6(Vstr, Vend, Vmax, Len);
            else
                % 匀速 + 减速
                [AccT(i), DecT(i), ContT(i), SType(i)] = SprofilePlanType7(Vstr, Vend, Vmax, Len, Lr4);
            end
        else
            % 否则根据子段弧长处理
            [AccT(i), DecT(i), ContT(i), SType(i), subSegmentFeedPeakSmall, subSegmentFeedPeakBig] = AccDecProfilePlan(Vstr, Vend, Vmax, Len, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, i);
        end
    else
        if Vend == Vmax
            Lr4 = (Vstr + Vend) * sqrt((Vend - Vstr) / maxJerk);
            if abs(Lr4 - Len) < 10^(-6)
                % 如果满足条件，则说明是直接加速的情况，按照加速规划
                [AccT(i), DecT(i), ContT(i), SType(i)] = SprofilePlanType2(Vstr, Vend, Vmax, Len);
            else
                % 加速 + 匀速
                [AccT(i), DecT(i), ContT(i), SType(i)] = SprofilePlanType3(Vstr, Vend, Vmax, Len, Lr4);
            end
        else
            % 否则根据子段弧长处理
            [AccT(i), DecT(i), ContT(i), SType(i), subSegmentFeedPeakSmall, subSegmentFeedPeakBig] = AccDecProfilePlan(Vstr, Vend, Vmax, Len, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, i);
        end
	end
end

sumT = 0;
for i = 1:subSegmentNum
    finishT(i) = 2 * AccT(i) + 2 * DecT(i) + ContT(i) + sumT;
    sumT = finishT(i);
end
