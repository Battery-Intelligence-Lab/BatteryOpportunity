function out = process_and_verify(caseNow)

allCases = [];

CC =  0.05; % Yearly interest. 

CC_list = 0:0.01:0.30;

for i=1:length(caseNow)
    EOL = caseNow(i).settings.EOL;
    dth = caseNow(i).settings.dt;
    dtd = 24/dth;
    dty = 365*dtd;
    c_investment = double(caseNow(i).settings.price_kWhcap)*double(caseNow(i).settings.Enom);
    cost_whole = c_investment/(1-EOL);

    caseNow(i).SOH = 1 - [0, cumsum(caseNow(i).Qloss)];
    caseNow(i).time_h = (0:length(caseNow(i).SOH)-1)*dth;
    caseNow(i).time_d = caseNow(i).time_h/24;
    caseNow(i).time_y = caseNow(i).time_d/365;
    caseNow(i).N_year = ceil(caseNow(i).time_y(end)); % total years to consider for NPV 
    caseNow(i).N_day  = ceil(caseNow(i).time_d(end)); % total days to consider for NPV 
    
    caseNow(i).NPV_indices = [1:dty:length(caseNow(i).time_y), length(caseNow(i).time_y)];  % for years 0, 1, 2, ... value of last day.
    caseNow(i).NPV_indices_daily = [1:dtd:length(caseNow(i).time_d), length(caseNow(i).time_d)];  % for years 0, 1, 2, ... value of last day.

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

    caseNow(i).yearly_profit = zeros(1,caseNow(i).N_year+1);
    caseNow(i).profit_years      = 1:caseNow(i).N_year+1;
    caseNow(i).profit_years(end) = caseNow(i).time_y(end);

    for i_NPV = 1:caseNow(i).N_year
        i_before = caseNow(i).NPV_indices(i_NPV);
        i_after  = caseNow(i).NPV_indices(i_NPV+1);
        profit_i = diff(caseNow(i).cumulative_revenue([i_before, i_after]));
        
        profit_sum = profit_sum + profit_i/(1 + CC)^i_NPV;
        caseNow(i).yearly_profit(i_NPV+1) = profit_sum;
        caseNow(i).profit_years(i_NPV) = i_NPV-1;
    end

    caseNow(i).NPV = profit_sum;
    caseNow(i).PI  = caseNow(i).NPV / c_investment;
    caseNow(i).CC  = CC;

    allCases.NPV(i)= caseNow(i).NPV;
    allCases.PI(i) = caseNow(i).PI;

    % List of interests, just for after revision work, not to modify above
    % I am creating a new for loop. 
    allCases.CC_list = CC_list;
    caseNow(i).CC_list = CC_list;

    profit_per = diff(caseNow(i).cumulative_revenue(caseNow(i).NPV_indices))';
    discounted_mat = profit_per./((1 + CC_list).^((1:caseNow(i).N_year)'));
    caseNow(i).NPV_list = sum(discounted_mat);
    caseNow(i).PI_list  = caseNow(i).NPV_list / c_investment;

    allCases.NPV_list(i,:) = caseNow(i).NPV_list;
    allCases.PI_list(i,:)  = caseNow(i).PI_list;   

    SOH_per = -diff(caseNow(i).SOH(caseNow(i).NPV_indices))';
    
    allCases.LambdaExp_list(i,:) = sum(discounted_mat.*SOH_per/mean(SOH_per)/c_investment);

    % This is for daily interest thing. 
    allCases.CC_list_daily = (1 + CC_list).^(1/365)-1;
    caseNow(i).CC_list_daily = allCases.CC_list_daily;

    for i_CC = 1:length(allCases.CC_list_daily)
        CC_now = allCases.CC_list_daily(i_CC);
        profit_sum = 0;

        for i_NPV = 1:caseNow(i).N_day
            i_before = caseNow(i).NPV_indices_daily(i_NPV);
            i_after  = caseNow(i).NPV_indices_daily(i_NPV+1);
            profit_i = diff(caseNow(i).cumulative_revenue([i_before, i_after]));

            profit_sum = profit_sum + profit_i/(1 + CC_now)^i_NPV;
        end

        caseNow(i).NPV_list_daily(i_CC) = profit_sum;
        caseNow(i).PI_list_daily(i_CC)  = profit_sum / c_investment;

    end

    allCases.NPV_list_daily(i,:) = caseNow(i).NPV_list_daily;
    allCases.PI_list_daily(i,:)  = caseNow(i).PI_list_daily;   
    
    
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

out.now = caseNow;
out.all = allCases;

end