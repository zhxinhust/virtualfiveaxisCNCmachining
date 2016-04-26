function searchPRChord(startIndex, endIndex, PR, errLim)
% searchChord(lowIndex, hightIndex, segmentLines)
% 搜索弓高点超过误差的点作为特征点。
% 输入：lowIndex, hightIndex分别表示搜索的区间,SegmentLines为小线段, errLim为误差限
% 输出：最终搜索到的点放在全局变量

global featurePointsIndex;
global featurePointNum;

maxDis = 0;
maxDisIndex = startIndex;

for i = startIndex + 1 : endIndex - 1
    
    x1 = PR(startIndex, 1);
    y1 = PR(startIndex, 2);
    z1 = PR(startIndex, 3);

    dx = PR(endIndex, 1) - PR(startIndex, 1);
    dy = PR(endIndex, 2) - PR(startIndex, 2);
    dz = PR(endIndex, 3) - PR(startIndex, 3);

    xi = PR(i, 1);
    yi = PR(i, 2);
    zi = PR(i, 3);
    
  %  dis(i - startIndex) = abs(dy * xi + (y1 * dx - x1 * dy) - yi * dx) / sqrt(dy^2 + dx^2);
    dis(i - startIndex) = norm(cross([dx, dy, dz], [xi, yi, zi] - [x1, y1, z1])) / norm([dx, dy, dz]);
    
    if dis(i - startIndex) > errLim
        if dis(i - startIndex) > maxDis
            maxDis = dis(i - startIndex);       % 记录最大弓高误差
            maxDisIndex = i;    % 保存最大弓高点的下标值
        end
    end
end

% 最大距离不等于0，说明存在一些点的弓高误差超过允许误差
if maxDis ~= 0
    searchPRChord(startIndex, maxDisIndex, PR, errLim); 
    featurePointsIndex(featurePointNum) = maxDisIndex;
    featurePointNum = featurePointNum + 1;  
    searchPRChord(maxDisIndex, endIndex, PR, errLim);
end



