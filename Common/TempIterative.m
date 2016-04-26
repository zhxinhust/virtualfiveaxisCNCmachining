function P = TempIterative(CtrlP, indexInterative)

global curveDegree; % ½×Êý
global KnotVector;

n = size(CtrlP, 1);
m = size(CtrlP, 2);

if indexInterative ~= n
    P = curveDegree * (CtrlP(indexInterative + 1, :) - CtrlP(indexInterative, :)) /...
        (KnotVector(indexInterative + curveDegree + 1) - KnotVector(indexInterative + 1));
else
%     P = curveDegree * (- CtrlP(indexInterative, :)) /...
%         (KnotVector(indexInterative + curveDegree + 1) - KnotVector(indexInterative + 1));
    P = zeros(1, m);
end