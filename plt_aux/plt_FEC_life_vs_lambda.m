function plt_FEC_life_vs_lambda(cal, cyc, both)
plt_common;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

%a1 = semilogx(cal.all.lambda_cal, cal.all.FEC_at_EOL,'o-', lw{:}); hold on;
%a2 = semilogx(cyc.all.lambda_cyc, cyc.all.FEC_at_EOL,'d-', lw{:});
a3 = semilogx(both.all.lambda_cal, both.all.FEC_at_EOL,'s-', lw{:});
ylabel('Full equivalent cycles (-)');
ylim([0,3.1]*1e4);
yyaxis right;

%semilogx(cal.all.lambda_cal, cal.all.lifetime_y,'o-', lw{:}); hold on;
%semilogx(cyc.all.lambda_cyc, cyc.all.lifetime_y,'d-', lw{:});
semilogx(both.all.lambda_cal, both.all.lifetime_y,'d-', lw{:});

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

end