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


%% Fig 1-3 combined AFTER REVISION: 


%% NEW FIGURE best profit vs. interest rate. 
close all;
width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

N_CC = length(all_both.CC_list);
my_CC_to_plot = [0, 0.01, 0.02, 0.03, 0.05, 0.08, 0.12, 0.2];
iCC_to_plot = interp1(all_both.CC_list,1:length(all_both.CC_list), my_CC_to_plot);
CC_to_plot = all_both.CC_list(iCC_to_plot);

colors= flipud(viridis(length(CC_to_plot)));
icolor = 1;
for iii=iCC_to_plot
    plot(all_both.lambda_cal', all_both.PI_list(:,iii),lw{:},'color',colors(icolor,:)); hold on;
    icolor = icolor+1;
end

lin_curve = [1e-3, max(all_both.PI_list(:,1))]*1.2;

plot(lin_curve, lin_curve,'b--', lw{:});
xlim([-0.1,25])
ylim([-0.1,7])

xlabel('\lambda-both (-)'); 
ylabel('Profitability index (-)');

%grid on;


ax = gca;
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
y1 = interp1(all_both.lambda_cal', all_both.PI_list(:,1), x1);

x2 = 9.41171875;
y2 = interp1(all_both.lambda_cal', all_both.PI_list(:,2), x2);

x3 = 8.5;
y3 = interp1(all_both.lambda_cal', all_both.PI_list(:,3), x3);

xN = 5.5;
yN = interp1(all_both.lambda_cal', all_both.PI_list(:,iCC_to_plot(end)), xN);

text(7.2, 6.6, "PI = \lambda line",'FontName','Times','FontSize',13);
text(x1, y1, "no interest",'Rotation',-36, annot_set{:});
text(x2, y2,   "{\iti} = 1%",'Rotation',-32, annot_set{:});
text(x3, y3,  "{\iti} = 2%",'Rotation',-30, annot_set{:});
text(xN, yN, "{\iti} = 20%",'Rotation',-20,annot_set{:});
%5.457552083333336,0.140080971659919   
%annotation('text',[0.45 0.34],[0.92 0.92],'String','PI = \lambda line','FontName','Times','FontSize',13);

plt_name = "CC_vs_PI";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));
saveas(fig1,fullfile(plot_folder, plt_name + ".pdf"));
fig1.PaperSize = fig1.PaperPosition(3:4);
print(fig1, fullfile(plot_folder, plt_name + ".pdf"), '-dpdf');

%% NEW FIGURE best profit vs. interest rate. interpolated
close all;
width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

N_CC = length(all_both.CC_list);
my_CC_to_plot = [0, 0.01, 0.02, 0.03, 0.05, 0.08, 0.12, 0.2];
iCC_to_plot = interp1(all_both.CC_list,1:length(all_both.CC_list), my_CC_to_plot);
CC_to_plot = all_both.CC_list(iCC_to_plot);

colors= flipud(viridis(length(CC_to_plot)));
icolor = 1;
temp_lambda = all_both.lambda_cal(1):0.01:all_both.lambda_cal(end);
for iii=iCC_to_plot
    temp_PI = interp1(all_both.lambda_cal, all_both.PI_list(:,iii)', temp_lambda,'cubic');
    plot(temp_lambda, temp_PI,lw{:},'color',colors(icolor,:)); hold on;
    icolor = icolor+1;
end

lin_curve = [1e-3, max(all_both.PI_list(:,1))]*1.2;

plot(lin_curve, lin_curve,'b--', lw{:});
xlim([-0.1,25])
ylim([-0.1,7])

xlabel('\lambda-both (-)'); 
ylabel('Profitability index (-)');

ax = gca;
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
y1 = interp1(all_both.lambda_cal', all_both.PI_list(:,1), x1);

x2 = 9.41171875;
y2 = interp1(all_both.lambda_cal', all_both.PI_list(:,2), x2);

x3 = 8.5;
y3 = interp1(all_both.lambda_cal', all_both.PI_list(:,3), x3);

xN = 5.5;
yN = interp1(all_both.lambda_cal', all_both.PI_list(:,iCC_to_plot(end)), xN);

text(7.2, 6.6, "PI = \lambda line",'FontName','Times','FontSize',13);
text(x1, y1, "no interest",'Rotation',-36, annot_set{:});
text(x2, y2,   "{\iti} = 1%",'Rotation',-32, annot_set{:});
text(x3, y3,  "{\iti} = 2%",'Rotation',-30, annot_set{:});
text(xN, yN, "{\iti} = 20%",'Rotation',-20,annot_set{:});
%5.457552083333336,0.140080971659919   
%annotation('text',[0.45 0.34],[0.92 0.92],'String','PI = \lambda line','FontName','Times','FontSize',13);

plt_name = "CC_vs_PI_interp";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));
saveas(fig1,fullfile(plot_folder, plt_name + ".pdf"));
fig1.PaperSize = fig1.PaperPosition(3:4);
print(fig1, fullfile(plot_folder, plt_name + ".pdf"), '-dpdf');

%% NEW FIGURE best profit vs. interest rate. -> LOG version
close all;
width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

N_CC = length(all_both.CC_list);
my_CC_to_plot = [0, 0.01, 0.02, 0.03, 0.05, 0.08, 0.12, 0.2];
iCC_to_plot = interp1(all_both.CC_list,1:length(all_both.CC_list), my_CC_to_plot);
CC_to_plot = all_both.CC_list(iCC_to_plot);

colors= viridis(length(CC_to_plot));
icolor = 1;
for iii=iCC_to_plot
    semilogx(all_both.lambda_cal', all_both.PI_list(:,iii),lw{:},'color',colors(icolor,:)); hold on;
    icolor = icolor+1;
end

lin_curve = 0.1:0.01:max(all_both.PI_list(:,1))*1.2;

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
y1 = interp1(all_both.lambda_cal', all_both.PI_list(:,1), x1);

x2 = 9.41171875;
y2 = interp1(all_both.lambda_cal', all_both.PI_list(:,2), x2);

x3 = 8.5;
y3 = interp1(all_both.lambda_cal', all_both.PI_list(:,3), x3);

xN = 5.5;
yN = interp1(all_both.lambda_cal', all_both.PI_list(:,iCC_to_plot(end)), xN);

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

%% Dave figure (after revision) 
close all;
Enom = 192; % 192 kWhcap
width  = 3.5; % 3.5 inch / 9 cm 
height = 2*width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');
gap    = [.01 .03];
marg_h = [.1  .01];
marg_w = [.01 .01];


[ha, pos] = tight_subplot(2, 1, gap, marg_h, marg_w);

iall = [15, 27, 29]
 
colors= flipud(viridis(length(iall)));

for i=1:2
    hold(ha(i),'on');
    ha(i).XTickMode

end
t_sel = 100;
i0 = 1;
for i1 = iall
plot(ha(1), now_both(i1).time_y(1:t_sel:end), now_both(i1).SOH(1:t_sel:end)*100,lw{:},'color',colors(i0,:));
i0 = i0+1;
end
%xlim([0,50]);
%ylim([75,100]);

i0 = 1;
for i1 = iall
plot(ha(2), now_both(i1).profit_years, now_both(i1).yearly_profit,lw{:},'color',colors(i0,:)); hold on;
i0 = i0+1;
end
%xlim([0,50]);


% 
% a3 = semilogx(all_both.lambda_cal, all_both.FEC_at_EOL,'s-', lw{:});
% ylabel('Full equivalent cycles (-)');
% ylim([0,3.1]*1e4);
% yyaxis right;
% 
% %semilogx(all_cal.lambda_cal, all_cal.lifetime_y,'o-', lw{:}); hold on;
% %semilogx(all_cyc.lambda_cyc, all_cyc.lifetime_y,'d-', lw{:});
% semilogx(all_both.lambda_cal, all_both.lifetime_y,'d-', lw{:});
% 
% ylabel('Lifetime (years)');
% grid on; xlabel('\lambda-both (-)'); 
% ylim([-1,101]);
% 
% xline(1)
% xlim([0.001/1.5, 130]);
% %ylim([150,1600])
% 
% leg = legend('FEC', 'Lifetime', 'Location','northwest');
% 
% leg.FontSize = text_font;
% 
% % New_XTickLabel = get(gca,'xtick');
% % set(gca,'XTickLabel',New_XTickLabel);

%ax.XTick = [0.001, ax.XTick];
% set(gca,...
% 'Units','normalized',...
% 'FontUnits','points',...
% 'FontWeight','normal',...
% 'FontSize',text_font,...
% 'FontName','Times');
% set(gca,'LooseInset',max(get(gca,'TightInset'), 0.02))
set(gcf,'renderer','Painters')


plt_name = "summary";

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


%% Qlos_cal  Qlos_cyc 
close all;
price_per_cap = 250; 
Enom = 192; % 192 kWhcap
EOL = 0.8;
cost_whole = Enom*price_per_cap/(1-EOL);

width  = 7/3; % 3.5 inch / 9 cm 
height = 1.2*width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

semilogx(all_cal.lambda_cal, all_cal.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(all_cal.lambda_cal, all_cal.Qloss_cyc_at_EOL*100,'bd-', lw{:}); 

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
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(all_cyc.lambda_cyc, all_cyc.Qloss_cyc_at_EOL*100,'bd-', lw{:});

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
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

% 
semilogx(all_both.lambda_cal, all_both.Qloss_cal_at_EOL*100,'rs-', lw{:}); hold on;
semilogx(all_both.lambda_cal, all_both.Qloss_cyc_at_EOL*100,'bd-', lw{:});

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


plt_name = "ageing_vs_lambda_both";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));