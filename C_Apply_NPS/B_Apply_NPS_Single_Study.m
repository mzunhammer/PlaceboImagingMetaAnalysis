clear
p = mfilename('fullpath'); %CANlab's apply mask do not like lists with relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
datadir=fullfile(filesep,splitp{1:end-2},'Datasets');
maskdir=fullfile(filesep,splitp{1:end-2},'pattern_masks');
addpath(maskdir)
% 'Atlas_et_al_2012'
% 'Bingel_et_al_2006'
% 'Bingel_et_al_2011'
% 'Choi_et_al_2013'
% 'Eippert_et_al_2009'
% 'Ellingsen_et_al_2013'
% 'Elsenbruch_et_al_2012'
% 'Freeman_et_al_2015'
% 'Geuter_et_al_2013'
% 'Huber_et_al_2013'
% 'Kessner_et_al_201314'
% 'Kong_et_al_2006'
% 'Kong_et_al_2009'
% 'Lui_et_al_2010'
% 'Ruetgen_et_al_2015'
% 'Schenk_et_al_2014'
% 'Theysohn_et_al_2014'
% 'Wager_at_al_2004a_princeton_shock'
% 'Wager_et_al_2004b_michigan_heat'
% 'Wrobel_et_al_2014'
% 'Zeidan_et_al_2015'

runstudies={...
 %'Atlas_et_al_2012'
% 'Bingel_et_al_2006'
 'Bingel_et_al_2011'
 'Choi_et_al_2013'
 'Eippert_et_al_2009'
 'Ellingsen_et_al_2013'
 'Elsenbruch_et_al_2012'
 'Freeman_et_al_2015'
 'Geuter_et_al_2013'
%'Huber_et_al_2013' % Excluded as same sample as Lui
 'Kessner_et_al_201314'
 'Kong_et_al_2006'
 'Kong_et_al_2009'
 'Lui_et_al_2010'
 'Ruetgen_et_al_2015'
 'Schenk_et_al_2014'
 'Theysohn_et_al_2014'
 'Wager_at_al_2004a_princeton_shock'
 'Wager_et_al_2004b_michigan_heat'
 'Wrobel_et_al_2014'
 'Zeidan_et_al_2015'
};

tic
h = waitbar(0,'Calculating NPS, studies completed:')
for i=1:length(runstudies)
    %Load table into a struct
    varload=load(fullfile(datadir,[runstudies{i},'.mat']));
    %Every table will be named differently, so get the name
    currtablename=fieldnames(varload);
    varload=struct2cell(varload);
    %Load the variably named table into "df"
    currtablename=currtablename(cellfun(@istable,varload),:);
    df=varload{cellfun(@istable,varload),:};

    % Compute NPS (The CAN Toolbox must be added to path!!!!)
    all_imgs= df.norm_img;

    [NPS_values, image_names, data_objects, NPSpos_exp_by_region, NPSneg_exp_by_region, clpos, clneg] = apply_nps(fullfile(datadir, all_imgs),'notables' );

    NPS_pos=vertcat(NPSpos_exp_by_region{:});
    NPS_pos_names=strcat('NPS_Pos_',...
                           strtrim({clpos.title}'),'_',...
                           strtrim({clpos.shorttitle}'));
    NPS_pos_names=matlab.lang.makeValidName(NPS_pos_names);
    NPS_pos=array2table(NPS_pos,'VariableNames',NPS_pos_names);

    NPS_neg=vertcat(NPSneg_exp_by_region{:});
    NPS_neg_names=strcat('NPS_Neg_',...
                           strtrim({clneg.title}'),'_',...
                           strtrim({clneg.shorttitle}'));
    NPS_neg_names=matlab.lang.makeValidName(NPS_neg_names);
    NPS_neg=array2table(NPS_neg,'VariableNames',NPS_neg_names);

    emptyimgs=cellfun(@isempty,NPS_values);
    NPS_values(emptyimgs)={NaN};
    NPS_pos{emptyimgs,:}=NaN;
    NPS_neg{emptyimgs,:}=NaN;
    df.NPS=[NPS_values{:}]';
    
    if any(ismember(NPS_neg_names,df.Properties.VariableNames))
        df(:,NPS_pos_names)=NPS_pos;
        df(:,NPS_neg_names)=NPS_neg;
    else
        df=[df,NPS_pos];
        df=[df,NPS_neg];
    end
    
    clneg_NPS=clneg;
    clpos_NPS=clpos;
    % Push the data in df into a table with the name of the original table
    eval([currtablename{1} '= df']);
    % Eval statement saving results with original table name
    %eval(['save(fullfile(datadir,[runstudies{i}]),''',currtablename{1},''')']);
    eval(['save(fullfile(datadir,[runstudies{i}]),''',currtablename{1},''',''clneg_NPS'',''clpos_NPS'',''-append'')']);

    toc/60, 'Minutes'
    waitbar(i / length(runstudies))
end
close(h)