function index = findSpan(n, p, u, U)

% 利用二分法得到u所在节点向量的区间号
% 输入n,p,u,U。返回所在区间的下标
% n = m - p - 1，m为节点总数-1
% p为要求的基函数阶数
% u为参数
% U为节点向量

if u == U(n + 2)
    index = n;
    return;
end

low = p + 1;
high = n + 2;
mid = floor((low + high) / 2);
 
i = 1;
if u < 0
    while U(i) == 0
        i = i + 1;
    end
    index = i - 2;
    return;
end

if u >= 1
    while U(i) < 1
        i = i + 1;
    end
    index = i - 2;
    return;
end


 while u < U(mid) || u >= U(mid + 1)
     if u < U(mid)
         high = mid;
     else
         low = mid;
     end
     mid = floor((low + high) / 2);
 end
 index = mid - 1;