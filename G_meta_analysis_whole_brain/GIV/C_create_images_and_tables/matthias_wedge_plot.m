function hh=matthias_wedge_plot(values,SE_values,wedgenames,varargin)
% change label of outcome metric if not Hedge's g
if any(strcmp(varargin,'metric'))
    metric=varargin{find(strcmp(varargin,'metric'))+1};
else
    metric='g';
end

if any(strcmp(varargin,'nolabels'))
    wedgenames=repmat({''},size(wedgenames,1),size(wedgenames,1));
end
% set up vaules and SE's for tor_wedge_plot
toplot=double([values+SE_values...
        values...
        values-SE_values]);

% Set outer circle radius according to maximum absuloute value+se
max_val=max(abs(toplot(:)));
if max_val>0.3
    outer_circle_radius=ceil(max_val*2)/2;
elseif max_val>0.1
    outer_circle_radius=ceil(max_val*10)/10;
elseif max_val>0.01
    outer_circle_radius=ceil(max_val*100)/100;
else
    outer_circle_radius=ceil(max_val*1000)/1000;
end

hh=tor_wedge_plot(toplot',...
                  wedgenames,...
           'outer_circle_radius', outer_circle_radius,...
           'bicolor',...
           'nofigure',...
           'colors',[{[1 0 0] [0 0 1]}']);

% Add outer circle label       
radius_label=sprintf([metric,' = %0.2g'],outer_circle_radius);
xmid_outside = 0 + (outer_circle_radius + .2*outer_circle_radius) * cos(0);
ymid_outside = 0 + (outer_circle_radius + .2*outer_circle_radius) * sin(0);
text(xmid_outside, ymid_outside, radius_label,...
     'FontSize', get(hh.outer(1).texth,'FontSize'),...
     'HorizontalAlignment','center','parent',gca, 'Layer','front');

       
% Add more margin so text labels don't get cut-off
old_pos=get(gcf,'Position');
new_pos=round(old_pos.*[1,1,1.5,1.8]);
set(gcf,'Position',new_pos)

%Todo: Load and add symbolic images for buckner
% img_files=dir('./buckner_7_networks_surface_figures/slice_icons/*.tiff');
% if all(wedgenames)
%     for i=1:length(wedgenames)
%         currpos=hh.outer(i).texth.Position;
%         %axes('pos',[currpos(1:2) .5 .3]);
%         h=imshow(fullfile(img_files(i).folder,img_files(i).name));
%         %uistack(h,'bottom')
%     end
% end
end