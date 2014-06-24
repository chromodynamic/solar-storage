tsim = BatteryData.time;
SOC = BatteryData.signals(1).values;
i_batt = BatteryData.signals(2).values;
v_batt = BatteryData.signals(3).values;
D = (1 + duty(:,2))/2;

v_batt(tsim < 0.5) = NaN; % Remove transients
D(tsim < 0.5) = NaN;
i_batt(tsim < 0.5) = NaN; i_batt(1) = -15;
chargeLogic(tsim < 0.5) = NaN;

tsim = tsim/60; % Conver to minutes
switchCondition = find(chargeLogic == 0,1,'first');
tswitch = tsim(switchCondition);

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
plot(tsim,D,'LineWidth',2); grid on;
ylabel('Duty Cycle [%]');
xlabel('Time (min)');
