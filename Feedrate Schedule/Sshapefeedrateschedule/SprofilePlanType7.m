function [AccT, DecT, ContT, SType] = SprofilePlanType7(Vstr, Vend, Vmax, Len, Lr4)
% ‘»ÀŸ + ºıÀŸ

global maxJerk;
global interpolationFrequence;

AccT = 0;
DecT = sqrt((Vstr - Vend) / maxJerk) * interpolationFrequence;
ContT = (Len - Lr4) / Vmax * interpolationFrequence;
SType = 7;
