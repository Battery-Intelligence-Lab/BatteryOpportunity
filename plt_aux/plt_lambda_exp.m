function plt_lambda_exp(cal, cyc, both)
plt_common;
height_ = width_/golden_ratio/0.8;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

%semilogx(cal.all.lambda_cal, cal.all.revenue_at_EOL/Enom,'o-', lw{:}); hold on;
%semilogx(cyc.all.lambda_cyc, cyc.all.revenue_at_EOL/Enom,'d-', lw{:});
loglog(both.all.lambda_cal, both.all.revenue_at_EOL/cost_whole/0.2,'s-', lw{:}); hold on;
loglog(both.all.lambda_cal, both.all.lambda_cal,'o-', lw{:});

grid on; xlabel('\lambda (-)'); 
ylabel('\lambda (-)');

%xline(1)
xlim([0.04, 60]);
ylim([0.04, 60])
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
end