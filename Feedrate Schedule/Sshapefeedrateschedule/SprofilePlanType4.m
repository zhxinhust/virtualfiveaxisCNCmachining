function [AccT, DecT, ContT, SType] = SprofilePlanType4(Vstr, Vend, Vmax, Len)
% 加速 + 减速

global maxAcc;
global maxJerk;

global interpolationFrequence;

TstrNow = maxAcc / maxJerk; 
TstrLast = 0;

% 方程系数，林明宗table 3
k1 = maxJerk * (Vend - Vstr);
k2 = 2 * maxJerk * Len;
k3 = -(Vstr - Vend)^2;
k4 = 4 * Vstr * Len;
k5 = (Vstr + Vend)^2 * (Vstr - Vend) / maxJerk - Len^2;

% 利用牛顿迭代法求解方程
while abs(TstrNow - TstrLast) > 10^(-6)
    TstrLast = TstrNow;
    TstrNow = TstrLast - (k1 * TstrLast^4 + k2 * TstrLast^3 + k3 * TstrLast^2 + k4 * TstrLast + k5) /...
        (4 * k1 * TstrLast^3 + 3 * k2 * TstrLast^2 + 2 * k3 * TstrLast + k4);
end

AccT = TstrNow * interpolationFrequence;
ContT = 0;
DecT = sqrt(TstrNow^2 + (Vstr - Vend) / maxJerk) * interpolationFrequence;
SType = 4;