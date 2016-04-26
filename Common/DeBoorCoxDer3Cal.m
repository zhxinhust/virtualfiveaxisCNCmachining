function der3 = DeBoorCoxDer3Cal(CtrlP,uIndex)
% 计算三阶导失

global curveDegree;         % 阶数
global KnotVector;

m = size(CtrlP, 2);

iterativeMat = zeros(curveDegree + 1, m, curveDegree + 1);

for temp4 = 3:curveDegree
    T(temp4 + 1, :) = (curveDegree - 1) * (TempIterative(CtrlP, uIndex - curveDegree + temp4) - TempIterative(CtrlP, uIndex - curveDegree + temp4 - 1))...
                / (KnotVector(uIndex - curveDegree + temp4 + curveDegree) - KnotVector(uIndex - curveDegree + temp4 + 1));
    T(temp4 , :) = (curveDegree - 1) * (TempIterative(CtrlP, uIndex - curveDegree + temp4-1) - TempIterative(CtrlP, uIndex - curveDegree + temp4 - 2))...
                / (KnotVector(uIndex - curveDegree + temp4 + curveDegree-1) - KnotVector(uIndex - curveDegree + temp4 ));      
end

for temp3 = curveDegree: -1 : 3
    for temp4 = 3 : temp3
        if temp3 == curveDegree
            utemp = (KnotVector(uIndex - temp3 + temp4 + curveDegree-1) - KnotVector(uIndex - temp3 + temp4 +1));
            if utemp == 0
                iterativeMat(temp4 + 1, :, temp3 + 1) = zeros(1, m);
            else
                iterativeMat(temp4 + 1, :, temp3 + 1) = (curveDegree - 2) * (T(temp4 + 1, :) - T(temp4, :)) / utemp;
            end
%         else
%             iterativeMat(temp4 + 1, :, temp3 + 1) = (1 - alfaMatrixDer3(temp4 + 1, temp3 + 1)) * iterativeMat(temp4 + 1, :, temp3 + 2) + alfaMatrixDer3(temp4 + 1, temp3 + 1) * iterativeMat(temp4 + 2, :, temp3 + 2);
        end
    end
end

der3 = iterativeMat(4, :, 4);