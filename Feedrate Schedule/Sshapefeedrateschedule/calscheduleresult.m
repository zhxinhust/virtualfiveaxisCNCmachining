function scheduleresult = calscheduleresult(sshapefeedrate, smoothpath, interpolationperiod)
% 将规划得到的路径，计算速度极值曲线、规划曲线、加速度曲线等

global KnotVector;  % 节点向量
global CP;      % 控制点
global curveDegree; % 曲线阶数
global p0;
global V0;
global interpolationPeriod;
global interpolationFrequence;

interpolationPeriod = interpolationperiod;
interpolationFrequence = 1 / interpolationPeriod;

% 根据不同的格式，对这些全局变量进行初始化
if smoothpath.method == 1 || smoothpath.method == 2

    KnotVector = smoothpath.dualquatpath.dualquatspline.knotvector;
    CP = smoothpath.dualquatpath.dualquatspline.controlp;
    curveDegree = smoothpath.dualquatpath.dualquatspline.splineorder;
    p0 = smoothpath.dualquatpath.tip0;
    V0 = smoothpath.dualquatpath.vector0;
elseif smoothpath.method == 3
    KnotVector = smoothpath.foursplineinterpath.tipspline.knotvector;
    CP = smoothpath.foursplineinterpath.tipspline.controlp;
    curveDegree = smoothpath.foursplineinterpath.tipspline.splineorder;
end

subSegmentFeedPeakSmall = sshapefeedrate.subSegmentFeedPeakSmall;
subSegmentFeedPeakBig = sshapefeedrate.subSegmentFeedPeakBig;

subSegmentAccAccTime = sshapefeedrate.subSegmentAccAccTime;
subSegmentDecDecTime = sshapefeedrate.subSegmentDecDecTime;
subSegmentContVTime = sshapefeedrate.subSegmentContVTime;
subSegmentFinishTime = sshapefeedrate.subSegmentFinishTime;

% 进行插补计算，得到结果
scheduleresult = NurbsInterpProcess(subSegmentFeedPeakSmall, subSegmentFeedPeakBig, subSegmentAccAccTime, subSegmentDecDecTime, subSegmentContVTime, subSegmentFinishTime, smoothpath);

clear KnotVector
clear C
clear curveDegree
clear p0
clear V0
clear interpolationPeriod
clear interpolationFrequence