function pathders = DerCalFromQ(p0, vector0, deboordualquat, derorder)
% 求二阶导矢

dualQ = deboordualquat(1, :);



Q = dualQ(1:4);
R = dualQ(5:8);
Qs = Q;
Qs(2:4) = -Q(2:4);
Rs = R;
Rs(2:4) = -R(2:4);

% 将初始点表示为四元数格式
p = [0, p0];
v = [0, vector0];

f = quatmultiply(quatmultiply(Q, p), Qs) - quatmultiply(R, Qs) + quatmultiply(Q, Rs);
fv = quatmultiply(quatmultiply(Q, v), Qs);

g = quatmultiply(Q, Qs);
normQ = dot(Q, Q);

pathders(1, 1:3) = TransformViaQ(p0, dualQ);  % 求0阶导
vectortemp = quatmultiply3(Q, v, quatconj(Q));
pathders(1, 4:6) = vectortemp(2:4);  % 求0阶导

if derorder > 0
    % 求一阶导
    dualQder1 = deboordualquat(2, :);
    Qder1 = dualQder1(1:4);
    Rder1 = dualQder1(5:8);
    Qder1s = Qder1;
    Qder1s(2:4) = -Qder1(2:4);
    Rder1s = Rder1;
    Rder1s(2:4) = -Rder1(2:4);
    
    fd = quatmultiply(quatmultiply(Qder1, p), Qs) + quatmultiply(quatmultiply(Q, p), Qder1s) - quatmultiply(Rder1, Qs) - quatmultiply(R, Qder1s) + quatmultiply(Qder1, Rs) + quatmultiply(Q, Rder1s);
    
    fvd = quatmultiply(quatmultiply(Qder1, v), Qs) + quatmultiply(quatmultiply(Q, v), Qder1s);
    
    gd = quatmultiply(Qder1, Qs) + quatmultiply(Q, Qder1s);
    
    der1Temptip = (quatmultiply(fd, g) - quatmultiply(f, gd)) / normQ^2;
    
    der1Tempvector = (quatmultiply(fvd, g) - quatmultiply(fv, gd)) / normQ^2;
    
    pathders(2, 1:3) = der1Temptip(2:4);
    pathders(2, 4:6) = der1Tempvector(2:4);    

    if derorder > 1
        % 求二阶导
        dualQder2 = deboordualquat(3, :);
        Qder2 = dualQder2(1:4);
        Rder2 = dualQder2(5:8);
        Qder2s = Qder2;
        Qder2s(2:4) = -Qder2(2:4);
        Rder2s = Rder2;
        Rder2s(2:4) = -Rder2(2:4);
        
        fdd = quatmultiply(quatmultiply(Qder2, p), Qs) + 2 * quatmultiply(quatmultiply(Qder1, p), Qder1s) + quatmultiply(quatmultiply(Q, p), Qder2s)...
            - quatmultiply(Rder2, Qs) - 2 * quatmultiply(Rder1, Qder1s) - quatmultiply(R, Qder2s) + quatmultiply(Qder2, Rs) + 2 * quatmultiply(Qder1, Rder1s) + quatmultiply(Q, Rder2s);
        
        fvdd = quatmultiply(quatmultiply(Qder2, v), Qs) + 2 * quatmultiply(quatmultiply(Qder1, v), Qder1s) + quatmultiply(quatmultiply(Q, v), Qder2s);
        
        gdd = quatmultiply(Qder2, Qs) + 2 * quatmultiply(Qder1, Qder1s) + quatmultiply(Q, Qder2s);
        
        der2Tmeptip = (quatmultiply(quatmultiply(fdd, g) - quatmultiply(f, gdd), g) - 2 * quatmultiply(quatmultiply(fd, g) - quatmultiply(f, gd), gd)) / normQ^3;
        
        der2Tmepvector = (quatmultiply(quatmultiply(fvdd, g) - quatmultiply(fv, gdd), g) - 2 * quatmultiply(quatmultiply(fvd, g) - quatmultiply(fv, gd), gd)) / normQ^3;
        
        pathders(3, 1:3) = der2Tmeptip(2:4);
        pathders(3, 4:6) = der2Tmepvector(2:4);
        
        if derorder > 2
            % 求三阶导
            dualQder3 = deboordualquat(4, :);
            Qder3 = dualQder3(1:4);
            Rder3 = dualQder3(5:8);
            Qder3s = Qder3;
            Qder3s(2:4) = -Qder3(2:4);
            Rder3s = Rder3;
            Rder3s(2:4) = -Rder3(2:4);
            
            fddd = quatmultiply3(Qder3, p, Qs) + 3 * quatmultiply3(Qder2, p, Qder1s) + 3 * quatmultiply3(Qder1, p, Qder2s) + quatmultiply3(Q, p, Qder3s)...
					- quatmultiply(Rder3, Qs) - 3 * quatmultiply(Rder2, Qder1s) - 3 * quatmultiply(Rder1, Qder2s) - quatmultiply(R, Qder3s)...
					+ quatmultiply(Qder3, Rs) + 3 * quatmultiply(Qder2, Rder1s) + 3 * quatmultiply(Qder1, Rder2s) + quatmultiply(Q, Rder3s);
                
            fvddd = quatmultiply3(Qder3, v, Qs) + 3 * quatmultiply3(Qder2, v, Qder1s) + 3 * quatmultiply3(Qder1, v, Qder2s) + quatmultiply3(Q, v, Qder3s);
			
			gddd = quatmultiply(Qder3, Qs) + 3 * quatmultiply(Qder2, Qder1s) + 3 * quatmultiply(Qder1, Qder2s) + quatmultiply(Q, Qder3s);
			
			der3Temptip = (quatmultiply(quatmultiply(quatmultiply(fddd, g) + quatmultiply(fdd, gd) - quatmultiply(fd, gdd) - quatmultiply(f, gddd), gd)...
						- 2 * quatmultiply(quatmultiply(fdd, g) - quatmultiply(f, gdd), gd) - 2 * quatmultiply(quatmultiply(fd, g) - quatmultiply(f, gd), gdd), g)...
						- 3 * quatmultiply(quatmultiply(quatmultiply(f, gdd) - quatmultiply(f, gdd), g) - 2 * quatmultiply(quatmultiply(fd, g) - quatmultiply(f, gd), gd), gd)) / normQ^4;
                    
            der3Tempvector = (quatmultiply(quatmultiply(quatmultiply(fvddd, g) + quatmultiply(fvdd, gd) - quatmultiply(fvd, gdd) - quatmultiply(fv, gddd), gd)...
						- 2 * quatmultiply(quatmultiply(fvdd, g) - quatmultiply(fv, gdd), gd) - 2 * quatmultiply(quatmultiply(fvd, g) - quatmultiply(fv, gd), gdd), g)...
						- 3 * quatmultiply(quatmultiply(quatmultiply(fv, gdd) - quatmultiply(fv, gdd), g) - 2 * quatmultiply(quatmultiply(fvd, g) - quatmultiply(fv, gd), gd), gd)) / normQ^4;
						
			pathders(4, 1:3) = der3Temptip(2:4);	
            pathders(4, 1:3) = der3Tempvector(2:4);
        end
    end
end
























