function [] = saveAll(f,plt_name, plot_folder)
print(f, fullfile(plot_folder, plt_name + ".png"), '-dpng','-r800');
print(f, fullfile(plot_folder, plt_name + ".eps"), '-depsc');
savefig(f, fullfile(plot_folder, plt_name + ".fig"));
f.PaperSize = f.PaperPosition(3:4);
print(f, fullfile(plot_folder, plt_name + ".pdf"), '-dpdf');
end