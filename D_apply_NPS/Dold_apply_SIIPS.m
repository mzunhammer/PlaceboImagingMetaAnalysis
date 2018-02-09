function D_apply_SIIPS(datapath)
addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));
addpath(genpath('~/Documents/MATLAB/CanlabPatternMasks/MasksPrivate/'));

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
       
tic
h = waitbar(0,'Calculating SIIPS, studies completed:')
for i=1:length(runstudies)
    %Load table into a struct
    varload=load(fullfile(datapath,[runstudies{i},'.mat']));
    %Every table will be named differently, so get the name
    currtablename=fieldnames(varload);
    varload=struct2cell(varload);
    %Load the variably named table into "df"
    currtablename=currtablename(cellfun(@istable,varload),:);
    df=varload{cellfun(@istable,varload),:};
    

    % Compute SIIPS (The CAN Toolbox and the "Neuroimaging_Pattern_Masks" folders must be added to path!!!!)
    all_imgs= df.norm_img;
    [siips_values, image_names, data_objects, siipspos_exp_by_region, siipsneg_exp_by_region, clpos, clneg] = apply_siips(fullfile(datapath, all_imgs),'notables' );

    siips_pos=vertcat(siipspos_exp_by_region{:});
    siips_pos_names=strcat('SIIPS_Pos_',...
                           strtrim({clpos.title}'),'_',...
                           strtrim({clpos.shorttitle}'));
    siips_pos_names=matlab.lang.makeValidName(siips_pos_names);
    siips_pos=array2table(siips_pos,'VariableNames',siips_pos_names);

    siips_neg=vertcat(siipsneg_exp_by_region{:});
    siips_neg_names=strcat('SIIPS_Neg_',...
                           strtrim({clneg.title}'),'_',...
                           strtrim({clneg.shorttitle}'));
    siips_neg_names=matlab.lang.makeValidName(siips_neg_names);
    siips_neg=array2table(siips_neg,'VariableNames',siips_neg_names);

    emptyimgs=cellfun(@isempty,siips_values);
   	siips_values(emptyimgs)={NaN};
    siips_pos{emptyimgs,:}=NaN;
    siips_neg{emptyimgs,:}=NaN;
    df.SIIPS=[siips_values{:}]';
    
    
    if any(ismember(siips_neg_names,df.Properties.VariableNames))
        df(:,siips_pos_names)=siips_pos;
        df(:,siips_neg_names)=siips_neg;
    else
        df=[df,siips_pos];
        df=[df,siips_neg];
    end

    clneg_siips=clneg;
    clpos_siips=clpos;
    % Push the data in df into a table with the name of the original table
    eval([currtablename{1} '= df']);
    % Eval statement saving results with original table name
    eval(['save(fullfile(datapath,[runstudies{i}]),''',currtablename{1},''',''clneg_siips'',''clpos_siips'',''-append'')']);

    toc/60, 'Minutes'
    waitbar(i / length(runstudies))
end
close(h)
end