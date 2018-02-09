function C_apply_MHE(datapath)
addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));
addpath(genpath('~/Documents/MATLAB/CanlabPatternMasks/MasksPrivate/'));

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
       
% Pre allocate by-study structs containing info on the location&size of NPS
% subregions.
%df.NPS_subr_info=repmat({struct('pos',{},'neg',{})},size(df,1),1);

%df.NPS_subr_info=struct('pos',cell(height(df),1),...
%              'neg',cell(height(df),1));

n=size(df,1);
h = waitbar(0,'Calculating tissue mask averages, studies completed:');          
for i=1:n
    for j=1:length(contrasts)
        for k=1:size(df.subjects{i},1)
        if ~isempty(df.subjects{i}.(contrasts{j}){k})
        in_img= df.subjects{i}.(contrasts{j}){k}.norm_img;
        
        % Apply NPS, get NPS values and sub-region estimates
        MHE_value=apply_patternmask(fullfile(datapath, in_img),...
                        fullfile(maskdir,'b_Weights_for_PCA_469_y_temp_x.nii'),...
                        'noverbose');
        df.subjects{i}.(contrasts{j}){k}.MHE = MHE_value{:};
        end
        end
     end
    save(df_path,'df');
    h =waitbar(i / n,h);
end
close(h)
end