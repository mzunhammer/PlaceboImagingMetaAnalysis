function add_legend_to_image(image,negative_only)
    img=imread(image);
    out_legend=color_legend_render(size(img,1)/2,size(img,2),negative_only);
    img=[img;out_legend];
    imshow(img);
    [p,file,ext]=fileparts(image);
    imwrite(img, fullfile(p,[file,'_w_legend',ext]), 'Format', 'png'); 
end