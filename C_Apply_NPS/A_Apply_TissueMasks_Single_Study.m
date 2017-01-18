clear
p = mfilename('fullpath'); %CANlab's apply mask do not like lists with relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
datadir=fullfile(filesep,splitp{1:end-2},'Datasets');
addpath('./pattern_masks/')
% 'Atlas_et_al_2012_NPS_MHE'
% 'Bingel_et_al_2006_NPS_MHE'
% 'Bingel_et_al_2011_NPS_MHE'
% 'Choi_et_al_2013_NPS_MHE'
% 'Eippert_et_al_2009_NPS_MHE'
% 'Ellingsen_et_al_2013_NPS_MHE'
% 'Elsenbruch_et_al_2012_NPS_MHE'
% 'Freeman_et_al_2015_NPS_MHE'
% 'Geuter_et_al_2013_NPS_MHE'
% 'Huber_et_al_2013_NPS_MHE'
% 'Kessner_et_al_201314_NPS_MHE'
% 'Kong_et_al_2006_NPS_MHE'
% 'Kong_et_al_2009_NPS_MHE'
% 'Lui_et_al_2010_NPS_MHE'
% 'Ruetgen_et_al_2015_NPS_MHE'
% 'Schenk_et_al_2014_NPS_MHE'
% 'Theysohn_et_al_2014_NPS_MHE'
% 'Wager_at_al_2004a_princeton_shock_NPS_MHE'
% 'Wager_et_al_2004b_michigan_heat_NPS_MHE'
% 'Wrobel_et_al_2014_NPS_MHE'
% 'Zeidan_et_al_2015_NPS_MHE'

runstudies={...
'Atlas_et_al_2012_NPS_MHE'
'Bingel_et_al_2006_NPS_MHE'
'Bingel_et_al_2011_NPS_MHE'
'Choi_et_al_2013_NPS_MHE'
'Eippert_et_al_2009_NPS_MHE'
'Ellingsen_et_al_2013_NPS_MHE'
'Elsenbruch_et_al_2012_NPS_MHE'
'Freeman_et_al_2015_NPS_MHE'
'Geuter_et_al_2013_NPS_MHE'
'Huber_et_al_2013_NPS_MHE'
'Kessner_et_al_201314_NPS_MHE'
'Kong_et_al_2006_NPS_MHE'
'Kong_et_al_2009_NPS_MHE'
'Lui_et_al_2010_NPS_MHE'
'Ruetgen_et_al_2015_NPS_MHE'
'Schenk_et_al_2014_NPS_MHE'
'Theysohn_et_al_2014_NPS_MHE'
'Wager_at_al_2004a_princeton_shock_NPS_MHE'
'Wager_et_al_2004b_michigan_heat_NPS_MHE'
'Wrobel_et_al_2014_NPS_MHE'
'Zeidan_et_al_2015_NPS_MHE'
};

tic
h = waitbar(0,'Calculating NPS, studies completed:');
for i=1:length(runstudies)
%Load table into a struct
varload=load(fullfile(datadir,[runstudies{i},'.mat']));
%Every table will be named differently, so get the name
currtablename=fieldnames(varload);
%Load the variably named table into "df"
df=varload.(currtablename{:});

% Compute MHE (The CAN Toolbox must be added to path!!!!)
all_imgs= df.img;

%mask = '/Users/matthiaszunhammer/Documents/MATLAB/zun_pain_pattern/b_Weights_for_PCA_469_y_temp_x.nii';

grey=apply_patternmask(fullfile(datadir,all_imgs),fullfile(p,'pattern_masks/grey.nii'));
white=apply_patternmask(fullfile(datadir,all_imgs),fullfile(p,'pattern_masks/white.nii'));
csf=apply_patternmask(fullfile(datadir,all_imgs),fullfile(p,'pattern_masks/csf.nii'));
brain=apply_patternmask(fullfile(datadir, all_imgs),fullfile(p,'pattern_masks/brainmask.nii'));
nobrain=apply_patternmask(fullfile(datadir, all_imgs),fullfile(p,'pattern_masks/inverted_brainmask.nii'));

df.grey=[grey{:}]';
df.white=[white{:}]';
df.csf=[csf{:}]';
df.brain=[brain{:}]';
df.nobrain=[nobrain{:}]';

grey_abs=apply_patternmask_abs(fullfile(datadir,all_imgs),fullfile(p,'pattern_masks/grey.nii'));
white_abs=apply_patternmask_abs(fullfile(datadir,all_imgs),fullfile(p,'pattern_masks/white.nii'));
csf_abs=apply_patternmask_abs(fullfile(datadir,all_imgs),fullfile(p,'pattern_masks/csf.nii'));
brain_abs=apply_patternmask_abs(fullfile(datadir, all_imgs),fullfile(p,'pattern_masks/brainmask.nii'));
nobrain_abs=apply_patternmask_abs(fullfile(datadir, all_imgs),fullfile(p,'pattern_masks/inverted_brainmask.nii'));

df.grey_abs=[grey_abs{:}]';
df.white_abs=[white_abs{:}]';
df.csf_abs=[csf_abs{:}]';
df.brain_abs=[brain_abs{:}]';
df.nobrain_abs=[nobrain_abs{:}]';

% Push the data in df into a table with the name of the original table
eval([currtablename{1} '= df']);
% Eval statement saving results with original table name
eval(['save(fullfile(datadir,[runstudies{i}]),''',currtablename{1},''')'])

toc/60, 'Minutes'
waitbar(i / length(runstudies))
end
close(h)