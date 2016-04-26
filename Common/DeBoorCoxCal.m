function P = DeBoorCoxCal( alfaMatrix, ctrl, uIndex)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明

global curveDegree; % 阶数
n = size(ctrl, 1);

m = size(ctrl, 2);
iterativeMatrix = zeros(curveDegree + 1, m,curveDegree + 1);

for temp3 = curveDegree : -1 : 0
    for temp4 = 0 : temp3
        if temp3 == curveDegree
            if uIndex ~= n
                iterativeMatrix(temp4 + 1, :,temp3 + 1) = ctrl(uIndex - temp3 + temp4 + 1, :);
            else
                if temp4 ~= temp3
                    iterativeMatrix(temp4 + 1, :,temp3 + 1) = ctrl(uIndex - temp3 + temp4 + 1, :);
                else
                    iterativeMatrix(temp4 + 1, :,temp3 + 1) = zeros(1, m);
                end
            end
        else
            iterativeMatrix(temp4 + 1, :,temp3 + 1) = (1 - alfaMatrix(temp4 + 1, temp3 + 1)) * iterativeMatrix(temp4 + 1, :,temp3 + 2) +...
                alfaMatrix(temp4 + 1, temp3 + 1) * iterativeMatrix(temp4 + 2, :,temp3 + 2);
        end
    end
end

P = iterativeMatrix(1, :, 1);
end

