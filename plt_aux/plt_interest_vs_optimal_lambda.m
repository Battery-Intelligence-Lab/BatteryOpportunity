function plt_interest_vs_optimal_lambda(cal, cyc, both)
plt_common;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');
N_CC = length(both.all.CC_list);
optimal_lambda = zeros(1,N_CC);
max_PIs = zeros(1,N_CC);




method = 'spline';

%colors= flipud(viridis(length(CC_to_plot)));
%icolor = 1;
temp_lambda = both.all.lambda_cal(1):0.01:both.all.lambda_cal(end);
for iii=1:N_CC
    temp_PI = interp1(both.all.lambda_cal, both.all.PI_list(:,iii)', temp_lambda,method);
    [max_PI, max_i] = max(temp_PI);
    optimal_lambda(iii) = temp_lambda(max_i);
    max_PIs(iii) = max_PI;

 %   plot(temp_lambda, temp_PI,lw{:},'color',colors(icolor,:)); hold on;
   % icolor = icolor+1;
end

% lin_curve = [1e-3, max(both.all.LambdaExp_list(:,1))]*1.2;
% 
% plot(both.all.lambda_cal, lin_curve,'b--', lw{:});
% xlim([-0.1,25])
% ylim([-0.1,7])

ratio = max_PIs./optimal_lambda;

%plot(both.all.CC_list+1, ratio); hold on;

a_coeff = (ratio-1)/(both.all.CC_list);

%plot(both.all.CC_list+1, 1+(both.all.CC_list)*a_coeff);

plot(both.all.CC_list*100, optimal_lambda,'LineWidth',1.3); hold on;
plot(both.all.CC_list*100, max_PIs./(1+both.all.CC_list),'--','LineWidth',1.3); 

xlabel('Interest rate (%)'); 
ylabel('Profitability index (-)');
legend('Optimal \lambda', 'PI/(1+i)') %/(1+both.all.CC_list)


% plot(optimal_lambda, max_PIs, 'LineWidth',1.3); hold on;
% plot(optimal_lambda, optimal_lambda);
% xlabel('Optimal lambda (-)');
% ylabel('Profitability index (-)');
% legend('Optimal \lambda vs PI', 'One-to-one line','Location','northwest') %/(1+both.all.CC_list)



% plot(both.all.CC_list*100, max_PIs,'--','LineWidth',1.3); 
% 
% xlabel('Interest rate (%)'); 
% ylabel('Profitability index (-)');
% legend('Optimal \lambda', 'PI') %/(1+both.all.CC_list)

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

plt_name = "CC_vs_optLambda";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));
%saveas(fig1,fullfile(plot_folder, plt_name + ".pdf"));
fig1.PaperSize = fig1.PaperPosition(3:4);
print(fig1, fullfile(plot_folder, plt_name + ".pdf"), '-dpdf');

end