function plt_rev_by_lambda(cal, cyc, both)
plt_common;
Enom = 192; % 192 kWhcap
EOL = 0.8;
price_per_cap = 250; 
cost_whole = Enom*price_per_cap/(1-EOL);
width_  = 3.5; % 3.5 inch / 9 cm 
height_ = width_/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

semilogx(cal.all.lambda_cal, cal.all.revenue_at_EOL/Enom,'o-', lw{:}); hold on;
semilogx(cyc.all.lambda_cyc, cyc.all.revenue_at_EOL/Enom,'d-', lw{:});
semilogx(both.all.lambda_cal, both.all.revenue_at_EOL/Enom,'s-', lw{:}); % cost_whole/0.2

%grid on; 
xlabel('\lambda (-)'); 
ylabel('NPV per capacity (EUR/kWh_{cap})');

%xline(1)
xlim([0.001/1.5, 130]);
ylim_per = [150, 1600];
ylim(ylim_per)

axfirst=gca;

set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')
yyaxis right;
axy = gca;
axy.YColor = 'k';
ylim(ylim_per/price_per_cap)

scaled_values_cal = cal.all.revenue_at_EOL/cost_whole/0.2;
scaled_values_cyc = cyc.all.revenue_at_EOL/cost_whole/0.2;
scaled_values_both = both.all.revenue_at_EOL/cost_whole/0.2;
ylabel('Profitability index (-)')


% Plotting the scaled data on the right y-axis
semilogx(cal.all.lambda_cal, scaled_values_cal, 'o-', 'Color', 'none', 'HandleVisibility', 'off'); hold on;
semilogx(cyc.all.lambda_cyc, scaled_values_cyc, 'd-',  'Color', 'none', 'HandleVisibility', 'off');
semilogx(both.all.lambda_cal, scaled_values_both, 's-', 'Color', 'none', 'HandleVisibility', 'off');


xline(6,'-','\lambda = 6','LabelVerticalAlignment','bottom','FontName','Times','FontSize',text_font*1.2,'LabelHorizontalAlignment','left')

leg = legend('only \lambda_{cal}', 'only \lambda_{cyc}', 'both \lambda_{cal}, \lambda_{cyc}',...
       'Location','northwest');

leg.FontSize = text_font;

% New_XTickLabel = get(gca,'xtick');
% set(gca,'XTickLabel',New_XTickLabel);

ax = gca;
ax.XTick =  [0.001, 0.01, 0.1, 1, 9.99999999999, 100];

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


% PI by lambda cyc/cal: 
Enom = 192; % 192 kWhcap
width_  = 3.23; % 3.5 inch / 9 cm 
height_ = 3.5/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

semilogx(cal.all.lambda_cal, cal.all.PI,'o-', lw{:}); hold on;
semilogx(cyc.all.lambda_cyc, cyc.all.PI,'d-', lw{:});
semilogx(both.all.lambda_cal, both.all.PI,'s-', lw{:});

%grid on; 
xlabel('\lambda (-)'); 
%ylabel('Profitability index (-)');
ylim(ylim_per/price_per_cap)

set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')
yyaxis right;
axy = gca;
axy.YColor = 'k';

scaled_values_cal = cal.all.NPV/Enom;
scaled_values_cyc = cyc.all.NPV/Enom;
scaled_values_both = both.all.NPV/Enom;
ylabel('NPV per capacity (EUR/kWh_{cap})')
semilogx(cal.all.lambda_cal, scaled_values_cal, 'o-', 'Color', 'none', 'HandleVisibility', 'off'); hold on;
semilogx(cyc.all.lambda_cyc, scaled_values_cyc, 'd-',  'Color', 'none', 'HandleVisibility', 'off');
semilogx(both.all.lambda_cal, scaled_values_both, 's-', 'Color', 'none', 'HandleVisibility', 'off');
ylim([150,1600])
xline(3,'-','\lambda = 3','LabelVerticalAlignment','bottom','FontName','Times','FontSize',text_font*1.2,'LabelHorizontalAlignment','left')


leg = legend('only \lambda_{cal}', 'only \lambda_{cyc}', 'both \lambda_{cal}, \lambda_{cyc}',...
       'Location','northwest');

leg.FontSize = text_font;

ax = gca;
ax.XTick = [0.001, 0.01, 0.1, 1, 9.999999999, 100];

xlim([0.001/1.5, 130]);

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
end