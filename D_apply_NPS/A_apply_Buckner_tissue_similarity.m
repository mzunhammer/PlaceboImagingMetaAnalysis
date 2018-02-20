function A_apply_Buckner_tissue_similarity(datapath)
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
h = waitbar(0,'Calculating Buckner lab map simularity, studies completed:');
%%
% Load Bucknerlab maps
[mask, ~, ~] = load_image_set('bucknerlab_wholebrain');
for i=10:n %loops over studies
    for j=1:length(contrasts) %loops over contrasts
        for k=1:size(df.subjects{i},1)
            if ~isempty(df.subjects{i}.(contrasts{j}){k})
            curr_img=df.subjects{i}.(contrasts{j}){k}.norm_img;
            in_path= fullfile(datapath,curr_img);
            in_img=fmri_data(in_path,'noverbose');
            sim = zeros(size(mask.dat, 2), size(in_img.dat,2));
                for im = 1:size(mask.dat, 2) %loops over pattern masks
                    sim(im, :) = canlab_pattern_similarity(in_img.dat, mask.dat(:,im), 'cosine_similarity');
                end
            df.subjects{i}.(contrasts{j}){k}.bucknerlab_wholebrain = sim';
            end 
        end
    save(df_path,'df');
    waitbar(i / n);
    end
end
    
close(h)
end