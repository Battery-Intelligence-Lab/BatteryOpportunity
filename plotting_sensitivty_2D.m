clear variables; close all; clc;

folder = 'C:/D/OneDrive - Nexus365/Proj/BatteryOpportunityCost/results/optimal_lambda_2023_09_17';

idc = readmatrix('data/idc_positive_dummy.csv')';

study_name = "mixed";

path = fullfile(folder, study_name + "_*.mat");
dirs = dir(path);

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

%%

Ncal = 7;
Ncyc = 13;

all_mix.lambda_cal = cellfun(@(x) double(x.settings.lambda_cal), now_mix );
all_mix.lambda_cyc = cellfun(@(x) double(x.settings.lambda_cyc), now_mix );
all_mix.revenue_at_EOL = cellfun(@(x) sum(x.revenue), now_mix );



all_mix.lambda_cal = reshape(all_mix.lambda_cal, Ncal, Ncyc);
all_mix.lambda_cyc = reshape(all_mix.lambda_cyc, Ncal, Ncyc);
all_mix.revenue_at_EOL = reshape(all_mix.revenue_at_EOL, Ncal, Ncyc);


%% Surf plot: 
Enom  = 192;
figure;
surf(all_mix.lambda_cal, all_mix.lambda_cyc, all_mix.revenue_at_EOL/Enom);
xlabel('\lambda-calendar')
ylabel('\lambda-cycle')
zlabel('Revenue at EOL (EUR/kWh_{cap})')
%%
close all;
Enom  = 192;
c_invest = Enom*250;


width  = 3.5; % 3.5 inch / 9 cm 
height = width/golden_ratio;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width) (y0+height)],...
'PaperPositionMode','auto');
imagesc(all_mix.lambda_cal(:,1)', all_mix.lambda_cyc(1,:), all_mix.revenue_at_EOL/Enom); 
%pcolor(all_mix.revenue_at_EOL/Enom)
%[X, Y] = meshgrid()
%shading interp;
colormap("jet");
xlabel('\lambda-{calendar}');
ylabel('\lambda-{cycle}');
c = colorbar;
c.Label.String = ('Revenue at EOL (EUR/kWh_{cap})');
c.Label.FontSize = text_font;
%clim([1100,1700])


set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',text_font,...
'FontName','Times');
set(gca,'LooseInset',max(get(gca,'TightInset'), 0.1))
set(gcf,'renderer','Painters')

plt_name = "sweep_2D";

print(fig1, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(fig1, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(fig1, fullfile(plot_folder, plt_name + ".fig"));

%%

%surf(all_mix.revenue_at_EOL/Enom)