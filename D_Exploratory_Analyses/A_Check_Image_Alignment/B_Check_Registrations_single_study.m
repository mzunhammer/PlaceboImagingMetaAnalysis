
% Setup: Load df with paths and variables
clear
basepath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/C_Exploratory_Analyses/A_Check_Image_Alignment';
cd(basepath)
dfpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets';
load(fullfile(dfpath,'AllData_w_NPS_MHE.mat'));
%datapath='/Volumes/Transcend/Boulder_Essen/Datasets/';
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/'
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/MontagePlot')

studies=unique(df.studyID);
masking_tol=0.00001;

for i=1%:length(studies)
currimgs=df.img(strcmp(df.studyID,studies(i)));
infiles=fullfile(datapath,currimgs);
[p,f,ext]=cellfun(@fileparts,infiles,'UniformOutput',0);
outfile=fullfile(basepath,['Check_',studies{i},'.nii']);

disp(['Masking ',studies(i)])

matlabbatch{1}.spm.util.imcalc.input = fullfile(datapath,currimgs);
matlabbatch{1}.spm.util.imcalc.output = outfile;
matlabbatch{1}.spm.util.imcalc.outdir = {};
matlabbatch{1}.spm.util.imcalc.expression = 'sum(abs(X)>masking_tol)/size(X,1)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
% For each Study load all images and convert them to logical (only voxels with content survive)
% Sum up all images/study
% Print
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
                 'ov_color',{parula},... %Cell array of overlay colors (RGB)
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