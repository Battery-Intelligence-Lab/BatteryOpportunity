clear variables; close all; clc;

folder_sensitivity = 'results/sensitivity_2023_09_13_real';
folder = 'results/ls_window_2023_09_25';

idc = readmatrix('data/idc_positive_dummy.csv')';

study_name = "ls_window";

path = fullfile(folder, study_name + "_*.mat");
dirs = dir(path);

% load both lambda sensitivity  
now_both = load_case(folder_sensitivity, "both");
[now_both, all_both] = process_and_verify(now_both);


now_mix = cell(1,length(dirs));
for i=0:length(dirs)-1
    fprintf('File %d is being loaded.\n',i);
    now_mix{i+1} = load(fullfile(dirs(i+1).folder, study_name + "_" + num2str(i) + "_.mat" ));
end

% Settings:
text_font = 12;
lw = {'LineWidth',1.3};
lw2 = {'LineWidth',1.5};

golden_ratio = 1.618;
x0 = 1;
y0 = 1;
plot_folder = "plots";



figure; 
plot(all_both.lambda_cal, all_both.revenue_at_EOL); hold on; 
yline(now_mppt(1).cumulative_revenue(end), 'r', lw{:})
yline(now_mppt(2).cumulative_revenue(end), 'b', lw{:})



