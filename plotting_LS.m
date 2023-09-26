clear variables; close all; clc;

folder_mean = 'C:/D/OneDrive - Nexus365/Proj/BatteryOpportunityCost/results/mean_window_2023_09_26';

folder_sensitivity = 'results/sensitivity_2023_09_13_real';
folder = 'C:\D\OneDrive - Nexus365\Proj\BatteryOpportunityCost\results\ls_window_2023_09_25';

idc = readmatrix('data/idc_positive_dummy.csv')';

study_name = "ls_window";

% load both lambda sensitivity  
now_mean = load_case(folder_mean, "mean_window");
[now_mean, all_mean] = process_and_verify(now_mean);

% load both lambda sensitivity  
now_geo = load_case(folder_mean, "geo_mean_window");
[now_geo, all_geo] = process_and_verify(now_geo);

% load both lambda sensitivity  
now_both = load_case(folder_sensitivity, "both");
[now_both, all_both] = process_and_verify(now_both);

path = fullfile(folder, study_name + "_*.mat");
dirs = dir(path);
now_mix = cell(1,length(dirs));
for i=0:length(dirs)-1
    fprintf('File %d is being loaded.\n',i);
    now_mix{i+1} = load(fullfile(dirs(i+1).folder, study_name + "_" + num2str(i) + "_.mat" ));

    [now_mix{i+1}, ~] = process_and_verify(now_mix{i+1});
end

% Settings:
text_font = 12;
lw = {'LineWidth',1.3};
lw2 = {'LineWidth',1.5};

golden_ratio = 1.618;
x0 = 1;
y0 = 1;
plot_folder = "plots";

%
folder_mppt = 'results/mppt_lambda_2023_09_18';

now_mppt = load_case(folder_mppt, "mppt");
[now_mppt, all_mppt] = process_and_verify(now_mppt);


%%

figure; 
plot(all_both.lambda_cal, all_both.revenue_at_EOL); hold on; 
% yline(now_mix{1}.cumulative_revenue(end), 'r--', lw2{:})
% yline(now_mix{2}.cumulative_revenue(end), 'b--', lw2{:})
% yline(now_mix{3}.cumulative_revenue(end), 'g--', lw2{:})
% yline(now_mix{4}.cumulative_revenue(end), 'c--.', lw2{:})
% yline(now_mix{5}.cumulative_revenue(end), 'k--.', lw2{:})

yline(now_mppt(1).cumulative_revenue(end), 'r:', lw2{:})
yline(now_mppt(2).cumulative_revenue(end), 'b:', lw2{:})

yline(now_mean(1).cumulative_revenue(end), 'r-.', lw2{:})
yline(now_mean(2).cumulative_revenue(end), 'b-.', lw2{:})
yline(now_mean(3).cumulative_revenue(end), 'g-.', lw2{:})
yline(now_mean(4).cumulative_revenue(end), 'c-.', lw2{:})
yline(now_mean(5).cumulative_revenue(end), 'k-.', lw2{:})

yline(now_geo(1).cumulative_revenue(end), 'r--', lw2{:})
yline(now_geo(2).cumulative_revenue(end), 'b--', lw2{:})
yline(now_geo(3).cumulative_revenue(end), 'g--', lw2{:})
yline(now_geo(4).cumulative_revenue(end), 'c--', lw2{:})
yline(now_geo(5).cumulative_revenue(end), 'k--', lw2{:})

%yline(now_geo(1).cumulative_revenue(end), 'r-.', lw2{:})


xlabel('lambda')
ylabel('Profit at EOL (EUR)')

grid on; 

legend('Parameter sweep',... %'Least-squares 1 week window', 'Least squares 15-day window', 'Least squares 1-month window', ... %'Least squares 2-month window', 'Least squares 3-month window', ...   
      'MPPT without volality', 'MPPT with volatility', ...
      'Mean-1week', 'Mean-2week', 'Mean-1mo', 'Mean-2mo', 'Mean-3mo',...
      'Geo-1week', 'Geo-2week', 'Geo-1mo', 'Geo-2mo', 'Geo-3mo')




