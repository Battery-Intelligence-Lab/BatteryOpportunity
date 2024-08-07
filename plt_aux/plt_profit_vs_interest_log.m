function plt_profit_vs_interest_log(cal, cyc, both)
plt_common;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

N_CC = length(both.all.CC_list);
my_CC_to_plot = [0, 0.01, 0.02, 0.03, 0.05, 0.08, 0.12, 0.2];
iCC_to_plot = interp1(both.all.CC_list,1:length(both.all.CC_list), my_CC_to_plot);
CC_to_plot = both.all.CC_list(iCC_to_plot);

colors= viridis(length(CC_to_plot));
icolor = 1;
for iii=iCC_to_plot
    semilogx(both.all.lambda_cal', both.all.PI_list(:,iii),lw{:},'color',colors(icolor,:)); hold on;
    icolor = icolor+1;
end

lin_curve = 0.1:0.01:max(both.all.PI_list(:,1))*1.2;

semilogx(lin_curve, lin_curve,'b--', lw{:});
xlim([0.04, 60]);
%ylim([0.04, 60])
%ylim([-0.1,7])

xlabel('\lambda-both (-)'); 
ylabel('Profitability index (-)');

%grid on;


ax = gca;
ax.XTick = [0.05, 0.1, 0.3, 1, 2.5, 6, 10, 25, 50];
%ax.YTick = ax.XTick;
%ax.XTick = [0.001, ax.XTick];
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters');
% annotation('textarrow',[0.45 0.34],[0.92 0.92],'String','PI = \lambda line','FontName','Times','FontSize',13);
% [normx, normy] = coord2norm(ax, [12 9], [5.7 5.7]);
% annotation('textarrow',normx,normy,'String','no interest','FontName','Times','FontSize',13);
% 
% [normx, normy] = coord2norm(ax, [15 8.8], [4.42 4.42]);
% annotation('textarrow',normx,normy,'String','{\it i} = 1%','FontName','Times','FontSize',13);
% 
% [normx, normy] = coord2norm(ax, [10 8], [3 3]);
% annotation('textarrow',normx,normy,'String','{\it i} = 2%','FontName','Times','FontSize',13);

%[normx, normy] = coord2norm(ax, [12 9], [5.7 5.7]);

annot_set = {'HorizontalAlignment','center','VerticalAlignment', 'middle','FontName','Times','FontSize',12, 'BackgroundColor','w','Margin',1.2};

x1 = 10.8;
y1 = interp1(both.all.lambda_cal', both.all.PI_list(:,1), x1);

x2 = 9.41171875;
y2 = interp1(both.all.lambda_cal', both.all.PI_list(:,2), x2);

x3 = 8.5;
y3 = interp1(both.all.lambda_cal', both.all.PI_list(:,3), x3);

xN = 5.5;
yN = interp1(both.all.lambda_cal', both.all.PI_list(:,iCC_to_plot(end)), xN);

% text(7.2, 6.6, "PI = \lambda line",'FontName','Times','FontSize',13);
% text(x1, y1, "no interest",'Rotation',-36, annot_set{:});
% text(x2, y2,   "{\iti} = 1%",'Rotation',-32, annot_set{:});
% text(x3, y3,  "{\iti} = 2%",'Rotation',-30, annot_set{:});
% text(xN, yN, "{\iti} = 20%",'Rotation',-20,annot_set{:});
%5.457552083333336,0.140080971659919   
%annotation('text',[0.45 0.34],[0.92 0.92],'String','PI = \lambda line','FontName','Times','FontSize',13);

plt_name = "CC_vs_PI_log";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));
saveas(fig1,fullfile(plot_folder, plt_name + ".pdf"));
fig1.PaperSize = fig1.PaperPosition(3:4);
print(fig1, fullfile(plot_folder, plt_name + ".pdf"), '-dpdf');
end