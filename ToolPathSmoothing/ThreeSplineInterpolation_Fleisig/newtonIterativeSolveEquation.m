function L = newtonIterativeSolveEquation(C, L0)
% 利用牛顿迭代法求解此四次方程，其中C为系数，L0为初始值

L1 = L0 - FourthOrderPolynomial(C, L0) / FourthOrderPolynomialDer(C, L0);
if abs(L1 - L0) < 0.00001
    L = L1;
else
    L = newtonIterativeSolveEquation(C, L1);
end
