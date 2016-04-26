function derVector = DeBoorCoxDer1Cal(alfaMatrix, CtrlP,uIndex)
% 计算型值点的一阶导矢

global curveDegree; % 阶数

m = size(CtrlP, 2);
iteratMatrix = zeros(curveDegree + 1, m,curveDegree + 1);

for temp3 = curveDegree:-1:1
    for temp4 = 1:temp3
        if temp3 == curveDegree
            iteratMatrix(temp4 + 1, :, temp3 + 1) = TempIterative(CtrlP, uIndex - temp3 + temp4);
        else
            iteratMatrix(temp4 + 1, :, temp3 + 1) = (1 - alfaMatrix(temp4 + 1, temp3 + 1)) * iteratMatrix(temp4 + 1, :, temp3 + 2) + ...
                alfaMatrix(temp4 + 1, temp3 + 1) * iteratMatrix(temp4 + 2, :, temp3 + 2);
        end
    end
end

derVector = iteratMatrix(2, :, 2);