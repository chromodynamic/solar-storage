clear all; close all;
load pvData;


N = 200;
dt = 5;
tvec = 2*(1:N)'*dt;

% Energy constraints
batteryMinMax.Emax = 40000;
batteryMinMax.Emin = 2000;
Einit = 5000;

% Power constraints
batteryMinMax.Pmin = -150;
batteryMinMax.Pmax = 150;

% Generate d = Ppv - Pload values
Ppv = 300*(sin(1.7/N*tvec+5)+1);
% Ppv = 300*ones(N,1);
% Pload = 200*ones(N,1);
% Ppv = irradiance(2:end)*0.75;
Pload = 200*(sin(1.7/N*tvec+3.5)+1);

% Generate cost values
C = 10*(sin(1.7/N*tvec+3.5)+5);
% C = ones(N,1);

[Pgrid,Pbatt,Ebatt] = battSolarOptimize(N,dt,Ppv,Pload,Einit,C,batteryMinMax);

figure;
subplot(3,1,1);
plot(tvec,Ebatt); grid on;

subplot(3,1,2);
plot(tvec,C); grid on;

subplot(3,1,3);
plot(tvec,Ppv,tvec,Pbatt,tvec,Pgrid,tvec,Pload);
grid on;
legend('PV','Battery','Grid','Load')
