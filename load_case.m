function cs = load_case(folder, study_name)

path = fullfile(folder, study_name + "_*.mat");
dirs = dir(path);

cs = [];
for i=1:length(dirs)
    cs = [cs, load(fullfile(folder, study_name + "_"+num2str(i-1) + "_.mat"))];
end

end