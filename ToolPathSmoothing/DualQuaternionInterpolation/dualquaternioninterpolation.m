function [CQ, U, tip0, vector0] = dualquaternioninterpolation(data, splineorder, parameterizationmethod)
% 采用B样条对偶四元数插值五轴刀路
% 输入参数
% data: 离散刀路数据
% splineorder 曲线阶数
% parameterizationmethod
% 参数化方法，1：采用对偶四元数向心参数化，2：采用对偶四元数弦长参数化，3：刀尖点向心参数化，4：刀尖点弦长参数化
%
% 输入参数
% CQ 对偶四元数控制点
% U 拟合后的节点矢量
% tip0 对偶四元数需要用到的初始点
% vector0 对偶四元数需要用到的初始向量

% 求对偶四元数需要用到的初始点
global p0;
p0 = [0 0 0];
tip0 = p0;

% 求对偶四元数需要用到的初始化向量
global V1;
V1 = [0 0 1];
% V1 = [sqrt(3)/3 sqrt(3)/3 sqrt(3)/3];
vector0 = V1;

% 保存上次求Q时旋转矩阵的特征向量，用来判断特征向量的符号
global lastEigVector;
lastEigVector = [0, 0, 0];

% 在求特征向量的时候符号的标志
global EigVectorSign;
EigVectorSign = 0;

pCount = size(data, 1);     % 获取数据点数量

Q = zeros(pCount, 8);

% 求对偶四元数
for i = 1:pCount
    Q(i, :) = getQi2(data(i, :), i);
end

% 对曲线进行拟合
[CQ, U] = dualquatinter(splineorder, data, Q, parameterizationmethod);

% 清除全局变量，避免在其他函数中无调用
clear p0
clear V1
clear lastEigVector
clear EigVectorSign