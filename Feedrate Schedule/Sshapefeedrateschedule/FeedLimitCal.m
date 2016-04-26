function feedLimit = FeedLimitCal(interpStepCurvature)

global chordErr;
global blockFeed;
global maxAcc;
global maxJerk;
global interpolationPeriod;

curvatureRadius = 1 / interpStepCurvature;  % 曲率半径

chordLimitFeed = 2 * sqrt(curvatureRadius^2 - (curvatureRadius - chordErr)^2) / interpolationPeriod;
curvatureAlgorithmFeed = blockFeed / (interpStepCurvature + 1); % Vcbf
accLimitFeed = sqrt(maxAcc / interpStepCurvature);              % 加速度约束
jerkLimitFeed = (maxJerk / interpStepCurvature^2) ^ (1 / 3);    % 跃度约束

feedLimit = min([blockFeed, chordLimitFeed, curvatureAlgorithmFeed, accLimitFeed, jerkLimitFeed]);