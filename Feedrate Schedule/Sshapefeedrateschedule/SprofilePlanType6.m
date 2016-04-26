function [AccT, DecT, ContT, SType] = SprofilePlanType6(Vstr, Vend, Vmax, Len)
% ¼õËÙ¹æ»®

global maxAcc;
global maxJerk;
global interpolationFrequence;

T1 = maxAcc / maxJerk;
T2 = 0;
while abs(T1 - T2) > 10^(-6)
    T2 = T1;
    T1 = T2 - (maxJerk * T2^3 + 2 * Vend * T2 - Len) / (3 * maxJerk * T2^2 + 2 * Vend);
end

AccT = 0;
DecT = T1 * interpolationFrequence;
ContT = 0;
SType = 6;