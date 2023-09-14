function [caseNow, allCases] = process_and_verify(caseNow)

allCases = [];
for i=1:length(caseNow)
    dth = caseNow(i).settings.dt;
    caseNow(i).SOH = 1 - [0, cumsum(caseNow(i).Qloss)];
    caseNow(i).time_h = (0:length(caseNow(i).SOH)-1)*dth;
    caseNow(i).time_d = caseNow(i).time_h/24;
    caseNow(i).time_y = caseNow(i).time_d/365;

    caseNow(i).cumulative_revenue = [0, cumsum(caseNow(i).revenue)];
    allCases.lambda_cyc(i) = caseNow(i).settings.lambda_cyc;
    allCases.lambda_cal(i) = caseNow(i).settings.lambda_cal;
    allCases.revenue_at_EOL(i) = caseNow(i).cumulative_revenue(end); % PS: not exactly 80%
    allCases.FEC_at_EOL(i)      = sum(caseNow(i).dFEC

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