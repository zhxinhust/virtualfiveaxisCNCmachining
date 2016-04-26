function N = basisFuns(i, u, p, U)
% 计算得到非零的B样条基函数的值
% 输入i为要计算的Ni,p中的索引值，一般用findSpan函数获得
% u为参数
% p为阶数
% U为节点向量
% 输出N为一个向量，其中包含所有的非零值
N = zeros(1, p + 1);
right = zeros(1, p + 1);
left = zeros(1, p + 1);
N(1) = 1;

for j = 1: p
    left(j + 1) = u - U(i + 1 - j + 1);
    right(j + 1) = U(i + j + 1) - u;
    saved = 0;
    for r = 0:j - 1
        temp = N(r + 1) / (right(r + 2) + left(j - r + 1));
        N(r + 1) = saved + right(r + 2) * temp;
        saved = left(j - r + 1) * temp;
    end
    N(j + 1) = saved;
end
