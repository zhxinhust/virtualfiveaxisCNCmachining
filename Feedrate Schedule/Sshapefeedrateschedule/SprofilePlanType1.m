function [subSegmentAccAccTime, subSegmentDecDecTime, subSegmentContVTime, subSegmentSType] = SprofilePlanType1(subSegmentVstr, subSegmentVend, subSegmentVmax, subSegmentLength)
% 恒速段速度规划

global interpolationFrequence;

subSegmentAccAccTime = 0;
subSegmentDecDecTime = 0;
subSegmentContVTime = subSegmentLength / subSegmentVstr * interpolationFrequence;
subSegmentSType = 1;