function [Pgrid,Pbatt,Ebatt] = battSolarOptimize(N,dt,Ppv,Pload,Einit,Cost,batteryMinMax)

% Power offset - battery/grid make up the difference
d = Pload - Ppv;

% Sub-matrices for optimization constraints
eyeMat = eye(N);
zeroMat = zeros(N);

battPower = diag(ones(N-1,1),-1);
battEnergy = diag(-ones(N-1,1),-1) + eye(N);

% Generate the equivalent constraint matrices
Aeq = [eyeMat   eyeMat     zeroMat; 
       zeroMat  battPower   battEnergy];  
beq = [d; Einit; zeros(N-1,1)];

% Generate the objective function
f = [(Cost*dt)' zeros(1,N) zeros(1,N)];

% Constraint equations
A = [zeroMat    eyeMat      zeroMat; 
     zeroMat    -eyeMat     zeroMat;
     zeroMat    zeroMat     eyeMat;
     zeroMat    zeroMat     -eyeMat];
b = [batteryMinMax.Pmax*ones(N,1);
    -batteryMinMax.Pmin*ones(N,1);
    batteryMinMax.Emax*ones(N,1);
    -batteryMinMax.Emin*ones(N,1)];

% Perform Linear programming optimization
xopt = linprog(f,A,b,Aeq,beq);

% Parse optmization results
Pgrid = xopt(1:N);
Pbatt = xopt(N+1:2*N);
Ebatt = xopt(2*N+1:end);