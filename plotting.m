clear all; close all; clc;

folder = 'results/sensitivity_2023_09_13_real';
study_name = "lambda_cyc";

caseNow = load_case(folder, study_name);
idc = readmatrix('data/idc_positive_dummy.csv')';
dth = 0.25;
allCases = []; 
%% Don't forget that we probably didn't save the very initial value of the things.
% Process cases:
for i=1:length(caseNow)
    caseNow(i).SOH = 1 - [0, cumsum(caseNow(i).Qloss)];
    caseNow(i).time_h = (0:length(caseNow(i).SOH)-1)*dth;
    caseNow(i).time_d = caseNow(i).time_h/24;
    caseNow(i).time_y = caseNow(i).time_d/365;

    caseNow(i).cumulative_revenue = [0, cumsum(caseNow(i).revenue)];
    allCases.lambda_cyc(i) = caseNow(i).settings.lambda_cyc;
    allCases.lambda_cal(i) = caseNow(i).settings.lambda_cal;
    allCases.revenue_at_EOL(i) = caseNow(i).cumulative_revenue(end); % PS: not exactly 80%
end

%% SOH vs time
figure;
for i=1:length(caseNow)
    plot(caseNow(i).time_y, caseNow(i).SOH*100);
    grid on; xlabel('time (years)'); ylabel('SOH (%)');
    hold on;
end
title(strrep(study_name,'_',' '));
legend('1','2','3', '4');
%% Revenue vs time:

figure;
for i=1:length(caseNow)
    plot(caseNow(i).time_y, caseNow(i).cumulative_revenue);
    grid on; xlabel('time (years)'); ylabel('Revenue (EUR)');
    hold on;
end
title(strrep(study_name,'_',' '));
legend('1','2','3','4');

%% Revenue vs SOH:

figure;
for i=1:length(caseNow)
    plot(caseNow(i).SOH*100, caseNow(i).cumulative_revenue);
    grid on; xlabel('time (years)'); ylabel('Revenue (EUR)');
    hold on;
end
title(strrep(study_name,'_',' '));
legend('1','2','3','4');

%% Revenue by lambda cyc/cal: 

figure;
semilogx(allCases.lambda_cyc, allCases.revenue_at_EOL,'d-');
grid on; xlabel('\lambda cycle (-)'); ylabel('Revenue (EUR)');
title(strrep(study_name,'_',' '));
%legend('1','2','3','4');

figure;
semilogx(allCases.lambda_cal, allCases.revenue_at_EOL,'d-');
grid on; xlabel('\lambda calendar (-)'); ylabel('Revenue (EUR)');
title(strrep(study_name,'_',' '));
%legend('1','2','3','4');


