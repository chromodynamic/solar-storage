%% Load example irradiance data
% Irradiance for Photovoltaic simulation over a 12 hour period
load pvData.mat;

loadFreq = 2*pi/time(end);
loadOffset = 3.5e4/loadFreq;
% clearIrrad = [time(1:end-24) clearIrrad(25:end)];
% cloudyIrrad = [time(1:end-24) cloudyIrrad(25:end)];

clearIrrad = [time clearDay];
cloudyIrrad = [time cloudyDay];
% loadData = [time(1:end-24) 115*sin(3.5/time(end-24)*time(1:end-24)-0.5)+150];
loadData = [time 100*(sin(loadFreq*time - loadOffset)+1)+50];
%% Initial conditions for battery

% Charge deficit
cellsInParallel = 4;
Qe_init = 1*cellsInParallel; %Ampere*hours

% Ambient Temperature
ambientTemp = 20;               % Ambient Temperature [C]
T_init = ambientTemp + 273.15;  % Convert to Kelvin [K]