function u = SecondTalorForInterp(uNurbs, lastStepFeed, lastStepAcc, deBoorP, firstSegFlag)
% 进行泰勒二阶展开计算插补步长

global interpolationPeriod;


if firstSegFlag == 0
    u = 0;
else
    u = uNurbs + (lastStepFeed * interpolationPeriod + interpolationPeriod^2 * lastStepAcc / 2) / norm(deBoorP(2, :)) - ...
		(lastStepFeed * interpolationPeriod)^2 * dot(deBoorP(2, :), deBoorP(3, :)) / (2 * (norm(deBoorP(2, :)))^4);
end