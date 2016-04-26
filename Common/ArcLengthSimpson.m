function L = ArcLengthSimpson(startPoint, endPoint)
% 利用辛普森公式计算单段曲线弧长

midPoint = (startPoint + endPoint) / 2;
segmentLength = endPoint - startPoint;

% 求曲线在起点、中点、终点处切矢长度f(u)
simpsonSum1 = ArcLengthDerivative(startPoint);
simpsonSum2 = ArcLengthDerivative(midPoint);
simpsonSum3 = ArcLengthDerivative(endPoint);

% 利用辛普森公式求积分
L = ((segmentLength / 6) * (simpsonSum1 + 4 * simpsonSum2 + simpsonSum3));
