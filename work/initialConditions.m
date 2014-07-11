%% Load example irradiance data
% Irradiance for Photovoltaic simulation over a 12 hour period
load pvData.mat;

pvData = [time(1:end-24) irradiance(25:end)];

%% Initial conditions for battery

% Charge deficit
cellsInParallel = 4;
Qe_init = 1*cellsInParallel; %Ampere*hours

% Ambient Temperature
ambientTemp = 20;               % Ambient Temperature [C]
T_init = ambientTemp + 273.15;  % Convert to Kelvin [K]