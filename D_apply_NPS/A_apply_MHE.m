function A_apply_MHE(datapath)
addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));

%% Set IO paths
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
maskdir=fullfile(filesep,splitp{1:end-2},'pattern_masks');
addpath(maskdir);
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');

contrasts={'pain_placebo',...
           'pain_control',...
           'placebo_minus_control',...
           'placebo_and_control'};

n=size(df,1);
h = waitbar(0,'Calculating MHE, studies completed:');
%%
for i=1:n
    for j=1:length(contrasts)
        for k=1:size(df.subjects{i},1)
        if ~isempty(df.subjects{i}.(contrasts{j}){k})
        in_img= df.subjects{i}.(contrasts{j}){k}.norm_img;
        
        grey=apply_patternmask(fullfile(datapath,in_img),...
            fullfile(maskdir,'grey.nii'),'noverbose');
        white=apply_patternmask(fullfile(datapath,in_img),...
            fullfile(maskdir,'white.nii'),'noverbose');
        csf=apply_patternmask(fullfile(datapath,in_img),...
            fullfile(maskdir,'csf.nii'),'noverbose');
        brainmask=apply_patternmask(fullfile(datapath, in_img),...
            fullfile(maskdir,'brainmask.nii'),'noverbose');
        nobrain=apply_patternmask(fullfile(datapath, in_img),...
            fullfile(maskdir,'inverted_brainmask.nii'),'noverbose');
        df.subjects{i}.(contrasts{j}){k}.grey = grey{:};
        df.subjects{i}.(contrasts{j}){k}.white = white{:};
        df.subjects{i}.(contrasts{j}){k}.csf = csf{:};
        df.subjects{i}.(contrasts{j}){k}.brain = brainmask{:};
        df.subjects{i}.(contrasts{j}){k}.nobrain = nobrain{:};
        end
        end
    save(df_path,'df');
    end
    waitbar(i / n,h);
end
    
close(h)
end