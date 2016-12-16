clear
p = mfilename('fullpath'); %CANlab's apply mask do not like lists with relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
datadir=fullfile(filesep,splitp{1:end-2},'Datasets');

% 'Atlas_et_al_2012_NPS'
% 'Bingel_et_al_2006_NPS'
% 'Bingel_et_al_2011_NPS'
% 'Choi_et_al_2013_NPS'
% 'Eippert_et_al_2009_NPS'
% 'Ellingsen_et_al_2013_NPS'
% 'Elsenbruch_et_al_2012_NPS'
% 'Freeman_et_al_2015_NPS'
% 'Geuter_et_al_2013_NPS'
% 'Huber_et_al_2013_NPS'
% 'Kessner_et_al_201314_NPS'
% 'Kong_et_al_2006_NPS'
% 'Kong_et_al_2009_NPS'
% 'Ruetgen_et_al_2015_NPS'
% 'Schenk_et_al_2014_NPS'
% 'Theysohn_et_al_2014_NPS'
% 'Wager_at_al_2004a_princeton_shock_NPS'
% 'Wager_et_al_2004b_michigan_heat_NPS'
% 'Wrobel_et_al_2014_NPS'
% 'Zeidan_et_al_2015_NPS'

runstudies={...
'Atlas_et_al_2012_NPS'
'Bingel_et_al_2006_NPS'
'Bingel_et_al_2011_NPS'
'Choi_et_al_2013_NPS'
'Eippert_et_al_2009_NPS'
'Ellingsen_et_al_2013_NPS'
'Elsenbruch_et_al_2012_NPS'
'Freeman_et_al_2015_NPS'
'Geuter_et_al_2013_NPS'
'Huber_et_al_2013_NPS'
'Kessner_et_al_201314_NPS'
'Kong_et_al_2006_NPS'
'Kong_et_al_2009_NPS'
'Ruetgen_et_al_2015_NPS'
'Schenk_et_al_2014_NPS'
'Theysohn_et_al_2014_NPS'
'Wager_at_al_2004a_princeton_shock_NPS'
'Wager_et_al_2004b_michigan_heat_NPS'
'Wrobel_et_al_2014_NPS'
'Zeidan_et_al_2015_NPS'
};

tic
h = waitbar(0,'Calculating NPS, studies completed:')
for i=1:length(runstudies)
%Load table into a struct
varload=load(fullfile(datadir,[runstudies{i},'.mat']));
%Every table will be named differently, so get the name
currtablename=fieldnames(varload);
%Load the variably named table into "df"
df=varload.(currtablename{:});

% Compute MHE (The CAN Toolbox must be added to path!!!!)
all_imgs= df.img;
results=apply_patternmask(fullfile(datadir, all_imgs),fullfile(p,'pattern_masks/b_Weights_for_PCA_469_y_temp_x.nii'));
df.MHEraw=[results{:}]';
df.MHEcorrected=nps_rescale(df.MHEraw,df.voxelVolMat,df.xSpan,df.conSpan);

% Push the data in df into a table with the name of the original table
eval([currtablename{1} '= df']);
% Eval statement saving results with original table name
eval(['save(fullfile(datadir,[runstudies{i},''_MHE.mat'']),''',currtablename{1},''')'])

toc/60, 'Minutes'
waitbar(i / length(runstudies))
end
close(h)