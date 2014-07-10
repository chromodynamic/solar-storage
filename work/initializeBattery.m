% Initialization file for example battery model ssc_lithium_cell_2RC.mdl
% based on T. Huria, M. Ceraolo, J. Gazzarri, R. Jackey. "High Fidelity
% Electrical Model with Thermal Dependence for Characterization and
% Simulation of High Power Lithium Battery Cells," IEEE International
% Electric Vehicle Conference, March 2012
%
% Copyright 2012 The MathWorks, Inc.

%% Load bus objects for model
load measControlBus.mat;
load pvData.mat;

pvData = [time(1:end-49) irradiance(50:end)];
loadData = [time(1:end-49) 115*sin(3.5/pvData(end,1)*pvData(:,1)-0.5)+150];

%% Battery Charge/Discharge Values

% Charge Conditions
finalVoltage = 30;      % Desired Final Cell Voltage [V]
currentSat = 0.5;       % Current Saturation (Charge off) [A]
maxChargeRate = 5;      % Constant Current Charge Rate [A]

% Discharge Conditions
maxDischargeRate = -5;  % Maximum Discharge Rate [A]

% Bus Regulation
% desiredBusVoltage = 24.45; % Desired DC bus voltage [V]
desiredBusVoltage = 30; % Desired DC bus voltage [V]


% Ambient Temperature
ambientTemp = 20;       % Ambient Temperature [C]

cellsInParallel = 8;

% Charge deficit
Qe_init = 3*cellsInParallel; %Ampere*hours

% Ambient temperature
T_init = 20 + 273.15; %K

%% Lookup Table Breakpoints

SOC_LUT = [0 0.1 0.25 0.5 0.75 0.9 1]';
Temperature_LUT = [-20 -15 -10 0 20 40] + 273.15;

%% Em Branch Properties
% Battery capacity
Capacity_LUT = [
    2.741  2.903  3.333  4.059  4.180  4.178
    ]; %Ampere*hours
Capacity_LUT = Capacity_LUT*cellsInParallel;

% Em open-circuit voltage vs SOC rows and T columns
Em_LUT = [
    3.238  3.199  3.189  3.101  3.029  3.142
    3.309  3.363  3.344  3.245  3.230  3.235
    3.350  3.252  3.256  3.268  3.295  3.297
    3.267  3.271  3.276  3.287  3.343  3.316
    3.303  3.279  3.289  3.308  3.345  3.338
    3.315  3.314  3.317  3.340  3.367  3.338
    3.343  3.330  3.331  3.504  3.483  3.585
]; %Volts

%% Terminal Resistance Properties

% R0 resistance vs SOC rows and T columns
R0_LUT = [
    0.0475  0.0304  0.0276  0.0148  0.0124  0.0019
    0.0539  0.0450  0.0280  0.0121  0.0116  0.0023
    0.0655  0.0400  0.0254  0.0171  0.0243  0.0075
    0.0439  0.0276  0.0256  0.0116  0.0062  0.0038
    0.0537  0.0389  0.0252  0.0116  0.0214  0.0055
    0.0471  0.0443  0.0245  0.0123  0.0389  0.0010
    0.0425  0.0270  0.0182  0.0130  0.0095  0.0211
    ]; %Ohms

%% RC Branch 1 Properties

% R1 Resistance vs SOC rows and T columns
R1_LUT = [
    0.1124  0.0893  0.0963  0.0762  0.0686  0.0103
    0.0792  0.0851  0.0727  0.0386  0.0346  0.0030
    0.7022  0.0420  0.0543  0.0217  0.0737  0.0987
    0.0025  0.0136  0.0170  0.0249  0.1033  0.2771
    0.0254  0.0189  0.0086  0.0068  0.0325  0.0025
    0.0283  0.0230  0.0265  0.0137  0.0225  0.0033
    0.0523  0.0510  0.0298  0.0427  0.0497  0.0291
    ]; %Ohms

% C1 Capacitance vs SOC rows and T columns
C1_LUT = [
       619     493     873    1941     860   22842
       351     221      19    1115    2072   74025
     10435    2209    3895    5088    6814  298857
     25987   24765   40020   71649   89099  665892
      4779    1001    4522    4008    5591   53143
       663      15      45    1128    1935    6313
       148      10      12     512     541     108

]; %Farads

% R2 Resistance vs SOC rows and T columns
R2_LUT = [
    0.0941  0.0137  0.0432  0.3822  0.3938  0.4072
    0.0966  0.1342  0.0773  0.0591  0.0930  0.1976
    0.0569  0.0275  0.0303  0.0061  0.0293  0.0067
    0.0475  0.0483  0.0284  0.0143  0.0405  0.0027
    0.0193  0.0144  0.0160  0.0071  0.0132  0.0056
    0.0386  0.0354  0.0397  0.0348  0.1296  0.0052
    0.2546  0.3326  0.6113  0.9565  0.9837  0.9115
    ]; %Ohms

% C2 Capacitance vs SOC rows and T columns
C2_LUT = [
        14      78      21     115   27539   13861
     44695  212996  143644  361717  346974  362745
      1268     414     216    3876    3623   75454
       208     103     222     847     886   39630
        36     163     492    1921    5320   58952
      3156   14964   29348   68274   68279  256576
     16210   99517  242065  140296  140437  331497
    ]; %Farads


%% Thermal Properties

% Cell dimensions and sizes
cell_thickness = 0.0084; %m
cell_width = 0.215; %m
cell_height = 0.220; %m

% Cell surface area
cell_area = 2 * (...
    cell_thickness * cell_width +...
    cell_thickness * cell_height +...
    cell_width * cell_height); %m^2

% Cell volume
cell_volume = cell_thickness * cell_width * cell_height; %m^3

% Cell mass
cell_mass = 1; %kg

% Volumetric heat capacity (assumes uniform heat capacity throughout the cell)
cell_rho_Cp = 2.04E6; %J/m3/K

% Specific Heat
cell_Cp_heat = cell_rho_Cp * cell_volume; %J/kg/K

% Convective heat transfer coefficient
% For natural convection this number should be in the range of 5 to 25
h_conv = 5; %W/m^2/K