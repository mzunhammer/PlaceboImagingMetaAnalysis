% Setup: Load df with paths and variables
clear

% Setup: Load df with paths and variables
datapath='../../../Datasets/';
tic
load(fullfile(datapath,'dfMaskedInclusiveImg.mat'));
outpath='./C_Exploratory_Analyses/A_Check_Image_Alignment/'

outfile='Check_coverage_all_images_raw.nii';
addpath('../../MontagePlot/')

% For preparing a mask of all images:
%test_images=df.img

% For preparing a mask with the k'th image of each participant
% subs=unique(df.subID)
%  for i=1:length(subs)
%     imagei=find(strcmp(df.subID,subs(i)));
%     firstimagei(i)=imagei(1);
%  end
% test_images=df.img(firstimagei);

[p,f,e]=cellfun(@(x) fileparts(x),df.img,'UniformOutput',0);
rfilenames=fullfile(datapath,p,strcat(f,e)); % Un-masked version
%rfilenames=fullfile(datapath,p,strcat('r',f,e)); % Masked version
volume_coverage(rfilenames,outfile)

%% Display results as orthview-plots in a png

%t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/avg152T1.nii';
%t='/Users/matthiaszunhammer/Documents/MATLAB/spm12/canonical/single_subj_T1.nii';
t='/Users/matthiaszunhammer/Documents/MATLAB/spm12/canonical/fsl_standards/MNI152_T1_1mm_brain.nii'

%colorused=brighten(flipud(cbrewer('seq','OrRd',1000)),0) % Try out cbrewer
%colors
[~,fname,~]=fileparts(outfile);
plot_nii_results(t,...
                 'overlays',{outfile},... %Cell array of overlay volumes
                 'ov_color',{brighten(parula,-0.75)},... %Cell array of overlay colors (RGB)    
                 'ov_transparency',[0.6],...
                 'slices',[0,0,0],... %Cell array of slices (MNI)
                 'slice_ori',[1,2,3],...
                 'background',1,...
                 'outfilename',['montage_',fname]); %Scalar or array designating slice orientation (x=1,y=2,z=3)