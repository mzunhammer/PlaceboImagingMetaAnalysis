function out_legend=color_legend_render(y_size,x_size,neg_only)
% helper function to create legend for rendered images

%get desired label size

figure('Position',[0,0,x_size,y_size]);

gap=0.1;
cur=[0,0];

%set desired labels and colors
lbs={'p_{uncorr} < .001';
     'p_{perm} < .05'};
cons={'negative';
     'positive'};
cols={[0 0 1],[0 1 0];
      [1 0 0],[1 1 0]};

%check if negative only wanted
if neg_only==1
    cons=cons(1);
    cols=cols(1,:);
end

%compose image
for j=1:length(cons)
    for i=1:length(lbs)
        y=(length(lbs)-i);
        x=(j-1)*x_size/y_size;
        pos=[x,y,...
            1-gap,1-gap];
        rectangle('Position',pos,'Curvature',cur,...
                  'FaceColor',cols{j,i},...
                  'LineStyle','none');
        text(x+1,y+0.5-gap,lbs{i},...
           'FontUnits','normalized',...
           'FontSize',0.175)
    end
    text(x,length(lbs)+gap*2,cons{j},...
       'FontUnits','normalized',...
       'FontSize',0.2)
end
axis([0,length(lbs)*x_size/y_size,0,length(lbs)+gap*4])
axis off;

out_legend= print('-RGBImage');
out_legend=imresize(out_legend,'OutputSize',[NaN,x_size]);
close gcf

end 