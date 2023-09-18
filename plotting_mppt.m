clear variables; close all; clc;

folder_sensitivity = 'results/sensitivity_2023_09_13_real';
folder = 'results/mppt_lambda_2023_09_18';

idc = readmatrix('data/idc_positive_dummy.csv')';

% load cal lambda sensitivity
now_mppt = load_case(folder, "mppt");
[now_mppt, all_mppt] = process_and_verify(now_mppt);


% load both lambda sensitivity  
now_both = load_case(folder_sensitivity, "both");
[now_both, all_both] = process_and_verify(now_both);

%% Plot for both changes lambda vs EOL revenue: 

figure; 
plot(all_both.lambda_cal, all_both.revenue_at_EOL); hold on; 
yline(now_mppt.cumulative_revenue(end))

