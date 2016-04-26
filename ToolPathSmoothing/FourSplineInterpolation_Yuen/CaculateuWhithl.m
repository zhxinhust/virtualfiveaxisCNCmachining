function u = CaculateuWhithl( l, X, startL, S)
%计算以X为系数的九阶多项式l对应的u值

l = (l - startL) / S;   % 先变换到[0, 1]区间上
u = X(1) * (l.^9) + X(2)*(l.^8) + X(3)* (l.^7) + X(4)*(l.^6) + X(5)*(l.^5) + X(6)*(l.^4) + X(7)* (l.^3) + X(8)*(l.^2) + X(9)*l + X(10)*ones(length(l), 1 );

end

