clear variables; close all; clc;
addpath('plt_aux'); 


folder = 'results/sensitivity_2023_09_13_real';

idc = readmatrix('data/idc_positive_dummy.csv')';

% load cal lambda sensitivity
cal = process_and_verify(load_case(folder, "lambda_cal"));

% load cyc lambda sensitivity
cyc = process_and_verify(load_case(folder, "lambda_cyc"));

% load both lambda sensitivity  
both = process_and_verify(load_case(folder, "both"));

% Settings:
plt_common;

%% Plot idc:
%plt_idc(idc);

%% Revenue by lambda cyc/cal (after revision)
%close all;
%plt_rev_by_lambda(cal, cyc, both);

%% NEW FIGURE best profit vs. interest rate.    
close all;
%plt_profit_vs_interest(cal, cyc, both);
%plt_profit_vs_interest_daily(cal, cyc, both);
%plt_profit_vs_interest_interpolated(cal,cyc,both);
plt_lambdaExp_vs_interest_interpolated(cal,cyc,both);

%% New figure: optimal lambda 

plt_interest_vs_optimal_lambda(cal, cyc, both);

%% NEW FIGURE best profit vs. interest rate. -> LOG version
%close all;
%plt_profit_vs_interest_log(cal, cyc, both);

%% FEC and lifetime. 
%plt_FEC_life_vs_lambda(cal, cyc, both);

%% Dave figure (after revision) 
%close all;
%plt_summary(cal, cyc, both);


%% Revenue/ageing/cost_whole:
%plt_lambda_exp(cal,cyc,both);


%% Qlos_cal  Qlos_cyc 
%close all;
%plt_cal_cyc_portions(cal, cyc, both);
