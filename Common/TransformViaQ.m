function pi = TransformViaQ(p, Qi)
% pi = TransformViaQ(p, Qi)计算p点经过对偶四元数Qi变换后得到的点pi
% p为变换之前的点，形式为(x,y,z)，Qi为变换的对偶四元数

% 将坐标值转换为对偶四元数的形式
pq = zeros(1, 8);
pq(1) = 1;
pq(2:4) = 0;
pq(6:8) = p(1:3);
pq(5) = 0;

Qib = Qi;
Qib(5:8) = -Qi(5:8);

Qis = Qi;
Qis(2:4) = -Qi(2:4);
Qis(6:8) = -Qi(6:8);

ptemp = dualQuaternionsMultiply(dualQuaternionsMultiply(Qib, pq), Qis) / dot(Qib(1:4), Qis(1:4));

pi = ptemp(6:8) / ptemp(1);