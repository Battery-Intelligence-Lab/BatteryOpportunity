% Test hypothesis of 
% profit  =  a*cyc + b*cal + c    
% for a week time. 

clear variables; close all; clc;

folder = 'results/sensitivity_2023_09_13_real';

idc = readmatrix('data/idc_positive_dummy.csv')';

% load both lambda sensitivity  
both = process_and_verify(load_case(folder, "both"));

% Don't forget that we probably didn't save the very initial value of the things.

% Settings:
text_font = 12;
lw = {'LineWidth',1.3};
lw2 = {'LineWidth',1.5};

golden_ratio = 1.618;
x0 = 1;
y0 = 1;
plot_folder = "plots";

%%
avg_horizon = 24*7; % 1 week of horizon
cost_whole = 192*250/0.2;

i_now = find(both.all.lambda_cyc == 6);

caseNow = both.now(i_now);

dt = caseNow.settings.dt; 
N_avg = avg_horizon/dt; 


N_case = length(caseNow.revenue);
N_interest = floor(N_case/N_avg)*N_avg; 

prices = repmat(idc,1, ceil(N_interest/length(idc)));
prices = prices(1:N_interest);

prices_mat = reshape(prices,N_avg,[]);
prices_std = std(prices_mat);
prices_mean= mean(prices_mat);
prices_volatility = std(diff(prices_mat)./prices_mat(1:end-1,:));


revenue_mat = reshape(caseNow.revenue(1:N_interest),N_avg,[]);
revenue_std = std(revenue_mat);

revenue_sum = sum(reshape(caseNow.revenue(1:N_interest),N_avg,[]));
revenue_sum_normalised = revenue_sum./revenue_std;

Qcal_avg    = sum(reshape(caseNow.Qloss_cal(1:N_interest),N_avg,[]));
Qcyc_avg    = sum(reshape(caseNow.Qloss_cyc(1:N_interest),N_avg,[]));
Qtot_avg    = Qcal_avg  +  Qcyc_avg;


revenue_per_Q = revenue_sum./Qtot_avg;
lambda_per_Q = revenue_per_Q/cost_whole;

T = table(Qcal_avg', Qcyc_avg', revenue_sum', 'VariableNames', ["Qcal","Qcyc","Revenue"]);

writetable(T, "estimation_example.csv");


%% Plot spread! 

Enom = 192; % 192 kWhcap
width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio/1.5;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');


plfit = [revenue_sum/Qtot_avg, 0];           %polyfit(Qtot_avg,  revenue_sum,1');
line_val = polyval(plfit, Qtot_avg);

scatter(Qtot_avg*100, revenue_sum,'.','MarkerEdgeColor', 'flat', 'CData',viridis(length(Qtot_avg))); hold on;
plot(Qtot_avg*100,line_val,'LineWidth',1.3);
ylabel('Revenue (EUR)');
xlim([0.004, 0.0141])

grid on; xlabel('Qloss (%)'); 

leg = legend('Qloss', 'Least-squares fit', 'Location','northwest');

leg.FontSize = text_font;
colormap(viridis); % Set colormap to viridis
cbar = colorbar; % Add a colorbar
cbar.Ticks = [0 1]; % Set ticks at the beginning and end
cbar.TickLabels = {'Beg.\newlineof life', 'End\newlineof life'}; % Label the lower and upper limits
cbar.FontSize = 12;

ax = gca;
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.07))
set(gcf,'renderer','Painters')

%%
plt_name = "profit_vs_ageing_LS";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));
fig1.PaperSize = fig1.PaperPosition(3:4);
print(fig1, fullfile(plot_folder, plt_name + ".pdf"), '-dpdf');


%% Estimated weekly lambda
close all
Enom = 192; % 192 kWhcap
width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio/1.5;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');

scatter(Qtot_avg*100, lambda_per_Q,'.','MarkerEdgeColor', 'flat', 'CData',viridis(length(Qtot_avg))); hold on;
%plot(Qtot_avg*100,ones(size(Qtot_avg))*mean(lambda_per_Q),'LineWidth',1.3);
ylabel('Weekly \lambda (-)');
xlim([0.004, 0.0145])
ylim([0,14])
yticks(0:2:15)

grid on; xlabel('Weekly Qloss (%)'); 

%leg = legend('', "Mean \lambda"+sprintf('=%4.1f',mean(lambda_per_Q)), 'Location','northwest');
%leg.FontSize = text_font;

yline(mean(lambda_per_Q),'-',"Mean \lambda="+sprintf('%4.1f',mean(lambda_per_Q)),'LabelVerticalAlignment',...
    'bottom','FontName','Times','FontSize',text_font*1.2,'LabelHorizontalAlignment','right',...
    'LineWidth',1.5,'Color','b')

colormap(viridis); % Set colormap to viridis
cbar = colorbar; % Add a colorbar
cbar.Ticks = [0 1]; % Set ticks at the beginning and end
cbar.TickLabels = {'Beg.\newlineof life', 'End\newlineof life'}; % Label the lower and upper limits
cbar.FontSize = 12;

ax = gca;
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.07))
set(gcf,'renderer','Painters')
%%
plt_name = "profit_vs_lambda_LS";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));
fig1.PaperSize = fig1.PaperPosition(3:4);
print(fig1, fullfile(plot_folder, plt_name + ".pdf"), '-dpdf');


%% Gradient descent: 
clc;
c_investment = 250*192/0.2; 

N_t = length(Qtot_avg);


l_cyc = zeros(1,N_t+1); 
l_cal = zeros(1,N_t+1); 
l_con = zeros(1,N_t+1); % constrant term. 

error = zeros(1,N_t);

% P = 1000000000000*eye(3); % Large-valued identity matrix for initialization
% forget_factor = 0.95;
% beta = 0.1; % regularisation parameter. 
% 
% for i = 1:10%N_t
%     theta = [l_cyc(i); l_cal(i); l_con(i)];
%     x = c_investment*[Qcyc_avg(i); Qcal_avg(i); 1];
% 
%     prediction = theta' * x;
% 
%     error = revenue_sum(i) - prediction + beta * norm(theta,2)^2;
% 
%     % Kalman Gain
%     K = (forget_factor*P*x) / (1 + x'*forget_factor*P*x + beta);
% 
%     fprintf('i = %3d, error = %4.4f, l_cyc %4.4f,  l_cal = %4.4f, l_con = %4.4f\n',i, error, l_cyc(i), l_cal(i), l_con(i));
% 
%     % Update theta (coefficients)
%     theta = theta + K*error;
% 
%     l_cyc(i+1) = theta(1); %max(,0);
%     l_cal(i+1) = theta(2); %max(0, theta(2));
%     l_con(i+1) = theta(3); %min(0, );
% 
%     % Update P
%     P = forget_factor*(P - K*x'*P + beta*eye(3));
% end


P = 1000000000000*eye(2); % Large-valued identity matrix for initialization
forget_factor = 0.95;

for i = 1:10%N_t
    theta = [l_cyc(i); l_con(i)];
    x = c_investment*[Qtot_avg(i); 1];

    prediction = theta' * x;

    error = revenue_sum(i) - prediction;

    % Kalman Gain
    K = (forget_factor*P*x) / (1 + x'*forget_factor*P*x);

    fprintf('i = %3d, error = %4.4f, l_cyc %4.4f,  l_cal = %4.4f, l_con = %4.4f\n',i, error, l_cyc(i), l_cal(i), l_con(i));

    % Update theta (coefficients)
    theta = theta + K*error;

    l_cyc(i+1) = max(0, theta(1)); %max(,0);
    l_cal(i+1) = max(0, theta(1)); %max(0, theta(2));
    l_con(i+1) = min(0,theta(2)); %min(0, );

    % Update P
    P = forget_factor*(P - K*x'*P);
end


%% price -> std -> revenue/Q




