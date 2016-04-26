function FP = SearchDominantPionts(P, curvatureThr, chordThrL, chordThrV, Q)
% ScanFeaturePionts(P) 扫描曲线，得到特征点。
% 输入的P为离散的数据点，curvatureThr为曲率阈值，chordThr为弓高点阈值 Q为位移对应的对偶四元数，在对刀轴矢量选择特征点时使用
% 扫描得到的特征点存放在全局变量 featurePointsIndex 和 featurePointNum 中

global featurePointsIndex;
global featurePointNum;
featurePointsIndex = 0;     % 使用全局变量一定要初始化，否则上次运行的结果不会清除
featurePointNum = 1;

PL = P(:, 1:3);                         % 刀尖点

pCount = size(P, 1);    % 数据点总数

% 计算每段的弦长
chordLenL = zeros(1, pCount - 1);   % 刀尖点曲线每段弦长

for i = 1 : pCount - 1
    chordLenL(i) = norm(PL(i + 1, :) - PL(i, :));
end

% 计算夹角的余弦值
LineCosL = zeros(1, pCount - 2);    % 刀尖点曲线各点处角度余弦值

for i = 1:pCount - 2
    LineCosL(i) = dot(PL(i + 2, :) - PL(i + 1, :),...
        PL(i + 1, :) - PL(i, :)) / (chordLenL(i + 1) * chordLenL(i));
end

% 扫描曲线，记录特征点
curvatureL = zeros(1, pCount - 2);
for i = 1:pCount - 2
    % 计算离散曲率
    curvatureL(i) = 2 * sqrt(1 - LineCosL(i)^2) / norm(PL(i + 2, :) - PL(i, :));
    p1to3V = PL(i + 2, :) - PL(i, :);
    p1to3NV(1) = -p1to3V(2);
    p1to3NV(2) = p1to3V(1);
    p1to3NV(3) = p1to3V(3);
    p1to2dotN = dot(PL(i + 1, :) - PL(i, :), p1to3NV);
    if p1to2dotN >= 0
        curvatureL(i) = -curvatureL(i);
    end
end

% 查找刀尖点曲线的曲率极小值点
curvatureMinIndexL = zeros(1, pCount - 3);
curvatureMinIndexL(1) = 1;
curvatureMinNumL = 2;
for i = 2:pCount - 3
    if abs(curvatureL(i)) < abs(curvatureL(i - 1)) && abs(curvatureL(i)) < abs(curvatureL(i + 1))
        curvatureMinIndexL(curvatureMinNumL) = i;
        curvatureMinNumL = curvatureMinNumL + 1;
    end
end

% 查找曲线中的曲率极值点和过零点
extremePIndexL(1) = 1;   % 搜索到的曲率极大值点和曲率过零点都存在此数组中
extremePNumL = 2;        % 表示数组长度
isMaxCurvatureL(1) = 1;  % 由于extremePIndex中既有曲率极值点，又有过零点，此变量进行区分。如果是曲率极大值点为1，否则为0
nearMinAbskSearchIndexL = 1;    % 表示i所在两个极小值点的区间
for i = 2:pCount - 3
    if(abs(curvatureL(i) > abs(curvatureL(i - 1)))) && abs(curvatureL(i)) > abs(curvatureL(i + 1))    
        % 判断为极大值，则查找与最近的左右两个极小值的差值
        % 先找到i点左右两极小值的区间
        while i > curvatureMinIndexL(nearMinAbskSearchIndexL)
            nearMinAbskSearchIndexL = nearMinAbskSearchIndexL + 1;
             if nearMinAbskSearchIndexL > length(nearMinAbskSearchIndexL)
                 nearMinAbskSearchIndexL = length(nearMinAbskSearchIndexL);
                 break;
             end
        end
        
        % 找到i点前的一个极小值fmincurvatureL
        if nearMinAbskSearchIndexL == 1
            fmincurvatureL = 0;
        else
            fmincurvatureL = abs(curvatureL(curvatureMinIndexL(nearMinAbskSearchIndexL)));
        end
        
        % 找到i点后一个极小值lmincurvatureL
        if nearMinAbskSearchIndexL >= curvatureMinNumL - 1
            lmincurvatureL = 0;
        else
            lmincurvatureL = abs(curvatureL(curvatureMinIndexL(nearMinAbskSearchIndexL + 1)));
        end
                
        % 如果此曲率极大值点曲率值超过前面和后面曲率极小值一定阈值后，认为是有效的极值点，保存下来
        if (abs(curvatureL(i)) - fmincurvatureL > curvatureThr) || (abs(curvatureL(i)) - lmincurvatureL > curvatureThr)
            extremePIndexL(extremePNumL) = i;
            isMaxCurvatureL(extremePNumL) = 1;
            extremePNumL = extremePNumL + 1;
        end
    % 对于不是极大值的点判断是否为过零点，过零点在判断弓高点的时候需要用到 
    elseif (curvatureL(i) * curvatureL(i - 1) < 0 && curvatureL(i) * curvatureL(i + 1) > 0) ...
%             ||...
%             (curvatureL(i) * curvatureL(i - 1) > 0 && curvatureL(i) * curvatureL(i + 1) < 0)
        extremePIndexL(extremePNumL) = i;
        isMaxCurvatureL(extremePNumL) = 0;
        extremePNumL = extremePNumL + 1;
    end
end

extremePIndexL(extremePNumL) = pCount;

for i = 1:extremePNumL - 1
    startIndex = extremePIndexL(i);
    endIndex = extremePIndexL(i + 1);
    
    % 首先判断起始点，如果起始点是极大值，则记录为特征点
    if isMaxCurvatureL(i) == 1
        featurePointsIndex(featurePointNum) = extremePIndexL(i);
        featurePointNum = featurePointNum + 1;
    end
    searchChord(startIndex, endIndex, P, Q, chordThrL, chordThrV);
end
featurePointsIndex(featurePointNum) = pCount;
featurePointNum = featurePointNum + 1;
FP = featurePointsIndex;

% 清除全局变量，避免被其他程序调用
clear featurePointsIndex
clear featurePointNum