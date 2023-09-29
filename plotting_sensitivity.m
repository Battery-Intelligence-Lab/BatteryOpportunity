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

%% Plot idc:
N_price = 367*24*4; % #TODO I repeated some prices accidentally. 

price_mat = reshape(idc(1:N_price),[],367);

[X_price,Y_price] = meshgrid(0:0.25:(24-0.25),1:367);

ax = surf(X_price', Y_price', price_mat);

colormap('parula')
%colormap(cmocean('solar'))
shading interp


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


%% PI by lambda cyc/cal: 
Enom = 192; % 192 kWhcap
width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

semilogx(all_cal.lambda_cal, all_cal.PI,'o-', lw{:}); hold on;
semilogx(all_cyc.lambda_cyc, all_cyc.PI,'d-', lw{:});
semilogx(all_both.lambda_cal, all_both.PI,'s-', lw{:});

grid on; xlabel('\lambda (-)'); 
ylabel('Profitability index (-)');

xline(3)


leg = legend('Case 1: only \lambda_{cal}', 'Case 2: only \lambda_{cyc}', 'Case 3: both \lambda_{cal}, \lambda_{cyc}',...
       'Location','southwest');

leg.FontSize = text_font;

% New_XTickLabel = get(gca,'xtick');
% set(gca,'XTickLabel',New_XTickLabel);

ax = gca;
ax.XTick = [0.001, 0.01, 0.1, 1, 3, 10, 100];
%ax.XTick = [0.01, 0.1, 0.3, 1, 2.5, 6, 10, 25, 50];

xlim([0.001/1.5, 130]);
ylim([0,3.2])

set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')


plt_name = "PI_vs_lambda";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));


%% FEC and lifetime. 
Enom = 192; % 192 kWhcap
width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

%a1 = semilogx(all_cal.lambda_cal, all_cal.FEC_at_EOL,'o-', lw{:}); hold on;
%a2 = semilogx(all_cyc.lambda_cyc, all_cyc.FEC_at_EOL,'d-', lw{:});
a3 = semilogx(all_both.lambda_cal, all_both.FEC_at_EOL,'s-', lw{:});
ylabel('Full equivalent cycles (-)');
ylim([0,3.1]*1e4);
yyaxis right;

%semilogx(all_cal.lambda_cal, all_cal.lifetime_y,'o-', lw{:}); hold on;
%semilogx(all_cyc.lambda_cyc, all_cyc.lifetime_y,'d-', lw{:});
semilogx(all_both.lambda_cal, all_both.lifetime_y,'d-', lw{:});

ylabel('Lifetime (years)');
grid on; xlabel('\lambda-both (-)'); 
ylim([-1,101]);

xline(1)
xlim([0.001/1.5, 130]);
%ylim([150,1600])

leg = legend('FEC', 'Lifetime', 'Location','northwest');

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


plt_name = "FEC_life_vs_lambda";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));


%% Revenue/ageing/cost_whole:

price_per_cap = 250; 
Enom = 192; % 192 kWhcap
EOL = 0.8;
cost_whole = Enom*price_per_cap/(1-EOL);



width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio/0.8;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

%semilogx(all_cal.lambda_cal, all_cal.revenue_at_EOL/Enom,'o-', lw{:}); hold on;
%semilogx(all_cyc.lambda_cyc, all_cyc.revenue_at_EOL/Enom,'d-', lw{:});
loglog(all_both.lambda_cal, all_both.revenue_at_EOL/cost_whole/0.2,'s-', lw{:}); hold on;
loglog(all_both.lambda_cal, all_both.lambda_cal,'o-', lw{:});

grid on; xlabel('\lambda (-)'); 
ylabel('\lambda (-)');

%xline(1)
xlim([0.04, 60]);
ylim([0.04,60])
xline(6);
yline(6);
leg = legend('\lambda-exp', '\lambda-both',...
       'Location','northwest');

leg.FontSize = text_font;

% New_XTickLabel = get(gca,'xtick');
% set(gca,'XTickLabel',New_XTickLabel);

ax = gca;
ax.XTick = [0.05, 0.1, 0.3, 1, 2.5, 6, 10, 25, 50];
ax.YTick = ax.XTick;
%set(ax, 'XTickLabel', num2str(get(ax,'XTick')','%.2f'));
%set(ax, 'YTickLabel', num2str(get(ax,'YTick')','%.1f'))



set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')


plt_name = "lambda_vs_lambda";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));


%% Qlos_cal  Qlos_cyc 

price_per_cap = 250; 
Enom = 192; % 192 kWhcap
EOL = 0.8;
cost_whole = Enom*price_per_cap/(1-EOL);

width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

semilogx(all_cal.lambda_cal, all_cal.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(all_cal.lambda_cal, all_cal.Qloss_cyc_at_EOL*100,'bd-', lw{:}); 

% semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cal_at_EOL*100,'rd-', lw{:}); hold on;
% semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cyc_at_EOL*100,'bd-', lw{:});
% 
% semilogx(all_both.lambda_cal, all_both.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
% semilogx(all_both.lambda_cal, all_both.Qloss_cyc_at_EOL*100,'bs-', lw{:});

grid on; xlabel('\lambda-cal (-)'); 
ylabel('Aging at EOL (%)');

xline(1)
xlim([0.001/1.5, 130]);
ylim([-1,21])

leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');

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


plt_name = "ageing_vs_lambda_cal";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));

%----------------------- versus lambda cyc ------------------------

price_per_cap = 250; 
Enom = 192; % 192 kWhcap
EOL = 0.8;
cost_whole = Enom*price_per_cap/(1-EOL);

width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

% semilogx(all_cal.lambda_cal, all_cal.Qloss_cal_at_EOL*100,'ro-', lw{:}); hold on;
% semilogx(all_cal.lambda_cal, all_cal.Qloss_cyc_at_EOL*100,'bo-', lw{:}); 

semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cyc_at_EOL*100,'bd-', lw{:});
% 
% semilogx(all_both.lambda_cal, all_both.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
% semilogx(all_both.lambda_cal, all_both.Qloss_cyc_at_EOL*100,'bs-', lw{:});

grid on; xlabel('\lambda-cyc (-)'); 
ylabel('Aging at EOL (%)');

xline(1)
xlim([0.001/1.5, 130]);
ylim([-1,21])

leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');

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


plt_name = "ageing_vs_lambda_cyc";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));

%----------------------- versus BOTH ---------------------------------------

price_per_cap = 250; 
Enom = 192; % 192 kWhcap
EOL = 0.8;
cost_whole = Enom*price_per_cap/(1-EOL);

width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

% semilogx(all_cal.lambda_cal, all_cal.Qloss_cal_at_EOL*100,'ro-', lw{:}); hold on;
% semilogx(all_cal.lambda_cal, all_cal.Qloss_cyc_at_EOL*100,'bo-', lw{:}); 

% semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cal_at_EOL*100,'rd-', lw{:}); hold on;
% semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cyc_at_EOL*100,'bd-', lw{:});
% 
semilogx(all_both.lambda_cal, all_both.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(all_both.lambda_cal, all_both.Qloss_cyc_at_EOL*100,'bd-', lw{:});

grid on; xlabel('\lambda-both (-)'); 
ylabel('Aging at EOL (%)');

xline(1)
xlim([0.001/1.5, 130]);
ylim([-1,21])

leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');

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


plt_name = "ageing_vs_lambda_both";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));

% %% Q ------------------- as subplot all --------------------------------
% 
% price_per_cap = 250; 
% Enom = 192; % 192 kWhcap
% EOL = 0.8;
% cost_whole = Enom*price_per_cap/(1-EOL);
% 
% width  = 3.5; % 3.5 inch / 9 cm 
% height = width/golden_ratio;
% fig1=figure('Units','inches',...
% 'Position',[x0 y0 (x0+width*3) (y0+height*1.2)],...
% 'PaperPositionMode','auto');
% 
% subplot(1,3,1);
% semilogx(all_cal.lambda_cal, all_cal.Qloss_cal_at_EOL*100,'ro-', lw{:}); hold on;
% semilogx(all_cal.lambda_cal, all_cal.Qloss_cyc_at_EOL*100,'bo-', lw{:}); 
% xlabel('\lambda-cal (-)'); 
% ylabel('Aging at EOL (%)'); grid on; 
% 
% xline(1)
% xlim([0.001/1.5, 130]);
% ylim([-1,21])
% 
% leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');
% 
% leg.FontSize = text_font;
% 
% 
% ax = gca;
% ax.XTick = [0.001, ax.XTick];
% set(gca,...
% 'Units','normalized',...
% 'FontUnits','points',...
% 'FontWeight','normal',...
% 'FontSize',text_font,...
% 'FontName','Times');
% set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
% set(gcf,'renderer','Painters')
% 
% 
% subplot(1,3,2);
% semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cal_at_EOL*100,'rd-', lw{:}); hold on;
% semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cyc_at_EOL*100,'bd-', lw{:});
% xlabel('\lambda-cyc (-)'); 
% ylabel('Aging at EOL (%)');grid on; 
% 
% xline(1)
% xlim([0.001/1.5, 130]);
% ylim([-1,21])
% 
% leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');
% 
% leg.FontSize = text_font;
% 
% 
% ax = gca;
% ax.XTick = [0.001, ax.XTick];
% set(gca,...
% 'Units','normalized',...
% 'FontUnits','points',...
% 'FontWeight','normal',...
% 'FontSize',text_font,...
% 'FontName','Times');
% set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
% set(gcf,'renderer','Painters')
% 
% 
% 
% subplot(1,3,3);
% semilogx(all_both.lambda_cal, all_both.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
% semilogx(all_both.lambda_cal, all_both.Qloss_cyc_at_EOL*100,'bs-', lw{:});
% 
% xlabel('\lambda-both (-)'); 
% ylabel('Aging at EOL (%)'); grid on; 
% 
% xline(1)
% xlim([0.001/1.5, 130]);
% ylim([-1,21])
% 
% leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');
% 
% leg.FontSize = text_font;
% 
% 
% ax = gca;
% ax.XTick = [0.001, ax.XTick];
% set(gca,...
% 'Units','normalized',...
% 'FontUnits','points',...
% 'FontWeight','normal',...
% 'FontSize',text_font,...
% 'FontName','Times');
% set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
% set(gcf,'renderer','Painters')
% 
% 
% plt_name = "ageing_vs_lambda_all";
% 
% print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
% print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
% savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));