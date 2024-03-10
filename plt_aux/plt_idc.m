function plt_idc(idc)
plt_common;
fig1=figure('Units','inches',...
'Position',[x0 y0 (x0+width_) (y0+height_)],...
'PaperPositionMode','auto');

N_price = 367*24*4; % #TODO I repeated some prices accidentally. 

price_mat = reshape(idc(1:N_price),[],367);

[X_price,Y_price] = meshgrid(0:0.25:(24-0.25),1:367);

ax = surf(X_price', Y_price', price_mat);

colormap('parula')
%colormap(cmocean('solar'))
shading interp
end