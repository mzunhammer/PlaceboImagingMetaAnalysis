function A_apply_various(datapath)
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

atlas_names={'bucknerlab_wholebrain',...
            'thalamus',...
            'brainstem',...
            'basal_ganglia'};
        
n=size(df,1);
h = waitbar(0,'Calculating Buckner lab map simularity, studies completed:');
%%
% Load Bucknerlab maps
[mask{1}, ~, ~] = load_image_set('bucknerlab_wholebrain'); % different loading procedure required.
mask{2} = load_atlas_matthias('thalamus');
mask{3} = load_atlas_matthias('brainstem');
mask{4} = load_atlas_matthias('basal_ganglia');

for l=4%1:length(mask)
    curr_mask=mask{l};
    curr_atlasname=atlas_names{l};
for i=1:n %loops over studies
    for j=1:length(contrasts) %loops over contrasts
        for k=1:size(df.subjects{i},1)
            if ~isempty(df.subjects{i}.(contrasts{j}){k})
            curr_img=df.subjects{i}.(contrasts{j}){k}.norm_img;
            in_path= fullfile(datapath,curr_img);
            in_img=fmri_data(in_path,'noverbose');
            sim = matthias_pattern_similarity(in_img,curr_mask);
%             for im = 1:size(curr_mask.dat, 2) %loops over pattern masks
%                 sim(im, :) = canlab_pattern_similarity(in_img.dat, curr_mask.dat(:,im), 'dot_product');
%             end
%             image_similarity_plot(in_img,curr_mask,...
%                                        'cosine_similarity',...
%                                        'nofigure',...
%                                        'noplot');
            df.subjects{i}.(contrasts{j}){k}.(curr_atlasname) = sim';
            end 
        end
    save(df_path,'df');
    waitbar(i / n);
    end
end
end  
close(h)
end