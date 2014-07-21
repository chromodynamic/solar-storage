%% Load example irradiance data
% Irradiance for Photovoltaic simulation over a 12 hour period
load pvData.mat;

clearIrrad = [time(1:end-24) clearIrrad(25:end)];
cloudyIrrad = [time(1:end-24) cloudyIrrad(25:end)];
loadData = [time(1:end-24) 115*sin(3.5/time(end-24)*time(1:end-24)-0.5)+150];

%% Initial conditions for battery

% Charge deficit
cellsInParallel = 4;
Qe_init = 1*cellsInParallel; %Ampere*hours

% Ambient Temperature
ambientTemp = 20;               % Ambient Temperature [C]
T_init = ambientTemp + 273.15;  % Convert to Kelvin [K]