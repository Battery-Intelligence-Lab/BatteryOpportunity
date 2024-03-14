function plt_summary(cal, cyc, both)
plt_common;

height_ = 2*width_/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');
gap    = [.01 .03];
marg_h = [.06  .01];
marg_w = [.06 .01];


red = [0.635, 0.078, 0.184];
yellow =[0.929, 0.694, 0.125];
green = [0.133, 0.545, 0.133];

[ha, pos] = tight_subplot(2, 1, gap, marg_h, marg_w);

iall = [1, 28, 30]; %1:5:33 % 1:33%[15, 27, 29]
 
colors= [red; yellow; green]; %flipud(hsv(length(iall)));

for i=1:2
    hold(ha(i),'on');
    ha(i).XTickMode
  set(ha(i),...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');

  grid(ha(i),'on')

end
t_sel = 1000;
i0 = 1;
for i1 = iall
plot(ha(1), both.now(i1).time_y([1,end]), both.now(i1).SOH([1,end])*100,lw{:},'color',colors(i0,:));
i0 = i0+1;
end
xlim([2,50]);
%ylim([75,100]);
yline(ha(1),80,'k-.','Linewidth',2,'label','End of life (80% SOH)','LabelVerticalAlignment','bottom','FontName','Times','FontSize',text_font*1.2,'LabelHorizontalAlignment','right');

%set(gcf, 'CurrentAxes', ha(1))
annot_set = {'HorizontalAlignment','center','VerticalAlignment', 'bottom','FontName','Times','FontSize',12, 'Margin',1.2};

now_data = both.now(1);
i_mid = round(length(now_data.time_y)/2);
x_mid = now_data.time_y(i_mid);
y_mid = now_data.SOH(i_mid)*100;
% 
% dx_mid = diff(now_data.time_y([i_mid-10000, i_mid+10000]))/diff(xlim);
% dy_mid = diff(now_data.SOH([i_mid-10000, i_mid+10000]))/diff(ylim);
% 
% theta_mid = rad2deg(atan2(dy_mid,dx_mid));

text(ha(1), x_mid+1.5, y_mid-3, "heavy usage",'Rotation',-79, annot_set{:},'color',red);

now_data = both.now(28);
i_mid = round(length(now_data.time_y)/2);
x_mid = now_data.time_y(i_mid);
y_mid = now_data.SOH(i_mid)*100;
% 
% dx_mid = diff(now_data.time_y([i_mid-10000, i_mid+10000]))/diff(xlim);
% dy_mid = diff(now_data.SOH([i_mid-10000, i_mid+10000]))/diff(ylim);
% 
% theta_mid = rad2deg(atan2(dy_mid,dx_mid));

text(ha(1), x_mid+5.5, y_mid-3, "moderate usage",'Rotation',-44, annot_set{:},'color',yellow);


now_data = both.now(30);
i_mid = round(length(now_data.time_y)/2);
x_mid = now_data.time_y(i_mid);
y_mid = now_data.SOH(i_mid)*100;
% 
% dx_mid = diff(now_data.time_y([i_mid-10000, i_mid+10000]))/diff(xlim);
% dy_mid = diff(now_data.SOH([i_mid-10000, i_mid+10000]))/diff(ylim);
% 
% theta_mid = rad2deg(atan2(dy_mid,dx_mid));

text(ha(1), x_mid+1, y_mid, "light usage",'Rotation',-25, annot_set{:},'color',green);

i0 = 1;
for i1 = iall
plot(ha(2), both.now(i1).profit_years, both.now(i1).yearly_profit,lw{:},'color',colors(i0,:)); hold on;
plot(ha(2), both.now(i1).profit_years(end), both.now(i1).yearly_profit(end),'o','color',colors(i0,:),'MarkerFaceColor',colors(i0,:),'MarkerSize',9);
i0 = i0+1;
end
%xlim([0,50]);
linkaxes([ha],'x');
sel = 1:33;
sel(2) = [];

profit_years_end = arrayfun(@(x) x.profit_years(end), both.now);
yearly_profit_end = arrayfun(@(x) x.yearly_profit(end), both.now);

profit_years_end_interp = profit_years_end(1):0.1:100;
yearly_profit_end_interp = interp1(profit_years_end(sel), yearly_profit_end(sel), profit_years_end_interp,'spline');

[max_y, max_i] = max(yearly_profit_end_interp);

plot(ha(2), profit_years_end_interp, yearly_profit_end_interp, 'k--'); hold on;
plot(profit_years_end_interp(max_i), max_y, 'pentagram','MarkerSize',10,'MarkerFaceColor','b','MarkerEdgeColor','b')

ha(1).YLabel.String = 'State of health';
% ha(1).YTick =  80:5:100;
% ha(1).YTickLabel = ha(1).YTick;
ha(1).YLim = [75,100];

ha(2).YLabel.String = 'Financial returns';

ha(2).YLim = 1.2*ha(2).YLim;
ha(2).XLim = -0.025*diff(ha(2).XLim) + 1.025*ha(2).XLim;

set(gcf,'renderer','Painters');

xlabel('Time');

text(ha(2), 46, 117344, "End-of-life returns",'Rotation',-21, annot_set{:});
annotation('textarrow',[0.70 0.44],[0.48 0.45],'String','Maximum revenue\newlinefor the best usage','FontName','Times','FontSize',text_font);
text(ha(2), 33, 82294, "long life, low rate",'Rotation',11, annot_set{:},'color',green);
text(ha(2), 4, 65000, "short life, high rate",'Rotation',70, annot_set{:},'color',red);
text(ha(2), 16, 101000, "balanced use",'Rotation',40, annot_set{:},'color',yellow);


plt_name = "summary";


print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));
fig1.PaperSize = fig1.PaperPosition(3:4);
saveas(fig1,fullfile(plot_folder, plt_name + ".pdf"));

end