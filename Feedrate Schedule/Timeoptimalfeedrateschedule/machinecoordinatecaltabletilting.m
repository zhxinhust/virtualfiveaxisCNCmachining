function mcr = machinecoordinatecaltabletilting(deboorp, derorder, pindex)
% 计算机床坐标系下的一二阶导
% deboorp 刀路的deboor点，采用DeBoor公式计算出来，是二维矩阵，包含有导数信息
% derorder 计算阶数，如果deorder = 0，则只计算机床坐标，若等于1，则除了坐标还计算1阶导，最大支持二阶
% pindex 此点在路径中的序号，用来判断是否为第一个点，以避免旋转关节突变。
% 输出 mcr 为一二维矩阵。

global lastA;
global lastC;

Ly = 0;		% 机床机构参数，自己定义
Lz = 41;

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
C = atan(i / j);

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

X = x * cos(C) + (Ly - y) * sin(C);
Y = x * cos(A) * sin(C) + (y - Ly) * cos(A) * cos(C) + (Lz - z) * sin(A) + Ly;
Z = (x - Ly) * sin(A) * sin(C) + y * sin(A) * cos(C) + (z - Lz) * cos(A) + Lz; 

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
	Cu = (iu * j - i * ju) / (i ^ 2 + j ^ 2);
	
	Xu = (xu - y * Cu) * cos(C) - (x * Cu + yu) * sin(C);
	
	Yu = (xu - y * Cu + Ly * Cu) * cos(A) * sin(C) - x * Au * sin(A) * sin(C) - (y - Ly) * Au * sin(A) * cos(C) + (yu + x * Cu) * cos(A) * cos(C) - zu * sin(A) + (Lz - z) * Au * cos(A);
	
	Zu = (xu - y * Cu) * sin(A) * sin(C) + (x * Cu - Ly * Cu + yu) * sin(A) * cos(C) + (x - Ly) * Au * cos(A) * sin(C) + y * Au * cos(A) * cos(C) + zu * cos(A) - (z - Lz) * Au * sin(A);
	
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

        Cuu = ((iuu * j - i * juu) * (i ^ 2 + j ^ 2) - 2 * (iu * j - i * ju) * (i * iu + j * ju)) / (i ^ 2 + j ^ 2)^2;
		
		Xuu = (xuu - 2 * yu * Cu - y * Cuu - x * Cu ^ 2) * cos(C) - (2 * xu * Cu - y * Cu ^ 2 + x * Cuu + yuu) * sin(C);
		
		Yuu = (xuu - 2* yu * Cu - y * Cuu + Ly * Cuu - x * Au ^ 2 - x * Cu^2) * cos(A) * sin(C) - (2 * xu * Au - 2 * y * Au * Cu + 2 * Ly * Au * Cu + x * Auu) * sin(A) * sin(C)...
				+ (2* xu * Cu - y * Cu^2 + Ly * Cu^2 - y * Au^2 + Ly * Au^2 + yuu + x * Cuu) * cos(A) * cos(C) - (2* x * Au * Cu + 2* yu * Au + (y - Ly) * Auu) * sin(A) * cos(C) ...
				- (zuu + (Lz - z) * Au^2) * sin(A) + ((Lz - z) * Auu - 2 * zu * Au) * cos(A);
				
		Zuu = (xuu - 2 * yu * Cu - y * Cuu - (x - Ly) * (Cu^2 + Au^2)) * sin(A) * sin(C) + (2 * xu * Au - 2 * y * Au * Cu + (x - Ly) * Auu) * cos(A) * sin(C)...
				+ (2 * xu * Cu - y * Cu^2 + x * Cuu - Ly * Cuu + yuu - y * Au^2) * sin(A) * cos(C) + (2 * x * Au * Cu - 2 * Ly * Au * Cu + 2 * yu * Au + y * Auu) * cos(A) * cos(C)...
				+ (zuu - (z - Lz) * Au^2) * cos(A) - (2 * zu * Au + (z - Lz) * Auu) * sin(A);
		
		
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
			
%             Cuuu = (((iuuu * j + iuu * ju - iu * juu - i * juuu) * (i ^ 2 + j ^ 2) + 2 * (iuu * j - i * juu) * (i * iu + j * ju) - 2 * (iuu * j - i * juu) * (i * iu + j * ju) - 2 * (iu * j - i * ju) * (iu ^ 2 + i * iuu + ju ^ 2 + j * juu)) * (i ^ 2 + j ^ 2) - 4 * ((iuu * j - i * juu) * (i ^ 2 + j ^ 2) - 2 * (iu * j - i * ju) * (i * iu + j * ju)) * (i * iu + j * ju)) / (i ^ 2 + j ^ 2) ^ 3;
            
			Cuuu = (((iuuu * j + iuu * ju - iu * juu - i * juuu) * (i ^ 2 + j ^ 2) + 2 * (iuu * j - i * juu) * (i * iu + j * ju) - 2 * (iuu * j - juu * i) * (i * iu + j * ju) - 2 * (iu * j - i * ju) * (iu ^ 2 + i * iuu + ju ^ 2 + j * juu)) * (i ^ 2 + j ^ 2) - 4 * ((iuu * j - i * juu) * (i ^ 2 + j ^ 2) - 2 * (j * iu - i * ju) * (i * iu + j * ju)) * (i * iu + j * ju)) / (i ^ 2 + j ^ 2) ^ 3;
			
			Xuuu = (xuuu - 2 * yuu * Cu - 2 * yu * Cuu - yu * Cuu - y * Cuuu - xu * Cu^2 - 2 * x * Cuu * Cu) * cos(C) - (xuu - 2 * yu * Cu - y * Cuu - x * Cu ^ 2) * Cu * sin(C) - (2 * xuu * Cu + 2 * xu * Cuu - yu * Cu^2 - 2 * y * Cu * Cuu + xu * Cuu + x * Cuuu + yuuu) * sin(C) + (2 * xu * Cu - y * Cu ^ 2 + x * Cuu + yuu) * Cu * cos(C);
			
			% Xuuu = (xuuu - 2 * yuu * Cu - 2 * yu * Cuu - yu * Cuu - y * Cuuu - xu * Cu^2 - 2 * x * Cuu * Cu) * cos(C) - (xuu - 2 * yu * Cu - y * Cuu - x * Cu ^ 2) * Cu * sin(C) - (2 * xuu * Cu + 2 * xu * Cuu - yu * Cu^2 - 2 * y * Cu * Cuu + xu * Cuu + x * Cuuu + yuuu) * sin(C) - (2 * xu * Cu - y * Cu ^ 2 + x * Cuu + yuu) * Cu * cos(C);
					
			Yuuu = (xuuu - 2* yuu * Cu - 2* yu * Cuu - yu * Cuu - y * Cuuu + Ly * Cuuu - xu * Au^2 - 2 * x * Auu * Au - xu * Cu^2 - 2 * x * Cuu * Cu) * cos(A) * sin(C) + (xuu - 2* yu * Cu - y * Cuu + Ly * Cuu - x * Au ^ 2 - x * Cu^2) * (-Au * sin(A) * sin(C) + Cu * cos(A) * cos(C))...
					- (2 * xuu * Au + 2 * xu * Auu - 2 * yu * Au * Cu - 2 * y * (Auu * Cu + Au * Cuu) + 2 * Ly * (Auu * Cu + Au * Cuu) + xu * Auu + x * Auuu) * sin(A) * sin(C) - (2 * xu * Au - 2 * y * Au * Cu + 2 * Ly * Au * Cu + x * Auu) * (Au * cos(A) * sin(C) + Cu * sin(A) * cos(C))...
					+ (2 * xuu * Cu + 2 * xu * Cuu - yu * Cu^2 - 2 * y * Cuu * Cu + 2 * Ly * Cu * Cuu - yu * Au^2 - 2 * y * Au * Auu + 2 * Ly * Au * Auu + yuuu + xu * Cuu + x * Cuuu) * cos(A) * cos(C) - (2* xu * Cu - y * Cu^2 + Ly * Cu^2 - y * Au^2 + Ly * Au^2 + yuu + x * Cuu) * (Au * sin(A) * cos(C) + Cu * cos(A) * sin(C)) ...
					- (2 * xu * Au * Cu + 2 * x * (Auu * Cu + Au * Cuu) + 2 * yuu * Au + 2 * yu * Auu + yu * Auu + (y - Ly) * Auuu) * sin(A) * cos(C) - (2* x * Au * Cu + 2* yu * Au + (y - Ly) * Auu) * (Au * cos(A) * cos(C) - Cu * sin(A) * sin(C))...
					- (zuuu - zu * Au^2 + 2 * Au * Auu * (Lz - z)) * sin(A) + (zuu + (Lz - z) * Au^2) * Au * cos(A)...
					+ ((Lz - z) * Auuu - zu * Auu - 2 * zuu * Au - 2 * zu * Auu) * cos(A) - ((Lz - z) * Auu - 2 * zu * Au) * Au * sin(A);
					
			Zuuu = (xuuu - 2 * yuu * Cu - 2 * yu * Cuu - yu * Cuu - y * Cuuu - xu * (Au^2 + Cu^2) - (x - Ly) * 2 * (Cuu * Cu + Auu * Au)) * sin(A) * sin(C) + (xuu - 2 * yu * Cu - y * Cuu - (x - Ly) * (Cu^2 + Au^2)) * (Au * cos(A) * sin(C) + Cu * sin(A) * cos(C))...
					+ (2 * xuu * Au + 2 * xu * Auu - 2 * yu * Au * Cu - 2 * y * (Auu * Cu + Au * Cuu) + xu * Auu + (x - Ly) * Auuu) * cos(A) * sin(C) + (2 * xu * Au - 2 * y * Au * Cu + (x - Ly) * Auu) * (- Au * sin(A) * sin(C) + Cu * cos(A) * cos(C))...
					+ (2 * xuu * Cu + 2 * xu * Cuu - yuu * Cu^2 - 2 * y * Cu * Cuu + xu * Cuu + x * Cuuu - Ly * Cuuu + yuuu - yu * Au^2 - y * 2 * Au * Auu) * sin(A) * cos(C) + (2 * xu * Cu - y * Cu^2 + x * Cuu - Ly * Cuu + yuu - y * Au^2) * (Au * cos(A) * cos(C) - Cu * sin(A) * sin(C))...
					+ (2 * xu * Au * Cu + 2 * x * (Auu * Cu + Au * Cuu) - 2 * Ly * (Auu * Cu + Au * Cuu) + 2 * (yuu * Au + yu * Auu) + yu * Auu + y * Auuu) * cos(A) * cos(C) - (2 * x * Au * Cu - 2 * Ly * Au * Cu + 2 * yu * Au + y * Auu) * (Au * sin(A) * cos(C) + Cu * cos(A) * sin(C))...
					+ (zuuu - zu * Au^2 - (z - Lz) * 2 * Au * Auu) * cos(A) - (zuu - (z - Lz) * Au^2) * Au * sin(A)...
					- (2 * zuu * Au + 2 * zu * Auu + zu * Auu + (z - Lz) * Auuu) * sin(A) - (2 * zu * Au + (z - Lz) * Auu) * Au * cos(A);
			
% 			Xuuu = xuuu + Ly * (Auuu * cos(A) * sin(C) + Auu * (-Au * sin(A) * sin(C) + Cu * cos(A) * cos(C)) + Cuuu * sin(A) * cos(C) + Cuu * (Au * cos(A) * cos(C) - Cu * sin(A) * sin(C)) - 2 * (Auu * Au + Cuu * Cu) * sin(A) * sin(C)...
% 					+ (Au ^ 2 + Cu ^ 2) * (Au * cos(A) * sin(C) + Cu * sin(A) * cos(C)) + 2 * (Auu * Cu + Au * Cuu) * cos(A) * cos(C) - 2 * Au * Cu * (Au * sin(A) * cos(C) + Cu * cos(A) * sin(C)));
%                 
% 			Yuuu = yuuu - Ly * (Auuu * cos(A) * cos(C) - Auu * (Au * sin(A) * cos(C) + Cu * cos(A) * sin(C)) - Cuuu * sin(A) * sin(C) - Cuu * (Au * cos(A) * sin(C) + Cu * sin(A) * cos(C)) - 2 * (Auu * Au + Cuu * Cu) * sin(A) * cos(C)...
% 					- (Au ^ 2 + Cu ^ 2) * (Au * cos(A) * cos(C) - Cu * sin(A) * sin(C))) - 2 * (Auu * Cu + Au * Cuu) * cos(A) * sin(C) - 2 * Au * Cu * (-Au * sin(A) * sin(C) + Cu * cos(A) * cos(C));
%                 
% 			Zuuu = zuuu - Ly * (Auuu * sin(A) + 3 * Auu * Au * cos(A) - Au ^ 3 * sin(A));
			
			mcr(4, :) = [Auuu, Cuuu, Xuuu, Yuuu, Zuuu];  % 保存结果
        end
	end
end
