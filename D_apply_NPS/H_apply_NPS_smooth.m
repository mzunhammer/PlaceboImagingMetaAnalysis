%% Additional NPS analysis based on images where smoothness was equalized

clear
addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));
addpath(genpath('~/Documents/MATLAB/CanlabPatternMasks/MasksPrivate/'));

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
df.NPS_subr_info_smooth=repmat({struct('pos',{},'neg',{})},size(df,1),1);

df.NPS_subr_info_smooth=struct('pos',cell(height(df),1),...
              'neg',cell(height(df),1));
for i=1:n
    curr_fields=fieldnames(df.full(i));
    for j=1:length(curr_fields)
        if istable(df.full(i).(curr_fields{j}))
        if ~isempty(df.full(i).(curr_fields{j}))
        curr_imgs= df.full(i).(curr_fields{j}).smoothed_norm_img;
        
        % Apply NPS, get NPS values and sub-region estimates
        [NPS_values, image_names, data_objects, NPSpos_exp_by_region, NPSneg_exp_by_region, clpos, clneg] = apply_nps(fullfile(datadir, curr_imgs),'notables' );
        df.full(i).(curr_fields{j}).NPS_smooth=[NPS_values{:}]';
        df.NPS_subr_info_smooth(i).pos.(curr_fields{j})={clpos};
        df.NPS_subr_info_smooth(i).neg.(curr_fields{j})={clneg};
        % Get sub-region estimates, construct valid names 
        NPS_pos=vertcat(NPSpos_exp_by_region{:});
        NPS_pos_names=strcat('NPS_smooth_Pos_',...
                               strtrim({clpos.title}'),'_',...
                               strtrim({clpos.shorttitle}'));
        NPS_pos_names=matlab.lang.makeValidName(NPS_pos_names);
        NPS_pos=array2table(NPS_pos,'VariableNames',NPS_pos_names);

        NPS_neg=vertcat(NPSneg_exp_by_region{:});
        NPS_neg_names=strcat('NPS_smooth_Neg_',...
                               strtrim({clneg.title}'),'_',...
                               strtrim({clneg.shorttitle}'));
        NPS_neg_names=matlab.lang.makeValidName(NPS_neg_names);
        NPS_neg=array2table(NPS_neg,'VariableNames',NPS_neg_names);

        % NaN for subregions with no global NPS-estimates
        emptyimgs=cellfun(@isempty,NPS_values);
        NPS_values(emptyimgs)={NaN};
        NPS_pos{emptyimgs,:}=NaN;
        NPS_neg{emptyimgs,:}=NaN;

        if any(ismember(NPS_neg_names,...
                        df.full(i).(curr_fields{j}).Properties.VariableNames))
            df.full(i).(curr_fields{j})(:,NPS_pos_names)=NPS_pos;
            df.full(i).(curr_fields{j})(:,NPS_neg_names)=NPS_neg;
        else
            df.full(i).(curr_fields{j})=[df.full(i).(curr_fields{j}),NPS_pos];
            df.full(i).(curr_fields{j})=[df.full(i).(curr_fields{j}),NPS_neg];
        end
        
        end
        end
     end
    save(df_path,'df');
    h =waitbar(i / n);
end
    
close(h)