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

% Settings:
text_font = 12;
lw = {'LineWidth',1.3};
lw2 = {'LineWidth',1.5};

golden_ratio = 1.618;
x0 = 1;
y0 = 1;
plot_folder = "plots";

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
Enom = 192; % 192 kWhcap
width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

semilogx(all_cal.lambda_cal, all_cal.revenue_at_EOL/Enom,'o-', lw{:}); hold on;
semilogx(all_cyc.lambda_cyc, all_cyc.revenue_at_EOL/Enom,'d-', lw{:});
semilogx(all_both.lambda_cal, all_both.revenue_at_EOL/Enom,'s-', lw{:});

grid on; xlabel('\lambda (-)'); 
ylabel('Revenue per capacity (EUR/kWh_{cap})');

xline(1)
xlim([0.001/1.5, 130]);
ylim([150,1600])

leg = legend('Case 1: only \lambda_{cal}', 'Case 2: only \lambda_{cyc}', 'Case 3: both \lambda_{cal}, \lambda_{cyc}',...
       'Location','northwest');

leg.FontSize = text_font;

% New_XTickLabel = get(gca,'xtick');
% set(gca,'XTickLabel',New_XTickLabel);

ax = gca;
ax.XTick = [0.001, ax.XTick];
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')


plt_name = "profit_vs_lambda";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));


