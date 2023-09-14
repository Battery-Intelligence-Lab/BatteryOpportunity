clear variables; close all; clc;

folder = 'results/sensitivity_2023_09_13_real';

idc = readmatrix('data/idc_positive_dummy.csv')';

% load cal lambda sensitivity
now_cal = load_case(folder, "lambda_cal");
[now_cal, all_cal] = process_and_verify(now_cal);

% load cyc lambda sensitivity
now_cyc = load_case(folder, "lambda_cyc");
[now_cyc, all_cyc] = process_and_verify(now_cyc);

% load both lambda sensitivity  
now_both = load_case(folder, "both");
[now_both, all_both] = process_and_verify(now_both);

% Don't forget that we probably didn't save the very initial value of the things.

%% Settings:
text_font = 12;
lw = {'LineWidth',1.3};
lw2 = {'LineWidth',1.5};


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
semilogx(all_cyc.lambda_cyc, all_cyc.revenue_at_EOL/1e3,'d-');
grid on; xlabel('\lambda (-)'); ylabel('Revenue (thousand EUR)');

hold on;

semilogx(all_cal.lambda_cal, all_cal.revenue_at_EOL/1e3,'o-');
semilogx(all_both.lambda_cal, all_both.revenue_at_EOL/1e3,'x-');
xline(1)

legend('\lambda-cycle perturbation', '\lambda-calendar perturbation', '\lambda-both perturbation',...
       'Location','northwest')

set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')


