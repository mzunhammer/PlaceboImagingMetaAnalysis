% Setup: Load df with paths and variables
clear

% Setup: Load df with paths and variables
datapath='/Volumes/Transcend/Boulder_Essen/Datasets/';
tic
load(fullfile(datapath,'dfMaskedBasicImg.mat'));
cd '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/C_Exploratory_Analyses/A_Check_Image_Alignment'

outfile='Check_coverage_all_images_raw.nii';

% For preparing a mask of all images:
%test_images=df.img

% For preparing a mask with the k'th image of each participant
subs=unique(df.subID)
 for i=1:length(subs)
    imagei=find(strcmp(df.subID,subs(i)));
    firstimagei(i)=imagei(1);
 end
test_images=df.img(firstimagei);

[p,f,e]=cellfun(@(x) fileparts(x),test_images,'UniformOutput',0);
rfilenames=fullfile(datapath,p,strcat(f,e)); % Un-masked version
%rfilenames=fullfile(datapath,p,strcat('r',f,e)); % Masked version
volume_coverage(rfilenames,outfile)


%% Display results as orthview-plots in a png


t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/avg152T1.nii';
%t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/single_subj_T1.nii';

[~,fname,~]=fileparts(outfile);
plot_nii_results(t,...
                 'overlays',{outfile},... %Cell array of overlay volumes
                 'ov_color',{parula},... %Cell array of overlay colors (RGB)
                 'ov_transparency',[0.6],...
                 'slices',[0,0,0],... %Cell array of slices (MNI)
                 'slice_ori',[1,2,3],...
                 'background',0,...
                 'outfilename',['montage_',fname]); %Scalar or array designating slice orientation (x=1,y=2,z=3)


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