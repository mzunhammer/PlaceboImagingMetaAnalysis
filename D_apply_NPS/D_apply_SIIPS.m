function D_apply_SIIPS(datapath)
addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));
addpath(genpath('~/Documents/MATLAB/CanlabPatternMasks/Neuroimaging_Pattern_Masks/'));

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
h = waitbar(0,'Calculating SIIPS, studies completed:');          
for i=1:n
    for j=1:length(contrasts)
        for k=1:size(df.subjects{i},1)
        if ~isempty(df.subjects{i}.(contrasts{j}){k})
        in_img= df.subjects{i}.(contrasts{j}){k}.norm_img;
        
        % Apply SIIPS, get SIIPS values and sub-region estimates
        [SIIPS_value, image_name, data_object, SIIPSpos_exp_by_region, SIIPSneg_exp_by_region, clpos, clneg] = ...
            apply_siips(fullfile(datapath, in_img),'notables','noverbose' );
        df.subjects{i}.(contrasts{j}){k}.SIIPS = SIIPS_value{:};
        % Not feasible for single-study processing. Get separately, for all images
        % together
        % df.SIIPS_subr_info(i).pos.(contrasts{j})={clpos};
        % df.SIIPS_subr_info(i).neg.(contrasts{j})={clneg};
        % Get sub-region estimates, construct valid names 
        SIIPS_pos=vertcat(SIIPSpos_exp_by_region{:});
        SIIPS_pos_names=strcat('SIIPS_pos_',...
                               strtrim({clpos.title}'),'_',...
                               strtrim({clpos.shorttitle}'));
        SIIPS_pos_names=matlab.lang.makeValidName(SIIPS_pos_names);
        SIIPS_pos=array2table(SIIPS_pos,'VariableNames',SIIPS_pos_names);

        SIIPS_neg=vertcat(SIIPSneg_exp_by_region{:});
        SIIPS_neg_names=strcat('SIIPS_neg_',...
                               strtrim({clneg.title}'),'_',...
                               strtrim({clneg.shorttitle}'));
        SIIPS_neg_names=matlab.lang.makeValidName(SIIPS_neg_names);
        SIIPS_neg=array2table(SIIPS_neg,'VariableNames',SIIPS_neg_names);

        % NaN for subregions with no global SIIPS-estimates
        emptyimgs=cellfun(@isempty,SIIPS_value);
        SIIPS_value(emptyimgs)={NaN};
        SIIPS_pos{emptyimgs,:}=NaN;
        SIIPS_neg{emptyimgs,:}=NaN;

        if any(ismember(SIIPS_neg_names,...
                        df.subjects{i}.(contrasts{j}){k}.Properties.VariableNames))
            df.subjects{i}.(contrasts{j}){k}(:,SIIPS_pos_names)=SIIPS_pos{:};
            df.subjects{i}.(contrasts{j}){k}(:,SIIPS_neg_names)=SIIPS_neg{:};
        end
        end
     end
    save(df_path,'df');
    waitbar(i / n,h);
    end
end
close(h)
end