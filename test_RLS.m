% Test hypothesis of 
% profit  =  a*cyc + b*cal + c    
% for a week time. 

clear variables; close all; clc;

folder = 'results/sensitivity_2023_09_13_real';

idc = readmatrix('data/idc_positive_dummy.csv')';

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

%%
avg_horizon = 24*7; % 1 week of horizon

i_now = find(all_both.lambda_cyc == 1);

caseNow = now_both(i_now);

dt = caseNow.settings.dt; 
N_avg = avg_horizon/dt; 


N_case = length(caseNow.revenue);
N_interest = floor(N_case/N_avg)*N_avg; 

revenue_mat = reshape(caseNow.revenue(1:N_interest),N_avg,[]);
revenue_std = std(revenue_mat);

revenue_sum = sum(reshape(caseNow.revenue(1:N_interest),N_avg,[]));
revenue_sum_normalised = revenue_sum./revenue_std;

Qcal_avg    = sum(reshape(caseNow.Qloss_cal(1:N_interest),N_avg,[]));
Qcyc_avg    = sum(reshape(caseNow.Qloss_cyc(1:N_interest),N_avg,[]));
Qtot_avg    = Qcal_avg  +  Qcyc_avg;

T = table(Qcal_avg', Qcyc_avg', revenue_sum', 'VariableNames', ["Qcal","Qcyc","Revenue"]);

writetable(T, "estimation_example.csv");


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



