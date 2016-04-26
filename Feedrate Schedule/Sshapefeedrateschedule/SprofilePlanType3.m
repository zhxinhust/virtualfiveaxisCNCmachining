function [AccT, DecT, ContT, SType] = SprofilePlanType3(Vstr, Vend, Vmax, Len, Lr4)
% º”ÀŸ + ‘»ÀŸ

global maxJerk;
global interpolationFrequence;

AccT = sqrt((Vend - Vstr) / maxJerk) * interpolationFrequence;
ContT = (Len - Lr4) / Vmax * interpolationFrequence;
DecT = 0;
SType = 3;