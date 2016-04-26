function [subSegmentUPara, subSegmentFeedPeakSmall, subSegmentFeedPeakBig] = NurbsScanning(constraints, smoothpath, interpolationperiod)
% 进行速度极值扫描，得到分段信息及各段的速度最大最小值以及相应分段的u的值

Ts = interpolationperiod / 2;			% 插补周期

% 刀尖点和刀轴参考点的初始点
p0 = smoothpath.dualquatpath.tip0;



chordErr = constraints.settings.geoconstr;

curvatureNurbsPreLast = 0;	% 上上次的曲率值;
curvatureNurbsLast = 0; 	% 上次的曲率值
curvatureNurbs = 0;			% 曲率值
lastFiveStepFeed = zeros(1, 4);	% 前面四步时的速度，用来使用5步法求速度导矢
 
oneSubSegmentFlag = 0;	% 只有一个子段的标志位
subSegmentMaxFeed = 0;	% 子段内最大速度；

uNurbs = 0;	% 曲线参数

cenAccLimitedCurvature = constraints.settings.dynconstr.maxacce / constraints.settings.dynconstr.maxvelo^2;	% 向心加速度设定的曲率阈值

jerkLimitedCurvature = sqrt(constraints.settings.dynconstr.maxjerk / constraints.settings.dynconstr.maxvelo^3);	% 跃度设定的曲率值

% 取几个限制的最小值;
curvatureLimitMin = min([0.5, cenAccLimitedCurvature, jerkLimitedCurvature]);

subSegmentNum = 2;
stepNumber = 1;

while uNurbs < 1
    if smoothpath.method == 1 || smoothpath.method == 2
        
        % 计算型值点及一二三阶导矢
        DeBoorP = DeBoorCoxNurbsCal(uNurbs, smoothpath.dualquatpath.dualquatspline, 2);
        % 求型值点
        knotCor(stepNumber, :) = TransformViaQ(p0, DeBoorP(1, :));    
    elseif smoothpath.method == 3
        % 如果采用四样条插值，则只计算刀尖点
        DeBoorP = DeBoorCoxNurbsCal(uNurbs, smoothpath.foursplineinterpath.tipspline, 2);
        knotCor(stepNumber, :) = DeBoorP(1, :);
    end
    % 更新保存的曲率值;
    curvatureNurbsPreLast = curvatureNurbsLast;
	curvatureNurbsLast = curvatureNurbs;
    
    if smoothpath.method == 1 || smoothpath.method == 2
        % 求当前点的曲率
        [der1, der2] = DerCalFromQ(p0, DeBoorP(2, :), DeBoorP(3, :), DeBoorP(1, :));    % 求一二阶导矢
        curvatureNurbs = norm(cross(der1, der2)) / norm(der1)^3;                        % 根据曲率公式求曲率
    elseif smoothpath.method == 3
        curvatureNurbs = norm(cross(DeBoorP(2, :), DeBoorP(3, :))) / norm(DeBoorP(2, :))^3;
    end
    
%     curvetureArr(stepNumber, 1) = uNurbs;
%     curvetureArr(stepNumber, 2) = curvatureNurbs;
    
    curvatureRadiusNurbs = 1 / curvatureNurbs;	% 计算曲率半径
	
    if constraints.selection.geoconstrsel == 1
        % 根据Ts，曲率半径，弓高误差，进给速度，kcbc，等计算Vaf，Vcbf，确定V(ui)
        chordLimitedFeed = 2 / Ts * sqrt(curvatureRadiusNurbs ^ 2 - (curvatureRadiusNurbs - chordErr)^2);
    else
        chordLimitedFeed = constraints.settings.dynconstr.maxvelo;
    end
	
	adaptiveAlgorithmFeed = min([constraints.settings.dynconstr.maxvelo, chordLimitedFeed]);     % Vaf
	curvatureAlgorithmFeed = 1 * constraints.settings.dynconstr.maxvelo / (curvatureNurbs + 1);	% Vcbf
	
    if constraints.selection.dynconstrsel == 1
        maxAccLimitedFeed = sqrt(constraints.settings.dynconstr.maxacce / curvatureNurbs);					% 计算加速度速度约束	
        maxJerkLimitedFeed = (constraints.settings.dynconstr.maxjerk / curvatureNurbs^2)^(1 / 3);	% 计算跃度速度约束
    else
        maxAccLimitedFeed = constraints.settings.dynconstr.maxvelo;
        maxJerkLimitedFeed = constraints.settings.dynconstr.maxvelo;
    end
	
	% 得到Vaf, Vbf, F 以及加速度、跃度约束下的速度最小值
	currentStepFeed = min([adaptiveAlgorithmFeed, curvatureAlgorithmFeed, constraints.settings.dynconstr.maxvelo, maxAccLimitedFeed, maxJerkLimitedFeed]);
	
    feedLimitArr(stepNumber) = currentStepFeed;
    
	% 利用5步法求速度导数
	currentStepFeedDer1 = 1 / (12 * Ts) * (3 * lastFiveStepFeed(1) - 16 * lastFiveStepFeed(2) + 36 * lastFiveStepFeed(3) - 48 * lastFiveStepFeed(4) + 25 * currentStepFeed);
	% 更新保存的前几步速度
	lastFiveStepFeed = [lastFiveStepFeed(2:4), currentStepFeed];
	
	% 确定下一步步长，并保存当前参数u
	uNurbsLast = uNurbs;
% 	uNurbs = uNurbs + (currentStepFeed * Ts + Ts^2 * currentStepFeedDer1 / 2) / norm(DeBoorP(2, :)) - (currentStepFeed * Ts)^2 * (dot(DeBoorP(2, :), DeBoorP(3, :))) / (2 * (norm(DeBoorP(2, :)))^4);
	uNurbs = uNurbs + 0.0005;
	if (uNurbs > uNurbsLast) && (uNurbs > 0.001)
		if (curvatureNurbsLast > curvatureNurbs) && (curvatureNurbsLast > curvatureNurbsPreLast)
			% 如果都不满足曲率阈值条件，那么将曲线作为一个子段处理，保存相应的数据；
			if curvatureNurbsLast >= curvatureLimitMin
				oneSubSegmentFlag = 1;
				subSegmentUPara(subSegmentNum) = uNurbsLast;
				subSegmentFeedPeakBig(subSegmentNum) = subSegmentMaxFeed;
				subSegmentFeedPeakSmall(subSegmentNum) = lastStepFeed;
                splitPoints(subSegmentNum, :) = knotCor(stepNumber, :);     % 保存分段点坐标，方便查看用
				subSegmentNum = subSegmentNum + 1;
				subSegmentMaxFeed = 0;
			end
		end
	end	
	% 更新子段内最大速度；
	subSegmentMaxFeed = max(subSegmentMaxFeed, currentStepFeed);
	% 保存当前速度值；
	lastStepFeed = currentStepFeed;
    
%     uNurbs = uNurbs + 0.001;      % 测试用，不适用预插补，直接等距累加参数u
    stepNumber = stepNumber + 1;
end

% figure;
% % 绘制对偶四元数求得的曲率曲线
% plot(curvetureArr(:, 1), curvetureArr(:, 2));
% % readCurvature = importdata('.\data\inputdata\Curvature.txt');
% % hold on;
% % plot(readCurvature(:, 1), readCurvature(:, 2), 'r');
% set(gca, 'fontsize', 25);
% title('Curvature');
% ylim([0 5]);
% hold on;
% % 绘制用VC程序求得的曲率曲线
% curvatureVs = importdata('Curvature.txt');
% plot(curvatureVs(:, 1), curvatureVs(:, 2), 'r');
% % 绘制用Matlab直接对刀尖点插值求得的曲率曲线
% load('interpolateCurvature.mat');
% plot(curvatureArr(:, 1), curvatureArr(:, 2), 'g');


if oneSubSegmentFlag == 1
	% 最初子段的起始速度为0 
	subSegmentFeedPeakSmall(1) = 0;
	% 最末子段的终止速度为0
	subSegmentUPara(subSegmentNum) = 1;
	subSegmentFeedPeakSmall(subSegmentNum) = 0;
	subSegmentFeedPeakBig(subSegmentNum) = subSegmentMaxFeed;
else
	% 如果没有速度拐点，那么初始速度和终止速度均为0，并且最大速度为整段的最大速度
	subSegmentFeedPeakSmall(1) = 0;
	subSegmentUPara(subSegmentNum) = 1;
	subSegmentFeedPeakSmall(subSegmentNum) = 0;
	subSegmentFeedPeakBig(2) = subSegmentMaxFeed;
end

% figure;
% plot3(knotCor(:, 1), knotCor(:, 2), knotCor(:, 3));
% hold on;
% plot3(splitPoints(:, 1), splitPoints(:, 2), splitPoints(:, 3), '*r');
% title('split points', 'fontsize', 24);
% set(gca, 'fontsize', 25);