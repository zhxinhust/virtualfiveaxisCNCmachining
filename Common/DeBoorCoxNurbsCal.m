function [ DeBoorP ] = DeBoorCoxNurbsCal(u, bslpine, derorder)
%计算德布尔点
%   derorder = 0，则不计算导矢，derorder = 1，则会计算点和一阶导矢, derorder = 2，则会计算点和二阶导矢， derorder = 3，则会计算点和三阶导矢

% 几个要用到的全局变量，使用全局变量减少数据传递次数
global KnotVector;  % 节点向量
global CP;          % 控制点
global curveDegree; % 阶数
KnotVector = bslpine.knotvector;
CP = bslpine.controlp;
curveDegree = bslpine.splineorder;


n = size(CP, 1);
weightVector = ones(n, 1);  % 由于本实验使用的是B样条，权重都为1，前期参考赵师兄NURBS代码写的，这里为了统一，并为以后留扩展，此部分保留

uIndex = findSpan(n, curveDegree, u, KnotVector);

% 系数矩阵
alfaMatrix = zeros(curveDegree, curveDegree);
alfaMatrixDer1 = zeros(curveDegree, curveDegree);
alfaMatrixDer2 = zeros(curveDegree, curveDegree);
alfaMatrixDer3 = zeros(curveDegree, curveDegree);

%% 计算型值点的系数矩阵
for tempData = 0 : curveDegree - 1
    for tempData2 = 0 : tempData
        utemp =  (KnotVector(uIndex + tempData2 + 2) - KnotVector(uIndex - tempData + tempData2 + 1));
        
        if utemp == 0
            alfaMatrix(tempData2 + 1, tempData + 1) = 0;
        else
            alfaMatrix(tempData2 + 1, tempData + 1) = (u - KnotVector(uIndex - tempData + tempData2 + 1)) / utemp;
        end
    end
end

deBoorAu = DeBoorCoxCal(alfaMatrix, CP, uIndex);            % 计算型值点
deBoorBu = DeBoorCoxCal(alfaMatrix, weightVector, uIndex);

if deBoorBu == 0
    KnotBoor = [0 0 0];
else
    KnotBoor = deBoorAu / deBoorBu;
end
DeBoorP(1, :) = KnotBoor;


if derorder >= 1
   % 计算一阶导矢需要用到的系数矩阵
    for tempData = curveDegree - 1 : -1 : 1
        for tempData2 = tempData: - 1 : 1
            utemp = (KnotVector(uIndex + tempData2 + 1) - KnotVector(uIndex - tempData + tempData2 + 1));
            if utemp == 0
                alfaMatrixDer1(tempData2 + 1, tempData + 1) = 0;
            else
                alfaMatrixDer1(tempData2 + 1, tempData + 1) = (u - KnotVector(uIndex - tempData + tempData2 + 1)) / utemp;
            end
        end
    end
    deBoorDer1 = DeBoorCoxDer1Cal(alfaMatrixDer1, CP, uIndex);
    deBoorDer1Bu = DeBoorCoxDer1Cal(alfaMatrixDer1, weightVector, uIndex);
    
    if deBoorBu == 0
        KnotCoorDer1 = [0 0 0];
    else
        KnotCoorDer1 = (deBoorDer1 - deBoorDer1Bu * KnotBoor) / deBoorBu;
    end
    DeBoorP(2, :) = KnotCoorDer1;
  
    if derorder >= 2
        % 计算二阶导矢需要用到的系数矩阵
        for tempData = curveDegree - 1: -1 : 2
            for tempData2 = tempData : -1 : 2
                utemp = (KnotVector(uIndex + tempData2) - KnotVector(uIndex - tempData + tempData2 + 1));
                if utemp == 0
                    alfaMatrixDer2(tempData + 1, tempData + 1) = 0;
                else
                    alfaMatrixDer2(tempData + 1, tempData + 1) = (u - KnotVector(uIndex - tempData + tempData2 + 1)) / utemp;
                end
            end
        end

        deBoorDer2 = DeBoorCox2Cal(alfaMatrixDer2, CP, uIndex);
        deBoorDer2Bu = DeBoorCox2Cal(alfaMatrixDer2, weightVector, uIndex);

        if deBoorBu == 0
            KnotCoorDer2 = [0 0 0];
        else
            KnotCoorDer2 = (deBoorDer2 - 2 *deBoorDer1Bu * KnotCoorDer1 - deBoorDer2Bu * KnotBoor) / deBoorBu;
        end
        DeBoorP(3, :) = KnotCoorDer2;
        
        if derorder >= 3
            % 计算求三阶导矢需要用到的系数矩阵
            for tempData = curveDegree - 1: -1 : 3
                for tempData2 = tempData: -1 : 3
                    utemp = (KnotVector(uIndex + tempData2 - 1) - KnotVector(uIndex - tempData + tempData2 + 1));
                    if utemp == 0
                        alfaMatrixDer3(tempData + 1, tempData2 + 1) = 0;
                    else
                        alfaMatrixDer3(tempData + 1, tempData2 + 1) = (u - KnotVector(uIndex - tempData + tempData2 + 1)) / utemp;            
                    end
                end
            end
            
            deBoorDer3 = DeBoorCox3Cal(alfaMatrixDer3, CP, uIndex);
            deBoorDer3Bu = DeBoorCox3Cal(alfaMatrixDer3, weightVector, uIndex);

            DeBoorP(4, :) = deBoorDer3;
        end
    end
end

clear KnotVector  % 节点向量
clear CP          % 控制点
clear curveDegree % 阶数

