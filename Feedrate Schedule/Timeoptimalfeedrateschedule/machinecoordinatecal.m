function mcr = machinecoordinatecal(deboorp, derorder, pindex)
% 计算机床坐标系下的一二阶导
% deboorp 刀路的deboor点，采用DeBoor公式计算出来，是二维矩阵，包含有导数信息
% derorder 计算阶数，如果deorder = 0，则只计算机床坐标，若等于1，则除了坐标还计算1阶导，最大支持二阶
% pindex 此点在路径中的序号，用来判断是否为第一个点，以避免旋转关节突变。
% 输出 mcr 为一二维矩阵。

global lastA;
global lastC;

L = 400;		% 机床机构参数，自己定义

x = deboorp(1, 1);
y = deboorp(1, 2);
z = deboorp(1, 3);
i = deboorp(1, 4);
j = deboorp(1, 5);
k = deboorp(1, 6);

vector = [i, j, k];

% 反解得到各轴坐标
% A = acos(k / norm(vector));
A = acos(k);
C = -atan(i / j);

% 避免突变
if pindex > 1
    if abs(A - lastA) > pi / 2
        if A > lastA
            A = A - 2 * pi;
        else
            A = A + 2 * pi;
        end
    end

    if abs(C - lastC) > 3 * pi / 4
        if C > lastC
            C = C - pi;
        else
            C = C + pi;
        end
    end
elseif pindex == 1
    lastA = A;
    lastC = C;
end
lastA = A;
lastC = C;

X = x + L * sin(A) * sin(C);
Y = y - L * sin(A) * cos(C);
Z = z + L * cos(A) - L;
mcr(1, :) = [A, C, X, Y, Z];

if derorder > 0
    xu = deboorp(2, 1);
    yu = deboorp(2, 2);
    zu = deboorp(2, 3);
    iu = deboorp(2, 4);
    ju = deboorp(2, 5);
    ku = deboorp(2, 6);

	% 机床坐标系下的刀具路径对参数的一阶导数
% 	Au = (k * (i * iu + j * ju) - ku * (i ^ 2 + j ^ 2)) / norm(vector)^2 / sqrt(i^2 + j^2);
    Au = -ku / sqrt(1 - k^2);
%     Au = (k * (i * iu + j * ju) - ku * (i ^ 2 + j ^ 2)) / norm(vector) ;
	Cu = -(iu * j - i * ju) / (i ^ 2 + j ^ 2);
	Xu = xu + L * (Au * cos(A) * sin(C) + Cu * sin(A) * cos(C));
	Yu = yu - L * (Au * cos(A) * cos(C) - Cu * sin(A) * sin(C));
	Zu = zu - L * Au * sin(A);
	mcr(2, :) = [Au, Cu, Xu, Yu, Zu];
	
	if derorder > 1
        xuu = deboorp(3, 1);
        yuu = deboorp(3, 2);
        zuu = deboorp(3, 3);
        iuu = deboorp(3, 4);
        juu = deboorp(3, 5);
        kuu = deboorp(3, 6);	
        % 计算二阶导
% 		Auu = (k * ((i * ku - iu * k)^2 + (j * ku - ju * k)^2 + (i * ju - iu * j)^2) + (k * (i * iu + j * ju) - kuu * (i ^ 2 + j ^ 2)) * (i ^ 2 + j ^ 2 + k ^ 2)) / (i ^ 2 + j ^ 2 + k ^ 2)^(3 / 2);
		
%         Auu = (k * (iu^2 + i * iuu + ju^2 + j * juu) - kuu * (i^2 + j^2) - ku * (i * iu + j * ju)) / (i^2 + j^2 + k^2) / sqrt(i^2 + j^2) -...
% 			((i * iu + j * ju) * (i^2 + j^2 + k^2) / (i^2 + j^2) + 2 * (i * iu + j * ju + k * ku)) * (k * (i * iu + j * ju) - ku * (i^2 + j^2)) / (i^2 + j^2 + k^2)^2 / sqrt(i^2 + j^2);
        Auu = (-kuu * (1 - k^2) - k * ku ^ 2) / (1 - k^2) ^ (3 / 2);

        Cuu = -((iuu * j - i * juu) * (i ^ 2 + j ^ 2) - 2 * (iu * j - i * ju) * (i * iu + j * ju)) / (i ^ 2 + j ^ 2)^2;
		
		Xuu = xuu + L * (Auu * cos(A) * sin(C) + Cuu * sin(A) * cos(C) - ((Au)^2 + (Cu) ^ 2) * sin(A) * sin(C) + 2 * Au * Cu * cos(A) * cos(C));
		
		Yuu = yuu - L * (Auu * cos(A) * cos(C) - Cuu * sin(A) * sin(C) - ((Au)^2 + (Cu) ^ 2) * sin(A) * cos(C) - 2 * Au * Cu * cos(A) * sin(C));
		
		Zuu = zuu - L * (Auu * sin(A) + (Au)^2 * cos(A));
		mcr(3, :) = [Auu, Cuu, Xuu, Yuu, Zuu];  % 保存结果
        
        % 求三阶导
        if derorder > 2
            xuuu = deboorp(4, 1);
			yuuu = deboorp(4, 2);
			zuuu = deboorp(4, 3);
			iuuu = deboorp(4, 4);
			juuu = deboorp(4, 5);
			kuuu = deboorp(4, 6);

% 			Auuu = (3 * k * ku * kuu * (k^2 - 1) - (k^2 - 1)^2 * kuuu - (2 * k ^2 + 1) * ku^3) / (1 - k^2)^(5 / 2);
            Auuu = ((1 - k^2) * ((k^2 - 1) * kuuu - ku ^ 3) + 3 * k * ku * ((k^2 - 1) * kuu - ku ^ 2 * k)) / (1 - k^2) ^ (5 / 2);
			% Cuuu = ((2 * (iuuu * j + iuu * ju - iu * juu - i * juuu) * (i * iu + j * ju) - 2 * (iuu * j - i * juu) * (iu^2 + i*iu + ju^2 + j * juu)) ...
			% 		  - 4 * (i * iu + j * ju) * (iuu * j - i * juu)) / (i ^ 2 + j ^ 2)^2;
			
			Cuuu = -(((iuuu * j + iuu * ju - iu * juu - i * juuu) * (i^2 + j ^ 2) + 2*(iuu * j - i * juu) * (i * iu + j * ju) - 2*(iuu * j - juu * i) * (i * iu + j * ju) - 2 * (iu * j - i * ju) * (iu^2 + i * iuu + ju ^ 2 + j * juu)) * (i^2 + j^2)...
					- 4 * ((iuu * j - i * juu) * (i ^ 2 + j ^ 2) - 2 * (i * ju - i * ju) * (i * iu + j * ju)) * (i * iu + j * ju)) / (i ^ 2 + j ^ 2) ^ 3;
			
			Xuuu = xuuu + L * (Auuu * cos(A) * sin(C) + Auu * (-Au * sin(A) * sin(C) + Cu * cos(A) * cos(C)) + Cuuu * sin(A) * cos(C) + Cuu * (Au * cos(A) * cos(C) - Cu * sin(A) * sin(C)) - 2 * (Auu * Au + Cuu * Cu) * sin(A) * sin(C)...
					+ (Au ^ 2 + Cu ^ 2) * (Au * cos(A) * sin(C) + Cu * sin(A) * cos(C)) + 2 * (Auu * Cu + Au * Cuu) * cos(A) * cos(C) - 2 * Au * Cu * (Au * sin(A) * cos(C) + Cu * cos(A) * sin(C)));
                
			Yuuu = yuuu - L * (Auuu * cos(A) * cos(C) - Auu * (Au * sin(A) * cos(C) + Cu * cos(A) * sin(C)) - Cuuu * sin(A) * sin(C) - Cuu * (Au * cos(A) * sin(C) + Cu * sin(A) * cos(C)) - 2 * (Auu * Au + Cuu * Cu) * sin(A) * cos(C)...
					- (Au ^ 2 + Cu ^ 2) * (Au * cos(A) * cos(C) - Cu * sin(A) * sin(C))) - 2 * (Auu * Cu + Au * Cuu) * cos(A) * sin(C) - 2 * Au * Cu * (-Au * sin(A) * sin(C) + Cu * cos(A) * cos(C));
                
			Zuuu = zuuu - L * (Auuu * sin(A) + 3 * Auu * Au * cos(A) - Au ^ 3 * sin(A));
			
			mcr(4, :) = [Auuu, Cuuu, Xuuu, Yuuu, Zuuu];  % 保存结果
        end
	end
end
