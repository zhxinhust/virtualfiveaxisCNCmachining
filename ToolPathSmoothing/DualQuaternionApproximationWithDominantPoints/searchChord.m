function searchChord(startIndex, endIndex, segmentLines, Q, TLErrLimit, vectLimit)
% searchChord(lowIndex, hightIndex, segmentLines)
% 搜索弓高点超过误差的点作为特征点。
% 输入：lowIndex, hightIndex分别表示搜索的区间,SegmentLines为小线段, errLim为误差限
% 输出：最终搜索到的点放在全局变量

global featurePointsIndex;
global featurePointNum;

maxDis = 0;
maxDisIndex = startIndex;

PL = segmentLines(:, 1:3);
% PR = segmentLines(:, 1:3) + toolLen * segmentLines(:, 4:6);

QR = Q(:, 1:4); % 取对偶四元数实部，用来选择刀轴矢量的弓高点用

for i = startIndex + 1 : endIndex - 1
    
    x1 = PL(startIndex, 1);
    y1 = PL(startIndex, 2);
    z1 = PL(startIndex, 3);

    dx = PL(endIndex, 1) - PL(startIndex, 1);
    dy = PL(endIndex, 2) - PL(startIndex, 2);
    dz = PL(endIndex, 3) - PL(startIndex, 3);

    xi = PL(i, 1);
    yi = PL(i, 2);
    zi = PL(i, 3);
    
  %  dis(i - startIndex) = abs(dy * xi + (y1 * dx - x1 * dy) - yi * dx) / sqrt(dy^2 + dx^2);
    dis(i - startIndex) = norm(cross([dx, dy, dz], [xi, yi, zi] - [x1, y1, z1])) / norm([dx, dy, dz]);
    
    if dis(i - startIndex) > TLErrLimit
        if dis(i - startIndex) > maxDis
            maxDis = dis(i - startIndex);       % 记录最大弓高误差
            maxDisIndex = i;    % 保存最大弓高点的下标值
        end
    end
end

% 最大距离不等于0，说明存在一些点的弓高误差超过允许误差
if maxDis ~= 0
    searchChord(startIndex, maxDisIndex, segmentLines, Q, TLErrLimit, vectLimit); 
    featurePointsIndex(featurePointNum) = maxDisIndex;
    featurePointNum = featurePointNum + 1;  
    searchChord(maxDisIndex, endIndex, segmentLines, Q, TLErrLimit, vectLimit);
% 如果刀尖点曲线满足弓高误差要求，则进行刀轴上参考点曲线弓高验算
elseif maxDis == 0
    searchVectorChord(startIndex, maxDisIndex, QR, vectLimit)
    searchVectorChord(maxDisIndex, endIndex, QR, vectLimit);
end



