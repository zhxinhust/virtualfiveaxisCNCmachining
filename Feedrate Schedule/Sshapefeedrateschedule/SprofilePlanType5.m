function [AccT, DecT, ContT, SType] = SprofilePlanType5(Vstr, Vend, Vmax, Len)
% 加速 + 匀速 + 减速

global maxJerk;
global interpolationFrequence;

AccT = sqrt((Vmax - Vstr) / maxJerk);

DecT = sqrt((Vmax - Vend) / maxJerk);

ContT = (Len - (Vstr + Vmax) * AccT - (Vmax + Vend) * DecT) / Vmax * interpolationFrequence;

AccT = AccT * interpolationFrequence;

DecT = DecT * interpolationFrequence;

SType = 5;