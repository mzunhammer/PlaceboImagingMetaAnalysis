function A_apply_various(datapath)
addpath(genpath(fullfile(userpath,'/CanlabCore/CanlabCore/')));
addpath(genpath(fullfile(userpath,'/CanlabPatternMasks/MasksPrivate')));

%% Set IO paths
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,['(?<!^)',filesep], 'DelimiterType','RegularExpression');
maskdir=fullfile(splitp{1:end-2},'pattern_masks');
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
            'basal_ganglia',...
            'insula'};
        
n=size(df,1);
%%
% Load Bucknerlab maps
[mask{1}, ~, ~] = load_image_set('bucknerlab_wholebrain'); % different loading procedure required.
mask{2} = load_atlas_matthias('thalamus');
mask{3} = load_atlas_matthias('brainstem');
mask{4} = load_atlas_matthias('basal_ganglia');
mask{5} = load_insular_atlas();
for l=1:length(mask);
    curr_mask=mask{l};
    curr_mask = replace_empty(curr_mask); % add zeros back in
    
    curr_atlasname=atlas_names{l};
    h = waitbar(0, [curr_atlasname, ' studies completed:']);
for i=1:n %loops over studies
    %for each study resample mask space to first study image (this is prefered over resampling the mask for every image to save computational time)
    first_img=fullfile(datapath,df.subjects{i}.(contrasts{4}){1}.norm_img);
    curr_mask = resample_space(curr_mask,...
                               fmri_data(first_img,'noverbose'));
    for j=1:length(contrasts) %loops over contrasts
        for k=1:size(df.subjects{i},1)
            if ~isempty(df.subjects{i}.(contrasts{j}){k})
            curr_img=df.subjects{i}.(contrasts{j}){k}.norm_img;
            in_path= fullfile(datapath,curr_img);
            in_img=fmri_data(in_path,'noverbose');
            sim = matthias_pattern_similarity(in_img,curr_mask);
            df.subjects{i}.(contrasts{j}){k}.(curr_atlasname) = sim';
            end 
        end
    save(df_path,'df');
    end
    waitbar(i / n,h);
end
close(h)
end  
end