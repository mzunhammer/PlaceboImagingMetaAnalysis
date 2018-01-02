
% Setup: Load df with paths and variables
clear
% Setup: Load df with paths and variables
datapath='../../../Datasets/';
maskpath='../../../pattern_masks/';

tic
outpath='./C_Exploratory_Analyses/A_Check_Image_Alignment/';

load(fullfile(datapath,'AllData.mat'));

studies=unique(df.studyID);
masking_tol=0.00001;

for i=1:length(studies)
currimgs=df.img(strcmp(df.studyID,studies(i)));
infiles=fullfile(datapath,currimgs);
[p,f,ext]=cellfun(@fileparts,infiles,'UniformOutput',0);
outfile=fullfile(['Check_',studies{i},'.nii']);

disp(['Masking ',studies(i)])

%[p,f,e]=cellfun(@(x) fileparts(x),df.img,'UniformOutput',0);
rfilenames=fullfile(datapath,currimgs); % Un-masked version
%rfilenames=fullfile(datapath,p,strcat('r',f,e)); % Masked version
volume_coverage(rfilenames,outfile)
end

%% Display results as orthview-plots in a png

summary_img_paths=dir('Check_*.nii');
summary_img_paths=vertcat({summary_img_paths.name});
t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/avg152T1.nii';
%t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/single_subj_T1.nii';

for i=1:length(summary_img_paths)
o=summary_img_paths(i);
[~,fname,~]=fileparts(summary_img_paths{i});
plot_nii_results(t,...
                 'overlays',o,... %Cell array of overlay volumes
                 'ov_color',{brighten(parula,-.6)},... %Cell array of overlay colors (RGB)
                 'ov_transparency',[0.6],...
                 'slices',[0,0,0],... %Cell array of slices (MNI)
                 'slice_ori',[1,2,3],...
                 'background',0,...
                 'outfilename',['montage_',fname]); %Scalar or array designating slice orientation (x=1,y=2,z=3)

end

%% For visually checking single-images with SPM's check_reg
%Get list of the first image of each study for exploration 
% for i=1:length(studies)
%    imagei=find(strcmp(df.studyID,studies(i)));
%    firstimagei(i)=imagei(1);
% end
% images=fullfile(datapath,df.img(firstimagei));
% images_hdr=strrep(images,'.img','.hdr');
% for i=1:length(images)
% [fpath,filename,ext]=fileparts(images{i});
% r_images{i,1}=fullfile(fpath,['r',filename,ext])
% end
% %Repeat for visually checking registration of first images with SPM's MNI
% %T1-template
% spm_check_registration(images{17},r_images{17},'/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/single_subj_T1.nii')