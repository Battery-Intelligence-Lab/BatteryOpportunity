function cs = load_case(folder, study_name)

path = fullfile(folder, study_name + "_*.mat");
dirs = dir(path);

cs = [];
for i=1:length(dirs)
    cs = [cs, load(fullfile(dirs(i).folder, dirs(i).name))];
end

% We need to sort by lambdas
if(study_name=="lambda_cal")    
    lambdas = arrayfun(@(x) double(x.settings.lambda_cal), cs);
    [~, order] = sort(lambdas);
    cs = cs(order);
else
    lambdas = arrayfun(@(x) double(x.settings.lambda_cyc), cs);
    [~, order] = sort(lambdas);
    cs = cs(order);
end

end