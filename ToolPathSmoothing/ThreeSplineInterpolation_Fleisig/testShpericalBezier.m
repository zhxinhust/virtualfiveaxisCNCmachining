clear;
close all;

q = [1.0000000, 0.0000000, 0.0000000;
    -0.995244, 0.0497622, 0.0837469;
    0.9909890, 0.0990989, 0.0901104;
    -0.988840, 0.1483260, 0.0139545;
    0.9778890, 0.1955920, -0.0740123;
    -0.965972, 0.2414930, -0.0926294;
    0.9574830, 0.2872450, -0.0267536];

n = size(q, 1) - 1;
v0 = [0.0000000, 0.2512177, 3.2112520];
a0 = [0.0000000, -0.128396, -2.356475];

d1 = q(1, :);

d2 = sin(norm(v0) / 3) * v0 / norm(v0) + cos(norm(v0) / 3) * d1;
d2 = d2 / norm(d2);

sita = acos(dot(d2, d1));
w = sin(sita) * a0 / (6 * sita) - dot(a0, d2) * (d2 - d1*cos(sita)) / (6 * sin(sita) * sita) + (1 + dot(a0, d2) / (6 * sita * sin(sita))) * sita * (cos(sita) * d2 - d1) / sin(sita);

d3 = sin(norm(w)) * w / norm(w) + cos(norm(w)) * d2;
d3 = d3 / norm(d3);

cubicControlP2(1, :) = d2;
cubicControlP3(1, :) = d3;

for i = 2:n

    d2 = cubicControlP2(i - 1, :);
    d3 = cubicControlP3(i - 1, :);
    d4 = q(i, :);
    
    d2i = 2 * dot(d3, d4) * d4 - d3;
    d2i = d2i / norm(d2i);
    
    sita = acos(dot(d3, d2));
    sita2 = acos(dot(d3, d4));
    
    w = sita * (cos(sita) * d3 - d2) / sin(sita) - 2 * sita2 * (d4 - d3 * sin(sita2)) / sin(sita2);
    temp = sin(norm(w)) * w / norm(w) + cos(norm(w)) * d3;
    d3i = 2 * dot(temp, d4) * d4 - temp;
    d3i = d3i / norm(d3i);
    
    cubicControlP2(i, :) = d2i;       
    cubicControlP3(i, :) = d3i;
end

pNum = 1;
for i = 1:n
    for v = 0:0.001:1
        CubicP(pNum, :) = CubicSphericalBezier(q(i, :), cubicControlP2(i, :), cubicControlP3(i, :), q(i + 1, :), 1, v);
        pNum = pNum + 1;
    end
end

figure;
plot3(CubicP(:, 1), CubicP(:, 2), CubicP(:, 3), 'r');
hold on;

plot3(q(:, 1), q(:, 2), q(:, 3), 'b');


