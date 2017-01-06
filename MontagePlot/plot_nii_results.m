function plot_nii_results(template_img,varargin)
% Created by Matthias Zunhammer November 2016
% Function to plot a nifti image with optional overlays in a slice-wise
% fashion.
% General form: plot_nii_results(template_img,varargin)
%
% 'template_img': a .nii image to plot, required.
%
% Optional arguments:
% 'overlays': a cell-array with n .nii image paths to overlay on top of
%                template_img, e.g. {pain_increase.nii,pain_decrease.nii}.
%             Default: no overlay.
% 'ov_color': a nx1 cell array of colormaps (e.g.  {gray(128),cool(128)}).
%             Default: matlab colors
% 'ov_transparency': a nx1 numberical array of values between 0 and 1 denoting the desired alpha value for each overlay.
%             Default: matlab colors
% 'slices': a kx1 array with MNI-coordinates (x,y,or z) to plot relative to the image origin
%           (from the SPM header): e.g. [-30 -15 0 15 30].
%           Default: [-30 -15 0 15 30]
% 'slice_ori': a single integer or kx1 array indicating spatial dimension (orienation) for all images/each slice.
%                    x=1, y=2, z=3
%                    >> e.g. 1 for all (Para-)SAGGITAL slices
%                            2 for all CORONAL slices
%                            [3 3 3 3 3] for 5 AXIAL slices (5 'slices' required)
%                            [1 1 2 2 3] for 2 SAGGITAL, 2 CORONAL, and 1
%                            AXIAL slices (5 'slices' required)
%                    Default: ALL SAGITAL
% 'background': Integer or logical indicating if background (must be nans
% or zeros from template should be shown. 0: remove, 1: show.
% 'resolution': an integer defining the isometric voxel size. By default this
%               will be the size of the template img.
% 'figure_size': a numeric vector defining the figure size in widthxheigth (in cm).
% 'outfilename': a string of chars defining the desired name of the outfile.
%
%Example:

close all

%% Parse optional inputs according to: https://de.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
p = inputParser

%iptsetpref('ImshowBorder','tight'); % Set Imshow Border to tight, otherwise there will be excess space around images
 
addRequired(p,'template_img',@ischar);
%Check overlays
defaultOverlays = 'none';
addParameter(p,'overlays',defaultOverlays,@iscell)
%Check ov_color
defaultColor = {gray(128)};
addParameter(p,'ov_color',defaultColor,@iscell)
%Check slices
defaultSlices = [-30 -15 0 15 30];
addParameter(p,'slices',defaultSlices,@isnumeric)
%Check slice_ori
defaultSlice_ori = ones(size(defaultSlices));
addParameter(p,'slice_ori',defaultSlice_ori,@isnumeric)
%Check resolution
defaultResolution=-1; % Negative number will later be replaced by no change in resolution
addParameter(p,'resolution',defaultResolution,@isnumeric)
%Check figure_size
defaultfigure_size=[6 6]; % Negative number will later be replaced by no change in resolution
addParameter(p,'figure_size',defaultfigure_size,@isnumeric)
%Check outfilename
defaultOutfilename='montage'; % Negative number will later be replaced by no change in resolution
addParameter(p,'outfilename',defaultOutfilename,@ischar)
%Check background
defaultBackground=1; % default is show background
addParameter(p,'background',defaultBackground,@isnumeric)
%Check overlay transparency
defaultOv_transparency=1; % default is show background
addParameter(p,'ov_transparency',defaultOv_transparency,@isnumeric)

parse(p,template_img,varargin{:})

%% Write input feedback to console
disp('Print Image:')
disp(p.Results.template_img)
disp('With overlay:')
disp(p.Results.overlays)
disp('With overlay colors:')
disp(p.Results.ov_color)
disp('With overlay slices:')
disp(p.Results.slices)
disp('With overlay slice orientation:')
disp(p.Results.slice_ori)
disp('With resolution:')
disp(p.Results.resolution)

%% Preprocess input
n_slices=length(p.Results.slices);

% Expand lazy slice_ori input
slice_ori=p.Results.slice_ori;
if length(slice_ori)==1
slice_ori=ones(size(p.Results.slices))*slice_ori;
end

% Reslice overlays to template, saving and re-loading overlays in the temporary file overlay*n*.nii
if ~strcmp(p.Results.overlays,'none')
    resample_overlay_to_template(template_img,p.Results.overlays)
end

% Set subplot-layout
if n_slices<=3
    m=n_slices;
    n=1;
else
    m=3;
    n=ceil(n_slices/m); 
end

%% Load template
template_hdr=spm_vol(p.Results.template_img);
template_img=spm_read_vols(template_hdr);
%% Load and scale overlays
if ~strcmp(p.Results.overlays,'none')
    overlays=dir(fullfile('overlay*.nii'));
    overlays={overlays.name};
    n_overlays=length(p.Results.overlays);
    for i=1:n_overlays
        overlay_hdr{i}=spm_vol(overlays{i});
        overlay_img{i}=spm_read_vols(overlay_hdr{i});
        min_signal(i)=min(overlay_img{i}(:));
        max_signal(i)=max(overlay_img{i}(:));
%         if min_signal<0 % if the image contains positive and negative Data keep the data scaled as is to keep the 0 meaningful
%             elseif min_signal>=0 % if all values are larger 0, apply max-min-scaling
%             overlay_img{i}=overlay_img{i}./(max_signal(i)-min_signal(i));
%         end
    end
end

%% Convert MNI coordinates to matrix coordinates
%(this is adapted from http://www.alivelearn.net/?p=1434 but could be simplified)
p.Results.slices
slicematrix=zeros(n_slices,4);
slicematrix(:,4)=1;
for i=1:n_slices
    c_ori=slice_ori(i);
    slicematrix(i,c_ori)=p.Results.slices(i);
    coords=inv(template_hdr.mat)*slicematrix(i,:)';
    mat_slices(i)=coords(c_ori);
end
%% Print each slice with overlay
% A tutorial on overlays is provided here: https://de.mathworks.com/company/newsletters/articles/image-overlay-using-transparency.html
for s=1:length(mat_slices)
    figure
    %Select current slice from origin in template.mat
    curr_slice_mat=round(mat_slices(s));
    %Select current orientation
    curr_slice_ori=slice_ori(s);
     % ANALYZE FORMAT in y and z planes HAVE TO BE L-R-FLIPPED! SEE: spm_flip_analyze_images
     % IN ADDITION a 270? tilt is necessary
     if curr_slice_ori==1
        curr_tmp=squeeze(template_img(curr_slice_mat,:,:));
         curr_tmp=mat2gray(rot90(curr_tmp,1)); %here, no left & right, only a 90? tilt is necessary and standardize to gray
     elseif curr_slice_ori==2
        curr_tmp=squeeze(template_img(:,curr_slice_mat,:));
        curr_tmp=mat2gray(rot90(fliplr(curr_tmp),3)); %flip left right and 270? tilt is necessary and standardize to gray
     elseif curr_slice_ori==3
        curr_tmp=squeeze(template_img(:,:,curr_slice_mat));
        curr_tmp=mat2gray(rot90(fliplr(curr_tmp),3)); %flip left right and 270? tilt is necessary and standardize to gray
     end

     
    %colormap gray
    %a=imagesc(curr_tmp,...
    %    'AlphaData',1); %No transparency for template
    %mintempsignal=min(min(min(curr_tmp)));
    %mintempsignal=prctile(curr_tmp(:),[2]);
    empty=curr_tmp==0|isnan(curr_tmp);%|curr_tmp<=mintempsignal
    empty=imresize(empty,5,'method','lanczos3','Antialiasing',false);
    if p.Results.background==0
        empty=zeros(size(empty));
    end
    curr_tmp=imresize(curr_tmp,5,'method','lanczos3','Antialiasing',false);
    curr_tmp=cat(3,curr_tmp,curr_tmp,curr_tmp); % Convert matrix to true-color or all type of random sht will happen...
    t=imshow(curr_tmp);
    set(t,'AlphaData',double(~empty)); %Hide all 0 background
    %Plot overlays, if present
 
    if ~strcmp(p.Results.overlays,'none')

        for i=1:n_overlays
            hold on
            if curr_slice_ori==1
                curr_ovl=squeeze(overlay_img{i}(curr_slice_mat,:,:));
                curr_ovl=rot90(curr_ovl,1); %flip left right and 270? tilt is necessary
            elseif curr_slice_ori==2
                curr_ovl=squeeze(overlay_img{i}(:,curr_slice_mat,:));
                curr_ovl=rot90(fliplr(curr_ovl),3); %flip left right and 270? tilt is necessary
            elseif curr_slice_ori==3
                curr_ovl=squeeze(overlay_img{i}(:,:,curr_slice_mat));
                curr_ovl=rot90(fliplr(curr_ovl),3); %flip left right and 270? tilt is necessary
            end
            
            % ANALYZE FORMAT IMAGES HAVE TO BE L-R-FLIPPED! SEE: spm_flip_analyze_images
            % IN ADDITION a 270? tilt is necessary
            
            %o=imshow(curr_ovl); % Create handle for overlay
            empty_ovl1=curr_ovl==0|isnan(curr_ovl);
            curr_ovl=imresize(curr_ovl,5,'method','lanczos3');
            empty_ovl1=imresize(empty_ovl1,5,'method','lanczos3');
            curr_ovl_col=p.Results.ov_color{i};
            curr_ovl_3d=ind2rgb(gray2ind(curr_ovl),curr_ovl_col); % Convert matrix to true-color or all type of random sht will happen...
            o(i)=imshow(curr_ovl_3d);
            set(o(i),'AlphaData',double(~empty_ovl1)*p.Results.ov_transparency);
            
            %           Encode overlay signal as opacity (transparency)
%           Create solid image desired color for overlay
%           color = cat(3, ones(size(curr_ovl)).*curr_ovl_col(1),... %r
%                        ones(size(curr_ovl)).*curr_ovl_col(2),... %g
%                        ones(size(curr_ovl)).*curr_ovl_col(3));     %b
%           solid=imshow(color);
%           set(solid,'AlphaData',curr_ovl); %apply overlay to solid as an "influence map"
        end
    end
    hold off
%Print slice

result_img{s}=getimage(gcf);
set(gca,'position',[0 0 1 1],'units','normalized');
%set(gcf,'PaperPosition',[0 0 p.Results.figure_size]);%set desired size of image. Must be the same for image and scale, otherwise the montage function will not work.
print([p.Results.outfilename,'_slice_',num2str(s)],gcf,'-dtiff');
end

%% Plot Scales as additional image
 %Create image matrix for scale (maximal dimension of last image as height)
 l_scale=length(result_img{1});
 w_scale=round(l_scale/6*n_overlays);
 scale=[];
 for i=1:n_overlays
     %scaleslice= ([0:l_scale]-min_signal(i))./max_signal(i);
     scale_mat=repmat([0:1/l_scale:1]',1,w_scale);
     s=ind2rgb(gray2ind(scale_mat),p.Results.ov_color{i});% Actual scale
     sspacer=zeros(size(s,1),round(size(s,2)/2),size(s,3));  % Spacer to next scale
     scale{i}=[sspacer,... % Spacer to next scale 
                rot90(rot90(s))];     %actual scale
 end
fullscale= [scale{:}];
figure
sc=imshow(fullscale);
empty=rgb2gray(fullscale)>0;
set(sc,'AlphaData',double(empty)*p.Results.ov_transparency);

%annotate scale
for i=1:n_overlays
text(w_scale*i+(w_scale/2*(i-1))-w_scale/2,l_scale-l_scale/20,num2str(min_signal(i)),'FontSize',l_scale/20)
text(w_scale*i+(w_scale/2*(i-1))-w_scale/2,l_scale/20,num2str(max_signal(i)),'FontSize',l_scale/20) %w_scale*i*1.25-w_scale/1.5
%annotation('textbox',[.5 .1 .2 .1],'String','123','FitBoxToText','on')
end
%set(gcf,'PaperPosition',[0 0 p.Results.figure_size]);%set desired size of image. Must be the same for image and scale, otherwise the montage function will not work.
print([p.Results.outfilename,'_scale'],gcf,'-dtiff');

%% Load single images, put in montage, delete single images
%Currently not working due to transition from MATLAB 2015a to 2016b
%Scale is now printed in a smaller size than previously
%slice_files=dir(fullfile('slice*.tif'));
%scale_file=dir(fullfile('scale.tif'));

%montage({slice_files.name,scale_file.name}','Size',[m,n+1]);
%print(p.Results.outfilename,gcf,'-dtiff');
%delete(slice_files.name);% Remove single files for they make problems
