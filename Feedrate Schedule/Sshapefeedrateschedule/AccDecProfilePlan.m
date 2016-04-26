function [AccT, DecT, ContT, SType, subSegmentFeedPeakSmall, subSegmentFeedPeakBig] = AccDecProfilePlan(Vstr, Vend, Vmax, Len, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, i)
% 进行分类规划

global maxJerk;

% 计算三个长度，用来划分类型
Lr1 = 4 * Vstr * sqrt(abs(Vmax - Vstr) / maxJerk);

Lr2 = (Vstr + Vend) * sqrt(abs(Vstr - Vend) / maxJerk);

Lr3 = (Vstr + Vmax) * sqrt((Vmax - Vstr) / maxJerk) + (Vend + Vmax) * sqrt((Vmax - Vend) / maxJerk);

if Vstr == Vend
	if Len <= Lr1	
		% 加速距离不够，按照恒速规划 
		[AccT, DecT, ContT, SType] = SprofilePlanType1(Vstr, Vend, Vmax, Len);
    elseif (Len > Lr1) && (Len <= Lr3)
		% 加速 + 减速
		[AccT, DecT, ContT, SType] = SprofilePlanType4(Vstr, Vend, Vmax, Len);
    else
        % 加速 + 匀速 + 减速
        [AccT, DecT, ContT, SType] = SprofilePlanType5(Vstr, Vend, Vmax, Len);
    end
else
    if Len < Lr2
        % 加速距离不够，按照恒速规划 
		[AccT, DecT, ContT, SType] = SprofilePlanType1(Vstr, Vend, Vmax, Len);
        subSegmentFeedPeakSmall(i + 1) = Vstr;
        subSegmentFeedPeakBig(i + 1) = Vstr;
    elseif Len == Lr2
        % 减速
        [AccT, DecT, ContT, SType] = SprofilePlanType6(Vstr, Vend, Vmax, Len);
    elseif Len > Lr2 && Len < Lr3
        % 加速 + 减速
		[AccT, DecT, ContT, SType] = SprofilePlanType4(Vstr, Vend, Vmax, Len);
    else
        % 加速 + 匀速 + 减速
		[AccT, DecT, ContT, SType] = SprofilePlanType5(Vstr, Vend, Vmax, Len);
    end
end