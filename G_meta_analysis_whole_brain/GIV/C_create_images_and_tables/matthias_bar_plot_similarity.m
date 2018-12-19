function matthias_bar_plot_similarity(values,SE_values,wedgenames,varargin)
hold on
% Flip negative values (direction of effect is color-coded below)
posvalues=values>0;
values(~posvalues)=values(~posvalues)*-1;
a=barh(1:length(values),values,'FaceColor','flat')
errorbar(values,1:length(values),SE_values,'horizontal',...
    'LineStyle','none',...
    'Color',[0, 0, 0])
hold off
set(gca,'YTick',1:length(values));
%set(gca,'XTickLabelRotation',45);
% Color-code direction of effect
a.CData(posvalues,:) = ones(size(a.CData(posvalues,:))).*[1 .4 .4];
a.CData(~posvalues,:) = ones(size(a.CData(~posvalues,:))).*[.4 .4 1];
%Set ticklabels
yticklabels(wedgenames)
b=gca;b.XLim(1)=0; %clip to 0 to ease figure arrangement
end