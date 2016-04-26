function Nip = oneBasisFun(u, i, p, U)
% oneBasisFun(u, i, p, U)
% 计算单个基函数的值Nip
% 输入：
% p为基函数阶数
% U为节点向量

m = length(U) - 1;

% 对首末处的处理
if ((i == 0) & (u == U(1))) | ((i == m - p - 1) & (u == U(m + 1)))
    Nip = 1.0;
    return;
end

% 考虑局部性
if (u < U(i + 1)) | (u >= U(i + p + 2))
     Nip = 0;
    return;
end

% 初始化0次基函数
for j = 0:p
    if u >= U(i + j + 1) && u < U(i + j + 2)
        N(j + 1) = 1.0;
    else
        N(j + 1) = 0;
    end
end

% 计算三角形表
for k = 1:p
    if N(1) == 0
        saved = 0;
    else
        saved = ((u - U(i + 1)) * N(1)) / (U( i + k + 1) - U(i + 1));
    end
    
    for j = 0:p - k
        Uleft = U(i + j + 2);
        Uright = U(i + j + k + 2);
        if N(j + 2) == 0
            N(j + 1) = saved;
            saved = 0;
        else
            temp = N(j + 2) / (Uright - Uleft);
            N(j + 1) = saved + (Uright - u) * temp;
            saved = (u - Uleft) * temp;
        end
    end
    Nip = N(1);
end
