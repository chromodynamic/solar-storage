%% Battery Charge/Discharge Values

% Max/min SOC
maxSOC = 80;
minSOC = 20;

% SOC Hysteresis threshold
hysteresisSOC = 5;

% Charge Conditions
finalVoltage = 30;      % Desired Final Cell Voltage [V]
currentSat = 0.5;       % Current Saturation (Charge off) [A]
maxChargeRate = 6;      % Constant Current Charge Rate [A]

% Discharge Conditions
maxDischargeRate = -5;  % Maximum Discharge Rate [A]

% Bus Regulation
% desiredBusVoltage = 24.45; % Desired DC bus voltage [V]
desiredBusVoltage = 30; % Desired DC bus voltage [V]

% Power hysteresis threshold [W]
powerHysteresis = 10;

