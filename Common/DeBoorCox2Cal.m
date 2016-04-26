function der2 = DeBoorCox2Cal(alfaMatrix, CtrlP,uIndex)
% Çó¶þ½×ÇÐÊ¸

global curveDegree;         % ½×Êý
global KnotVector;

m = size(CtrlP, 2);

iterativeMat = zeros(curveDegree + 1, m, curveDegree + 1);

for temp3 = curveDegree: -1 : 2
    for temp4 = 2 : temp3
        if temp3 == curveDegree
            utemp = (KnotVector(uIndex - temp3 + temp4 + curveDegree) - KnotVector(uIndex - temp3 + temp4 + 1));
            if utemp == 0
                iterativeMat(temp4 + 1, :, temp3 + 1) = zeros(1, m);
            else
                iterativeMat(temp4 + 1, :, temp3 + 1) = (curveDegree - 1) * (TempIterative(CtrlP, uIndex - temp3 + temp4) - TempIterative(CtrlP, uIndex - temp3 + temp4 - 1))...
                    / utemp;
            end
        else
            iterativeMat(temp4 + 1, :, temp3 + 1) = (1 - alfaMatrix(temp4 + 1, temp3 + 1)) * iterativeMat(temp4 + 1, :, temp3 + 2) + alfaMatrix(temp4 + 1, temp3 + 1) * iterativeMat(temp4 + 2, :, temp3 + 2);
        end
    end
end

der2 = iterativeMat(3,:, 3);