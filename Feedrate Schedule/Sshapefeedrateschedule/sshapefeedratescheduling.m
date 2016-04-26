function sshapefeedrate = sshapefeedratescheduling(constraints, smoothpath, interpolationperiod)
% 对光顺后的刀路进行S形速度规划
% 输入参数：
% constraints，规定的约束，它是一个结构体，里面有以下成员：
%   selection ： 包含有选择的约束项，它包含有
%                   dynconstrsel ： 动力学约束，
%                   geoconstrsel ： 几何约束；
%                   oriconstrsel ： 刀轴转动约束；
%                   driconstrsel ： 各轴驱动约束；
%                   forconstrsel : 驱动力约束
%   settings : 包含具体各项的设置值；它包含 dynconstr 、geoconstr 、oriconstr 、 driconstr
%   、forconstr 四项
% interpolationperiod 插补周期

global KnotVector;  % 节点向量
global CP;      % 控制点
global curveDegree; % 曲线阶数
global p0;
global V0;

global maxJerk;	% 全局变量，最大跃度
global maxAcc;		% 全局变量，最大加速度
maxJerk = constraints.settings.dynconstr.maxjerk;
maxAcc = constraints.settings.dynconstr.maxacce;

global interpolationFrequence;
global interpolationPeriod;
interpolationPeriod = interpolationperiod;
interpolationFrequence = 1 / interpolationperiod;


if smoothpath.method == 1 || smoothpath.method == 2
    % 根据不同的格式，对这些全局变量进行初始化
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

% 进行速度扫描。
[subSegmentUPara, subSegmentFeedPeakSmall, subSegmentFeedPeakBig] = NurbsScanning(constraints, smoothpath, interpolationperiod);

% 求利用辛普森公式二分迭代求各段弧长
arcLengthVector = NurbsSubSegArcLenCal(subSegmentUPara);

% 对长度特别小的段进行合并调整
% [subSegmentUPara, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, arcLengthVector] = subSegRegulate(subSegmentUPara, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, arcLengthVector);

% 进行双向扫描
[subSegmentFeedPeakSmall] = NurbsBiDirectionScanning(subSegmentUPara, subSegmentFeedPeakSmall, arcLengthVector);

% 对Nurbs曲线进行前瞻处理
[subSegmentAccAccTime, subSegmentDecDecTime, subSegmentContVTime, subSegmentSType, subSegmentFinishTime, subSegmentFeedPeakSmall, subSegmentFeedPeakBig] =...
    NurbsLookAhead(subSegmentUPara, subSegmentFeedPeakSmall, subSegmentFeedPeakBig, arcLengthVector);

% 保存数据
sshapefeedrate.subSegmentUPara = subSegmentUPara;
sshapefeedrate.subSegmentFeedPeakSmall = subSegmentFeedPeakSmall;
sshapefeedrate.subSegmentFeedPeakBig = subSegmentFeedPeakBig;
sshapefeedrate.arcLengthVector = arcLengthVector;

sshapefeedrate.subSegmentAccAccTime = subSegmentAccAccTime;
sshapefeedrate.subSegmentDecDecTime = subSegmentDecDecTime;
sshapefeedrate.subSegmentContVTime = subSegmentContVTime;
sshapefeedrate.subSegmentSType = subSegmentSType;
sshapefeedrate.subSegmentFinishTime = subSegmentFinishTime;

% 清除全局变量
clear KnotVector
clear CP
clear curveDegree
clear p0
clear V0

clear maxJerk
clear maxAcc
clear interpolationFrequence
clear interpolationPeriod