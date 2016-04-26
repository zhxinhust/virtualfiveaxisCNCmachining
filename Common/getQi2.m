function Qi = getQi2(pi, i)
% 计算对偶四元数

global lastEigVector;   % 声明保存上次的特征向量，用来判断特征向量符号
global EigVectorSign;   % 特征向量符号的选择标志
global p0;
global V1;

p1 = [p0 V1];
% 计算旋转轴
k = cross(p1(4:6), pi(4:6));
k = k / norm(k);

% 计算旋转角度

% 2015-09-11 使用正弦求theta角，发现使用open pocket算例会出现刀轴矢量错误！
% theta = asin(norm(cross(p1(4:6), pi(4:6))));

theta = acos(dot(p1(4:6), pi(4:6))); 

% 这里要进行判断，看是否需要进行变号
if EigVectorSign == 1 && i ~= 1
	k = -k;
    theta = -theta;
end

% 这里要注意，由于特征向量的符号可正可负，在取值的时候要注意，这里选取与上一个点的变换矩阵的特征向量距离近的
if norm(k - lastEigVector) > norm(k + lastEigVector)
	k = -k;
    theta = -theta;
end
lastEigVector = k;

Qi(1:4) = [cos(theta / 2), sin(theta / 2) * k];   % 计算旋转四元数

Qi(5:8) = (quatmultiply(Qi(1 : 4), [0, p1(1:3)]) - quatmultiply([0, pi(1:3)], Qi(1 : 4))) / 2;  % 计算对偶部 R = (Q*p1 - pi*Q) / 2;

% 判断
if i == 1
	Q1(1:4) = Qi(1:4);
    Q1(2:4) = -Q1(2:4);
    
    Q1(5:8) = (quatmultiply(Q1(1 : 4), [0, p1(1:3)]) - quatmultiply([0, pi(1:3)], Q1(1 : 4))) / 2;
%     Q1(5:8) = -quatmultiply(D, Q1(1:4)) / 2;
	
	p11 = TransformViaQ(p1, Qi);
    p12 = TransformViaQ(p1, Q1);
	
	dis1 = norm(p11(1:3) - pi(1:3));
    dis2 = norm(p12(1:3) - pi(1:3));
    % 2015-09-11 这里只对刀尖点距离进行判断，没有
    if dis1 > dis2
        EigVectorSign = 1;
        Qi = Q1;
        lastEigVector = -lastEigVector;
    end
end