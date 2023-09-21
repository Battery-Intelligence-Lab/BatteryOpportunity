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

revenue_avg = sum(reshape(caseNow.revenue(1:N_interest),N_avg,[]));
Qcal_avg    = sum(reshape(caseNow.Qloss_cal(1:N_interest),N_avg,[]));
Qcyc_avg    = sum(reshape(caseNow.Qloss_cyc(1:N_interest),N_avg,[]));
Qtot_avg    = Qcal_avg  +  Qcyc_avg;


