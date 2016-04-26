function y = FourthOrderPolynomial(C, x)
% 以C为系数的四阶多项式，x为自变量，y为输出值

y = C(1) * x^4 + C(2) * x^3 + C(3) * x^2 + C(4) * x + C(5);