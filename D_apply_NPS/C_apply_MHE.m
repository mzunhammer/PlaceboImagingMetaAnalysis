clear
addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));

%% Set IO paths
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
datadir=fullfile(filesep,splitp{1:end-2},'datasets');
maskdir=fullfile(filesep,splitp{1:end-2},'pattern_masks');
addpath(maskdir);
df_path=fullfile(datadir,'data_frame.mat');

load(df_path);
n=size(df,1);
h = waitbar(0,'Calculating tissue mask averages, studies completed:');
df.NPS_subr_info=repmat({struct('pos',{},'neg',{})},size(df,1),1);

df.NPS_subr_info=struct('pos',cell(height(df),1),...
              'neg',cell(height(df),1));
for i=1:n
    curr_fields=fieldnames(df.full(i));
    for j=1:length(curr_fields)
        if istable(df.full(i).(curr_fields{j}))
        if ~isempty(df.full(i).(curr_fields{j}))
        curr_imgs= df.full(i).(curr_fields{j}).norm_img;
        
        % Apply NPS, get NPS values and sub-region estimates
        MHE_values=apply_patternmask(fullfile(datadir, curr_imgs),fullfile(maskdir,'b_Weights_for_PCA_469_y_temp_x.nii'));
        df.full(i).(curr_fields{j}).MHE=[MHE_values{:}]';
        end
        end
     end
    save(df_path,'df');
    h =waitbar(i / n);
end
    
close(h)