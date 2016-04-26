function interpresult = dualquaternionspathsecondTaylorinterp(dualpathtimeoptimalfeedrate, dualquatpaht, interpolationperiod, machinetype)
% 对拟合得到的对偶四元数格式的刀具路径进行泰勒二阶近似插补计算
% 输入：
%   dualpathtimeoptimalfeedrate：采用时间最优速度规划方法得到的速度规划曲线，B样条形式
%   dualquatpaht：拟合得到的对偶四元数格式刀路
%   interpolationperiod：插补周期
%   machinetype：机床类型
%
% 输出：interpresult插补结果

global interpolationPeriod;
interpolationPeriod = interpolationperiod;
Ts = interpolationperiod;
u = 0.0001;	% 上一参数u

lastf = 0;	% 上一速度炿
lastf2 = 0;
lastA = 0;

% 将对偶四元数刀路中的数据读取出去，方便使用
tip0 = dualquatpaht.tip0;
vector0 = dualquatpaht.vector0;
controlp = dualquatpaht.dualquatspline.controlp;
knotvector = dualquatpaht.dualquatspline.knotvector;
splineorder = dualquatpaht.dualquatspline.splineorder;

% 先读取第一个控制点
deboordualq = dualquatpaht.dualquatspline.controlp(1, :);


lastp = DerCalFromQ(tip0, vector0, deboordualq, 0);

lastmcr2 = machinecoordinatecaltabletilting(lastp, 0, 1);
lastmcr = lastmcr2;

interpcor(1, :) = lastp;

stepnum = 1;


while u < 1
	f = DeBoorCoxNurbsCal(u, dualpathtimeoptimalfeedrate, 0);	% 计算当前点规划??f
	interpresult.schedulf(stepnum) = f;    % 保存规划的f值
    
	deboordualq = DeBoorCoxNurbsCal(u, dualquatpaht.dualquatspline, 2);	% 计算到二阶
	pathdeboor = DerCalFromQ(tip0, vector0, deboordualq, 2);
	
	if machinetype == 1
		mcr = machinecoordinatecaltabletilting(pathdeboor, 2, stepnum); % 计算机床坐标
	elseif machinetype == 2
		mcr = machinecoordinatecal(pathdeboor, 2, stepnum); % 计算机床坐标
    end
    % 保存曲率信息
	curvature(stepnum) = (norm(pathdeboor(2, 1:3))) ^ 3 / norm(cross(pathdeboor(2, 1:3), pathdeboor(3, 1:3)));
    
    mcrarr(stepnum, :) = mcr(1, :);             % 各轴位置
    
    punorm = norm(pathdeboor(2, 1:3));
    pudotpuu = dot(pathdeboor(2, 1:3), pathdeboor(3, 1:3));
    pu2 = (norm(pathdeboor(2, 1:3)))^2;
    
    if stepnum > 1
        % 差分计算规划加速度
        lastA = (f - lastf) / Ts ;	
        schedulMA(stepnum, :) = (lastmcr(3, :) / pu2 - lastmcr(2, :)* dot(pathdeboor(2, 1:3), pathdeboor(3, 1:3)) / pu2^2) * f^2  + lastmcr(2, :) / punorm * lastA;
        
		% 各轴规划速度
        schedulMV(stepnum, :) = mcr(2, :) * f / norm(pathdeboor(2, 1:3));

        actualf(stepnum) = norm(pathdeboor(1, 1:3) - lastp) / Ts;	% 差分计算实际速度
        actualMV(stepnum, :) = (mcr(1, :) - lastmcr(1, :)) / Ts;	% 差分计算各轴实际速度

        % 计算实际加速度
		actualMA(stepnum - 1, :) = (actualMV(stepnum, :) - actualMV(stepnum - 1, :)) / Ts;
		actualA(stepnum - 1) = (actualf(stepnum) - actualf(stepnum - 1)) / Ts;
	
        % 计算实际跃度
        if stepnum > 2
            actualMJ(stepnum - 2, :) = (actualMA(stepnum - 1, :) - actualMA(stepnum - 2, :)) / Ts;
            actualJ(stepnum - 2) = (actualA(stepnum - 1) - actualA(stepnum - 2)) / Ts;
        end

		% 保存插补点信息
        interpcor(stepnum, 1:6) = pathdeboor(1, :);

        interpV(stepnum) = f;
        interpA(stepnum) = lastA;
    end
    
	lastf2 = lastf;
	lastf = f;	
	lastp = pathdeboor(1, 1:3);
    lastmcr2 = lastmcr;
    lastmcr = mcr;
    
	interpcor(stepnum, 9) = u;
    
    if u >=0.99965 
		break;
    end
	
	u = SecondTalorForInterp(u, f, lastA, pathdeboor, stepnum);	% 利用泰勒二阶展开计算下一参数炿
	
	stepnum = stepnum + 1;	
end

interpresult.interpcor = interpcor;
interpresult.curvature = curvature;
interpresult.actualf = actualf;
interpresult.actualMV = actualMV;
interpresult.schedulMV = schedulMV;
interpresult.mcrarr = mcrarr;


% interpresult = 0;

clear interpolationPeriod