function E_apply_NPS_responder(datapath)

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
           'placebo_minus_control'};

n=size(df,1);
h = waitbar(0,'Calculating NPS, studies completed:');          
for i=1:n
    for j=1:length(contrasts)
        for k=1:size(df.responder_subjects{i},1)
        if ~isempty(df.responder_subjects{i}.(contrasts{j}){k})
        in_img= df.responder_subjects{i}.(contrasts{j}){k}.img;
        
        % Apply NPS, get NPS values and sub-region estimates
        [NPS_value, image_name, data_object, NPSpos_exp_by_region, NPSneg_exp_by_region, clpos, clneg] = ...
            apply_nps(fullfile(datapath, in_img),'notables','noverbose' );
        df.responder_subjects{i}.(contrasts{j}){k}.NPS = NPS_value{:};
        % Not feasible for single-study processing. Get separately, for all images
        % together
        % df.NPS_subr_info(i).pos.(contrasts{j})={clpos};
        % df.NPS_subr_info(i).neg.(contrasts{j})={clneg};
        % Get sub-region estimates, construct valid names 
        NPS_pos=vertcat(NPSpos_exp_by_region{:});
        NPS_pos_names=strcat('NPS_pos_',...
                               strtrim({clpos.title}'),'_',...
                               strtrim({clpos.shorttitle}'));
        NPS_pos_names=matlab.lang.makeValidName(NPS_pos_names);
        NPS_pos=array2table(NPS_pos,'VariableNames',NPS_pos_names);

        NPS_neg=vertcat(NPSneg_exp_by_region{:});
        NPS_neg_names=strcat('NPS_neg_',...
                               strtrim({clneg.title}'),'_',...
                               strtrim({clneg.shorttitle}'));
        NPS_neg_names=matlab.lang.makeValidName(NPS_neg_names);
        NPS_neg=array2table(NPS_neg,'VariableNames',NPS_neg_names);

        % NaN for subregions with no global NPS-estimates
        emptyimgs=cellfun(@isempty,NPS_value);
        NPS_value(emptyimgs)={NaN};
        NPS_pos{emptyimgs,:}=NaN;
        NPS_neg{emptyimgs,:}=NaN;

        if any(ismember(NPS_neg_names,...
                        df.responder_subjects{i}.(contrasts{j}){k}.Properties.VariableNames))
            df.responder_subjects{i}.(contrasts{j}){k}(:,NPS_pos_names)=NPS_pos{:};
            df.responder_subjects{i}.(contrasts{j}){k}(:,NPS_neg_names)=NPS_neg{:};
        end
        end
     end
    save(df_path,'df');
    waitbar(i /n,h);
    end
end
close(h)
end