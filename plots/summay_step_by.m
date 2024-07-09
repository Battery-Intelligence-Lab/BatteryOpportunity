% This file step by step plots the summary figure. 

clear variables; close all; clc; 

open('summary.fig');
f = gcf;

% For replotting
i_sum = 1;  % sequence of the summary
plt_name = "summary_";
plt_folder = "summaryPlots";

gif_name = "summary.gif";
gif_delay = 1; % 1 second delay between animations

%%

% This function gets heavy, moderate light use EOL and optimal usage lines.
[heavy, moder, light, EOL, opt] = getLines(f);

% heavy -> heavy usage 
% heavy.use -> top plot SOH vs time. 
% heavy.use.text -> text of the top plot
% heavy.use.line -> line of the top plot 

% opt.rev.star  -> the blue star
% opt.rev.arrow -> arrow annotation

% Start by removing everything
showLines(heavy,'off'); % Function to recursively make on/off visibility. 
showLines(moder,'off'); % Function to recursively make on/off visibility. 
showLines(light,'off'); % Function to recursively make on/off visibility. 
showLines(EOL,'off'); % Function to recursively make on/off visibility. 
showLines(opt,'off'); % Function to recursively make on/off visibility. 

saveAll(f, plt_name + i_sum, plt_folder); i_sum = i_sum + 1; % Save the empty figure. 
exportGIF(f, gif_name,'overwrite', gif_delay);
% First show heavy usage: 
%%
showLines(heavy,'on'); % Make heavy use on
saveAll(f, plt_name + i_sum, plt_folder); i_sum = i_sum + 1;
exportGIF(f, gif_name,'append', gif_delay);

showLines(light,'on'); % Make heavy use on
saveAll(f, plt_name + i_sum, plt_folder); i_sum = i_sum + 1;
exportGIF(f, gif_name,'append', gif_delay);

showLines(moder,'on'); % Make heavy use on
saveAll(f, plt_name + i_sum, plt_folder); i_sum = i_sum + 1;
exportGIF(f, gif_name,'append', gif_delay);

showLines(EOL,'on'); % Make EOL interpolation on
saveAll(f, plt_name + i_sum, plt_folder); i_sum = i_sum + 1;
exportGIF(f, gif_name,'append', gif_delay);


showLines(opt,'on'); % Function to recursively make on/off visibility. 
saveAll(f, plt_name + i_sum, plt_folder); i_sum = i_sum + 1;
exportGIF(f, gif_name,'append', gif_delay + 2);

%% Alternatively we could also make individually on or off 
% showLines(opt.rev.arrow, 'on'); % -> just to switch on arrow annotation. 
% sohwLines(heavy.use, 'on');     % -> just make the usage figure on. 



function [] = exportGIF(f, name, WriteMode, DelayTime)
frame = getframe(f);
im = frame2im(frame);
[imind,cmf] = rgb2ind(im,256);
if(strcmpi(WriteMode,'overwrite'))
    imwrite(imind, cmf, name,'gif','WriteMode', WriteMode, 'DelayTime', DelayTime, "LoopCount", Inf);
else
    imwrite(imind, cmf, name,'gif','WriteMode', WriteMode, 'DelayTime', DelayTime);
end
end












