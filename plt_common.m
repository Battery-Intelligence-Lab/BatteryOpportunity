% Common settings for plot
text_font = 12;
lw = {'LineWidth',1.3};
lw2 = {'LineWidth',1.5};

golden_ratio = 1.618;
x0 = 1;
y0 = 1;
plot_folder = "plots";

width_  = 3.5; % 3.5 inch / 9 cm 
height_ = width_/golden_ratio;

Enom = 192; % 192 kWhcap
price_per_cap = 250; 
EOL = 0.8;
cost_whole = Enom*price_per_cap/(1-EOL);

