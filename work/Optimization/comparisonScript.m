clear all; close all;
load pvData;

numDays = 2;            % Number of consecutive days
FinalWeight = 50000;    % Final weight on energy storage
timeOptimize = 5;       % Time step for optimization [min]
timePred = 6;           % Predict ahead horizon [hours]

% Battery parameters
Vnominal = 25;  % Nominal terminal voltage [V]
Qnominal = 50;   % Nominal charge [A-h]
pvEff = 0.7;    % Irradiance to Power factor

stepAdjust = (timeOptimize*60)/(time(2)-time(1));

loadFreq = 2*pi/time(end);
loadOffset = 3.5e4/loadFreq;

clearPpv = pvEff*repmat(clearDay(2:stepAdjust:end),numDays,1);
cloudyPpv = pvEff*repmat(cloudyDay(2:stepAdjust:end),numDays,1);
loadData = repmat(100*(sin(loadFreq*time(2:stepAdjust:end) - loadOffset)+1)+50,numDays,1);

Ppv = clearPpv;
Pload = loadData;

dt = timeOptimize*60;
N = numDays*(numel(time(1:stepAdjust:end))-1);
tvec = (1:N)'*dt;

% Energy constraints
battEnergy = Qnominal*Vnominal*3600;
Einit = 0.7*battEnergy;
batteryMinMax.Emax = 0.8*battEnergy;
batteryMinMax.Emin = 0.2*battEnergy;

% Power constraints
batteryMinMax.Pmin = -150;
batteryMinMax.Pmax = 150;

% Generate cost values
C = loadData;

% Global optimial solution to cost optimization
[Pgrid,Pbatt,Ebatt] = battSolarOptimize(N,dt,Ppv,Pload,Einit,C,FinalWeight,batteryMinMax);

Ppv = cloudyPpv;

% No energy storage - Grid only cost
loadTot = Pload - Ppv;
costGrid = cumsum(C.*loadTot*dt);

% Horizon for "sliding" optimization
M = find(tvec > timePred*3600,1,'first');

% Energy Vector for simulation
Ebatt_sim = zeros(N,3);
Pbatt_sim = zeros(N,3);
Pgrid_sim = zeros(N,3);

Ebatt_sim(1,:) = Einit*ones(1,3);
Pbatt_sim(:,3) = Pbatt;


for i = 2:N,
    
    % --- Heuristic battery - compute battery power --------------------
    
    % Logic to determine battery charge/discharge/off state
    if loadTot(i) > 0 && Ebatt_sim(i-1) > batteryMinMax.Emin,
        P_heur = loadTot(i);
    elseif loadTot(i) <= 0 && Ebatt_sim(i-1) < batteryMinMax.Emax,
        P_heur = loadTot(i);
    else
        P_heur = 0;
    end
    
    % Saturate Power if beyond battery
    if P_heur > batteryMinMax.Pmax,
        P_heur = batteryMinMax.Pmax;
    elseif P_heur < batteryMinMax.Pmin,
        P_heur = batteryMinMax.Pmin;
    end
    
    Pbatt_sim(i,1) = P_heur;
    
    % --- Sliding optimization - compute battery power ----------------
    
    if i+M < numel(Pload),
        lenOpt = M;
        Ppv_opt = Ppv(i:i+M-1);
        Pload_opt = Pload(i:i+M-1);
        C_opt = C(i:i+M-1);
    else
        Ppv_opt = Ppv(i:end);
        Pload_opt = Pload(i:end);
        C_opt = C(i:end);
        lenOpt = numel(Ppv_opt);
    end
        
    [~,P_slide,~] = battSolarOptimize(lenOpt,dt,Ppv_opt,Pload_opt,...
        Ebatt_sim(i-1,2),C_opt,FinalWeight,batteryMinMax);
    
    Pbatt_sim(i,2) = P_slide(1); % Apply only the first step
        
  
    % --- Compute grid requirements and battery energy for all cases --   
    Pgrid_sim(i,:) = loadTot(i) - Pbatt_sim(i,:);
    Ebatt_sim(i,:) = Ebatt_sim(i-1,:) - Pbatt_sim(i,:)*dt;
    
end

figure;
subplot(3,1,1);
plot(tvec,Ebatt); grid on;

subplot(3,1,2);
plot(tvec,C); grid on;

subplot(3,1,3);
plot(tvec,Ppv,tvec,Pbatt,tvec,Pgrid,tvec,Pload);
grid on;
legend('PV','Battery','Grid','Load')
