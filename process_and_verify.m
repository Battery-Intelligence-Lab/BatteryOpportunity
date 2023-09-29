function [caseNow, allCases] = process_and_verify(caseNow)

allCases = [];

CC =  0.05; % Yearly interest. 


for i=1:length(caseNow)
    EOL = caseNow(i).settings.EOL;
    dth = caseNow(i).settings.dt;
    c_investment = double(caseNow(i).settings.price_kWhcap)*double(caseNow(i).settings.Enom);
    cost_whole = c_investment/(1-EOL);

    caseNow(i).SOH = 1 - [0, cumsum(caseNow(i).Qloss)];
    caseNow(i).time_h = (0:length(caseNow(i).SOH)-1)*dth;
    caseNow(i).time_d = caseNow(i).time_h/24;
    caseNow(i).time_y = caseNow(i).time_d/365;
    caseNow(i).N_year = ceil(caseNow(i).time_y(end)); % total years to consider for NPV 
    
    [~, year_indices] = min(abs(caseNow(i).time_y' - (1:floor(caseNow(i).time_y(end)))));


    caseNow(i).NPV_indices = [1, year_indices, length(caseNow(i).time_y)]; % for years 0, 1, 2, ... value of last day.
    
    caseNow(i).cumulative_revenue = [0, cumsum(caseNow(i).revenue)];
    

    allCases.lifetime_y(i)         = caseNow(i).time_y(end);
    allCases.lambda_cyc(i)         = caseNow(i).settings.lambda_cyc;
    allCases.lambda_cal(i)         = caseNow(i).settings.lambda_cal;
    allCases.revenue_at_EOL(i)     = caseNow(i).cumulative_revenue(end); % PS: not exactly 80%
    allCases.FEC_at_EOL(i)         = sum(caseNow(i).dFEC);
    allCases.Qloss_cal_at_EOL(i)   = sum(caseNow(i).Qloss_cal);
    allCases.Qloss_cyc_at_EOL(i)   = sum(caseNow(i).Qloss_cyc);

    allCases.lambda_approx(i)      = allCases.revenue_at_EOL(i)/cost_whole/(1-EOL);

    profit_sum = 0;
    lambda_sum = 0;
    
    for i_NPV = 1:caseNow(i).N_year
        i_before = caseNow(i).NPV_indices(i_NPV);
        i_after  = caseNow(i).NPV_indices(i_NPV+1);
        profit_i = diff(caseNow(i).cumulative_revenue([i_before, i_after]));
        
        profit_sum = profit_sum + profit_i/(1 + CC)^i_NPV;
        
    end

    caseNow(i).NPV = profit_sum;
    caseNow(i).PI  = caseNow(i).NPV / c_investment;
    caseNow(i).CC  = CC;

    allCases.NPV(i)                = caseNow(i).NPV;
    allCases.PI(i)                 = caseNow(i).PI;

    
    
    % Verify cases:
    true_Qloss_cyc_dc = caseNow(i).dFEC*caseNow(i).settings.Qloss_cyc_dc;
    fprintf('Norm of error of %d-th case Qloss_cyc_dc is %4.10f\n',i, norm(true_Qloss_cyc_dc - caseNow(i).Qloss_cyc_dc,1))

    true_Qloss_cyc_ch = max(caseNow(i).settings.Qloss_cyc_Ab_ch(:,2) + caseNow(i).settings.Qloss_cyc_Ab_ch(:,1)*caseNow(i).rate_ch,[],1);
    fprintf('Norm of error of %d-th case Qloss_cyc_ch is %4.10f\n',i, norm(true_Qloss_cyc_ch - caseNow(i).Qloss_cyc_ch_per_h,1))

    true_Qloss_cal   = max(caseNow(i).settings.Qloss_cal(:,1) + ...
                           caseNow(i).settings.Qloss_cal(:,2)*caseNow(i).SOCavg + ...
                           caseNow(i).settings.Qloss_cal(:,3)*caseNow(i).Tk_avg,[],1);

    fprintf('Norm of error of %d-th case Qloss_cal    is %4.10f\n',i, norm(true_Qloss_cal - caseNow(i).Qloss_cal_per_h,1))
end


end