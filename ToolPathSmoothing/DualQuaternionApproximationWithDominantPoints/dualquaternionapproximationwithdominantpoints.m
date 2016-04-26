function [CQ, U, errtip, errorie, tip0, vector0] = dualquaternionapproximationwithdominantpoints(data, splineorder, curvaturethr, tipchord, orientationchord, tipiterativeaccu, orientationiterativeaccu, parameterizationmethod)
% 采用特征点选择的对偶四元数逼近算法
% 输入参数：
% data: 离散刀路数据
% splineorder 曲线阶数
% curvaturethr 特征点选择时曲率阈值
% tipchord 特征点选择时刀尖点弦高阈值
% orientationchord 特征点选择时刀轴矢量弦高阈值
% tipiterativeaccu 迭代拟合时刀尖点允许误差
% orientationiterativeaccu 迭代拟合时刀轴矢量允许误差
% parameterizationmethod
% 参数化方法，1：采用对偶四元数向心参数化，2：采用对偶四元数弦长参数化，3：刀尖点向心参数化，4：刀尖点弦长参数化
%
% 输出参数：
% CQ 对偶四元数控制点
% U 拟合后的节点矢量
% errtip 刀尖点拟合误差
% errorie 刀轴矢量拟合误差
% tip0 对偶四元数需要用到的初始点
% vector0 对偶四元数需要用到的初始向量

global wkDominant; % 特征点权重系数
wkDominant = 4;

% 保存上次求Q时旋转矩阵的特征向量，用来判断特征向量的符号
global lastEigVector;
lastEigVector = [0, 0, 0];

% 在求特征向量的时候符号的标志
global EigVectorSign;
EigVectorSign = 0;

global p0;
p0 = [0 0 0];
tip0 = p0;

global V1;
V1 = [ 0 0 1];
% V1 = [sqrt(3)/3 sqrt(3)/3 sqrt(3)/3];
vector0 = V1;

pCount = size(data, 1);     % 获取数据点数量

Q = zeros(pCount, 8);

for i = 1:pCount
    Q(i, :) = getQi2(data(i, :), i);
end

% 进行筛选特征点
dominantPIndex = SearchDominantPionts(data, curvaturethr, tipchord, orientationchord, Q);

% 对曲线进行拟合
[CQ, U, Ub, NFul] = BSplineMotionFitting(splineorder, data, dominantPIndex, Q, parameterizationmethod);

[QIterat, ErrV, U2, dominantPAf, NFul] = iterativeFitRealPart(CQ, U, Ub, Q, splineorder, data, dominantPIndex, orientationiterativeaccu, NFul);
[QIterat, ErrCL, ErrRL, U2, dominantPAf, NFul] = iterativeFitting(QIterat, U2, Ub, Q, splineorder, data, dominantPAf, tipiterativeaccu, NFul);

CQ = QIterat;
U = U2;

errtip = ErrCL;
vector1 = [0 V1];

for i = 1:pCount
    % 先找到当前点所在特征点段, i在[dominantPIndex(dominantPi), dominantPIndex(dominantPi + 1))

    % 计算误差
    Qtemp = NFul(i, :) * CQ;     % 直接利用系数矩阵相乘得到插值点，减少计算量
    vectorTemp = quatmultiply(quatmultiply(Qtemp(1:4), vector1), quatconj(Qtemp(1:4))) / quatnorm(Qtemp(1:4));   % 计算拟合得到的刀轴矢量
    
    % 计算在离散点处的误差，采用直接余弦求
    ErrV(i) = abs(acos(dot(vectorTemp(2:4) / norm(vectorTemp(2:4)), data(i, 4:6) / norm(data(i, 4:6))))) * 180 / pi;
	%ErrV(i) = acos(dot((p2Fit - pFit) / norm((p2Fit - pFit)), P(i, 4:6) / norm(P(i, 4:6)))) * 180 / pi;	% 计算刀轴矢量的角度偏差
end
errorie = ErrV;

% 清除全局变量
clear wkDominant
clear lastEigVector
clear EigVectorSign
clear p0
clear V1