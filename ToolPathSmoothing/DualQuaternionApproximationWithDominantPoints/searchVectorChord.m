function searchVectorChord(startIndex, endIndex, Q, errLimA)
% 对按照刀尖点轨迹搜索到的特征点进行验算刀轴矢量弓高误差
% Q 为刀轴矢量对应的四元数，errLimA 为角度距离偏差的阈值，超过此阈值则添加特征点
% 搜索完毕后，添加的特征点存放在featurePointsIndex 中

global featurePointsIndex;
global featurePointNum;

maxDis = 0;
maxDisIndex = startIndex;

for i = startIndex + 1 : endIndex - 1
    % 保存起点和终点的四元数
    ts = Q(startIndex, 1:4);
	te = Q(endIndex, 1:4);
	
	sita = acos(dot(ts, te));		% 求起点和终点的角度距离
    
	ti = Q(i, 1:4);
	
	% 求垂足处对应的u的值。具体推导方法见《五轴刀路特征点选择 四元数表示刀轴矢量》
	u = 1 / sita * atan((dot(ti, te) - dot(ti, ts) * cos(sita)) / (dot(ti, ts) * sin(sita)));
	
	% 求垂足
	tit = sin(sita - u * sita) / sin(sita) * ts + sin(u * sita) / sin(sita) * te;
	
	% 求角度距离
    dis(i - startIndex) = acos(dot(ti, tit)) * 180 / pi;
    
    if dis(i - startIndex) > errLimA
        if dis(i - startIndex) > maxDis
            maxDis = dis(i - startIndex);       % 记录最大弓高误差
            maxDisIndex = i;    % 保存最大弓高点的下标值
        end
    end
end

% 最大距离不等于0，说明存在一些点的弓高误差超过允许误差
if maxDis ~= 0
    searchPRChord(startIndex, maxDisIndex, Q, errLimA); 
    featurePointsIndex(featurePointNum) = maxDisIndex;
    featurePointNum = featurePointNum + 1;  
    searchPRChord(maxDisIndex, endIndex, Q, errLimA);
end
