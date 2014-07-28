clear all; close all;
load pvData;

numDays = 1;            % Number of consecutive days
FinalWeight = 500;    % Final weight on energy storage
timeOptimize = 5;       % Time step for optimization [min]

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

[Pgrid,Pbatt,Ebatt] = battSolarOptimize(N,dt,Ppv,Pload,Einit,C,FinalWeight,batteryMinMax);

figure;
subplot(3,1,1);
plot(tvec,Ebatt); grid on;

subplot(3,1,2);
plot(tvec,C); grid on;

subplot(3,1,3);
plot(tvec,Ppv,tvec,Pbatt,tvec,Pgrid,tvec,Pload);
grid on;
legend('PV','Battery','Grid','Load')


optVec = zeros(N,1);
optVec(Pbatt > 50) = -1; % Discharge values
optVec(Pbatt < -50) = 1; % Charge values
optVec(abs(Pbatt) < 50) = 0; % Disable values
optVec = [tvec optVec];
