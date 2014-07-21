%% Load example irradiance data
% Irradiance for Photovoltaic simulation over a 12 hour period
load pvData.mat;

clearDay = 0;
if clearDay == 1,
    irradiance = clearIrrad;
else
    irradiance = cloudyIrrad;
end

pvData = [time(1:end-24) irradiance(25:end)];
loadData = [time(1:end-24) 115*sin(3.5/pvData(end,1)*pvData(:,1)-0.5)+150];

%% Initial conditions for battery

% Charge deficit
cellsInParallel = 4;
Qe_init = 1*cellsInParallel; %Ampere*hours

% Ambient Temperature
ambientTemp = 20;               % Ambient Temperature [C]
T_init = ambientTemp + 273.15;  % Convert to Kelvin [K]