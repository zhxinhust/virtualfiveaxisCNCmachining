function Niku = GetBaseFunVal(u, i, k, knotVector)

Val = 0;
val1 = 0;
val2 = 0;

if k == 0
    if u < knotVector(i + 1) || u >= knotVector(i + 2)
        Niku = Val;
        return;
    else
        Niku = 1;
        return;
    end
end

if u < knotVector(i + 1) || u >= knotVector(i + k + 2)
    Niku = Val;
    return
else
    alpha = 0;
    beta = 0;
    dTemp = 0;
    dTemp = knotVector(i + k + 1) - knotVector(i + 1);

    if dTemp == 0
        alpha = 0;
    else
        alpha = (u - knotVector(i + 1)) / dTemp;
    end

    dTemp = knotVector(i + k + 2) - knotVector(i + 2);

    if dTemp == 0
        beta = 0;
    else
        beta = (knotVector(i + k + 2) - u) / dTemp;
    end

    val1 = alpha * GetBaseFunVal(u, i, k - 1, knotVector);
    val2 = beta * GetBaseFunVal(u, i + 1, k - 1, knotVector);
    Val = val1 + val2;
end


Niku = Val;
