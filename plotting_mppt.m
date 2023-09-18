clear variables; close all; clc;

folder_sensitivity = 'results/sensitivity_2023_09_13_real';
folder = 'results/mppt_lambda_2023_09_18';

idc = readmatrix('data/idc_positive_dummy.csv')';


% load both lambda sensitivity  
now_both = load_case(folder_sensitivity, "both");
[now_both, all_both] = process_and_verify(now_both);

% Settings:
text_font = 12;
lw = {'LineWidth',1.3};
lw2 = {'LineWidth',1.5};

golden_ratio = 1.618;
x0 = 1;
y0 = 1;

%%
% load cal lambda sensitivity
now_mppt = load_case(folder, "mppt");
[now_mppt, all_mppt] = process_and_verify(now_mppt);


%% Plot for both changes lambda vs EOL revenue: 

figure; 
plot(all_both.lambda_cal, all_both.revenue_at_EOL); hold on; 
yline(now_mppt(1).cumulative_revenue(end), 'r', lw{:})
yline(now_mppt(2).cumulative_revenue(end), 'b', lw{:})

