function plt_cal_cyc_portions(cal, cyc, both)
plt_common;
width_  = 7/3; % 3.5 inch / 9 cm 
height_ = 1.05*width_/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

semilogx(cal.all.lambda_cal, cal.all.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(cal.all.lambda_cal, cal.all.Qloss_cyc_at_EOL*100,'bd-', lw{:}); 

grid on; xlabel('\lambda-cal (-)'); 
ylabel('Aging at EOL (%)');

xline(1)
xlim([0.001/1.5, 130]);
ylim([-1,21])

leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');
leg.FontSize = text_font;

ax = gca;
ax.XTick = [0.001, 0.01, 0.1, 1, 3, 10, 100];
xlim([0.001/1.5, 130]);
ax.XTickLabelRotation = 0;

set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')

leg.Position(1) = 0.16;
leg.Position(2) = 0.79;

plt_name = "ageing_vs_lambda_cal";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));

%----------------------- versus lambda cyc ------------------------

price_per_cap = 250; 
Enom = 192; % 192 kWhcap
EOL = 0.8;
cost_whole = Enom*price_per_cap/(1-EOL);

fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

semilogx(cyc.all.lambda_cyc, cyc.all.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(cyc.all.lambda_cyc, cyc.all.Qloss_cyc_at_EOL*100,'bd-', lw{:});

grid on; xlabel('\lambda-cyc (-)'); 
ylabel('Aging at EOL (%)');

xline(1)
xlim([0.001/1.5, 130]);
ylim([-1,21])

leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');

leg.FontSize = text_font;

ax = gca;
ax.XTick = [0.001, 0.01, 0.1, 1, 3, 10, 100];
xlim([0.001/1.5, 130]);
ax.XTickLabelRotation = 0;

set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')

leg.Position(1) = 0.16;
leg.Position(2) = 0.79;


plt_name = "ageing_vs_lambda_cyc";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));

%----------------------- versus BOTH ---------------------------------------

price_per_cap = 250; 
Enom = 192; % 192 kWhcap
EOL = 0.8;
cost_whole = Enom*price_per_cap/(1-EOL);


fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

% 
semilogx(both.all.lambda_cal, both.all.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(both.all.lambda_cal, both.all.Qloss_cyc_at_EOL*100,'bd-', lw{:});

grid on; xlabel('\lambda-both (-)'); 
ylabel('Aging at EOL (%)');

xline(1)
ax.XTick = [0.001, 0.01, 0.1, 1, 3, 10, 100];

ylim([-1,21])

leg = legend('Calendar aging', 'Cycle aging', 'Location','northwest');

leg.FontSize = text_font;

ax = gca;
ax.XTick = [0.001, 0.01, 0.1, 1, 3, 10, 100];
xlim([0.001/1.5, 130]);
ax.XTickLabelRotation = 0;

set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')

leg.Position(1) = 0.16;
leg.Position(2) = 0.79;

plt_name = "ageing_vs_lambda_both";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));
end