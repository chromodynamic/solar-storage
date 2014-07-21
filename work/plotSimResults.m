% Parse Battery Results
tsim = BatteryData.time;
SOC = BatteryData.signals(3).values;
i_batt = BatteryData.signals(2).values;
v_batt = BatteryData.signals(1).values;

% Parse Power Converter Duty Cycles
D_batt = (1 + duty.signals(1).values)/2;
D_mppt = (1 + duty.signals(2).values)/2;

% Parse power distributions
P_load = PowerDist.signals.values(:,1);
P_pv = PowerDist.signals.values(:,2);
P_batt = PowerDist.signals.values(:,3);
P_grid = PowerDist.signals.values(:,4);

tsim = tsim/60; % Convert to minutes

% Power allocation figure
figure;
plot(tsim,P_load,tsim,P_pv,tsim,P_batt,tsim,P_grid,'LineWidth',2); grid on;
legend('Load','PV','Battery','Grid');
xlabel('Time [min]');
ylabel('Power [W]');

% Battery/conveter cycles figure
figure;
subplot(2,2,1)
plot(tsim,irradiance(:,2),'LineWidth',2); grid on;
xlabel('Time [min]');
ylabel('Irradiance [W/m^2]');

subplot(2,2,2)
[hAx,hLine1,hLine2] = plotyy(tsim,v_batt,tsim,i_batt);
xlabel('Time (min)');
ylabel(hAx(1),'Terminal Voltage [V]'); set(hAx(1),'FontSize',12);
ylabel(hAx(2),'Battery Current [A]');  set(hAx(2),'FontSize',12);
grid on;
set(hLine1,'LineWidth',2)
set(hLine2,'LineWidth',2,'LineStyle','-.')
% legend('Battery Current','Terminal Voltage')

subplot(2,2,3)
plot(tsim,SOC,'LineWidth',2); grid on;
ylabel('State-of-charge [%]');
xlabel('Time (min)');

subplot(2,2,4)
plot(tsim,D_batt,tsim,D_mppt,'LineWidth',2); grid on;
ylabel('Duty Cycle [%]');
xlabel('Time (min)');
legend('Battery Duty','MPPT Duty');
