clear all; close all;
load pvData;

numDays = 2;
FinalWeight = 0;

% Battery parameters
Vnominal = 25;  % Nominal terminal voltage [V]
Qnominal = 4;   % Nominal charge [A-h]
pvEff = 0.7;    % Irradiance to Power factor


loadFreq = 2*pi/time(end);
loadOffset = 3e4/loadFreq;
clearPpv = pvEff*repmat(clearIrrad(2:end),numDays,1);
cloudyPpv = pvEff*repmat(cloudyIrrad(2:end),numDays,1);
loadData = repmat(100*(sin(loadFreq*time(2:end) - 3e4)+1),numDays,1);

Ppv = clearPpv;
Pload = loadData;

N = numDays*(numel(time)-1);
dt = 300;
tvec = (1:N)'*dt;

% Energy constraints
battEnergy = Qnominal*Vnominal*3600;
Einit = 0.7*battEnergy;
batteryMinMax.Emax = 0.8*battEnergy;
batteryMinMax.Emin = 0.2*battEnergy;

% Power constraints
batteryMinMax.Pmin = -150;
batteryMinMax.Pmax = 150;

% Generate d = Ppv - Pload values
% Ppv = 300*(sin(1.7/N*tvec+5)+1);
% Ppv = 300*ones(N,1);
% Pload = 200*ones(N,1);
% Ppv = irradiance(2:end)*0.75;
% Pload = 200*(sin(1.7/N*tvec+3.5)+1);

% Generate cost values
C = loadData;
% C = 10*(sin(1.7/N*tvec+3.5)+5);
% C = ones(N,1);

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
