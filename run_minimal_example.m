% This is a minimal example for numerical investigation of 1/(1+i)
% Author: Volkan Kumtepeli
% Date:   2024.09.04

clear variables; close all; clc;

load('minimal_example.mat');

% Some user settings: 

CC_list = 0:0.01:0.9; % Interest rate 0% to 90%. 

% Preprocess data, create auxillary variables in case we need. 
Nsim = length(sim);
dtd  = dth/24;
dty  = dtd/365; 

nth  = 1/dth; 
ntd  = 24*nth;
nty  = 365*ntd; 

indexing = 1; % 1 or 0.

lambda_approx = revenue_at_EOL/cost_whole/(1-EOL); % Hypothesis of lambda 

for i=1:Nsim
    sim(i).Qloss = sim(i).Qloss_cal + sim(i).Qloss_cyc; % Qloss at each step
    sim(i).SOH   = 1 - [0, cumsum(sim(i).Qloss)];       % SOH at each step
    sim(i).dFEC  = abs(sim(i).Pnett)*dth/Enom/2;
    sim(i).FEC   = [0, cumsum(sim(i).dFEC)]; 
    
    sim(i).time_h = sim(i).time_d*24;  % time in days
    sim(i).time_y = sim(i).time_d/365; % time in years
    
    sim(i).N_year = ceil(sim(i).time_y(end)); % total years to consider for NPV
    sim(i).N_day  = ceil(sim(i).time_d(end)); % total days to consider for NPV
    
    sim(i).NPV_indices = [1:nty:length(sim(i).time_y), length(sim(i).time_y)]; % for years 0, 1, 2, ... value of last day.
    

    sim(i).cumulative_revenue = [0, cumsum(sim(i).revenue)];
    sim(i).profit_per_year    = diff(sim(i).cumulative_revenue(sim(i).NPV_indices))';
    
    NPV_years_0 = (0:sim(i).N_year-1)'; % Starting from zero.
    NPV_years_1 = (1:sim(i).N_year)';   % Starting from one.
    
    if(indexing == 0)
    NPV_years = NPV_years_0;
    elseif(indexing == 1)
    NPV_years = NPV_years_1;
    else
        error('indexing should be 0 or 1\n');
    end

    
    discounted_mat = sim(i).profit_per_year./((1 + CC_list).^(NPV_years));
    

    NPV_list(i,:) = sum(discounted_mat);
    PI_list(i,:)  = NPV_list(i,:)/ c_investment;

    SOH_per = -diff(sim(i).SOH(sim(i).NPV_indices))';
    LambdaExp_list(i,:) = sum(discounted_mat.*SOH_per/mean(SOH_per)/c_investment);
end


% Plotting 

plt_common;
height_ = height_/1.5;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');
N_CC = length(CC_list);
optimal_lambda = zeros(1,N_CC);
max_PIs = zeros(1,N_CC);

method = 'spline';

temp_lambda = lambda_cal(1):0.01:lambda_cal(end);
for iii=1:N_CC
    temp_PI = interp1(lambda_cal, PI_list(:,iii)', temp_lambda,method);
    [max_PI, max_i] = max(temp_PI);
    optimal_lambda(iii) = temp_lambda(max_i);
    max_PIs(iii) = max_PI;
end

ratio = max_PIs./optimal_lambda;
a_coeff = (ratio-1)/(CC_list);


plot(CC_list*100, optimal_lambda,'LineWidth',1.3); hold on;

    if(indexing == 0)
    plot(CC_list*100, max_PIs,'--','LineWidth',1.3); 
    legend('Optimal \lambda', 'PI') %/(1+CC_list)
    elseif(indexing == 1)
    plot(CC_list*100, max_PIs./(1+CC_list),'--','LineWidth',1.3); 
    legend('Optimal \lambda', 'PI/(1+i)')
    end

xlabel('Interest rate (%)'); 
ylabel('Optimal \lambda and PI (-)');

ax = gca;
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