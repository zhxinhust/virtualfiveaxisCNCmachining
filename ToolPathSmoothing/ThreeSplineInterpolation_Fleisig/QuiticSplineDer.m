function q = QuiticSplineDer(d1, d2, d3, d4, d5, d6, L, v)
% 用精度为4阶的中点差分公式求五阶球面Bezier的导数

delta = 0.005;
qm1 = QuinticSphericalBezier(d1, d2, d3, d4, d5, d6, L, v - delta * L);
qp1 = QuinticSphericalBezier(d1, d2, d3, d4, d5, d6, L, v + delta * L);
qm2 = QuinticSphericalBezier(d1, d2, d3, d4, d5, d6, L, v - 2 * delta * L);
qp2 = QuinticSphericalBezier(d1, d2, d3, d4, d5, d6, L, v + 2 * delta * L);

q = (-qp2 + 8 * qp1 - 8 * qm1 + qm2) / (12 * delta * L);