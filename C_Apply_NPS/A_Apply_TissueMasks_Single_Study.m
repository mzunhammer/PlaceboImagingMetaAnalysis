clear
p = mfilename('fullpath'); %CANlab's apply mask do not like lists with relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
datadir=fullfile(filesep,splitp{1:end-2},'Datasets');
addpath('./pattern_masks/')
% 'Atlas_et_al_2012'
% 'Bingel_et_al_2006'
% 'Bingel_et_al_2011'
% 'Choi_et_al_2013'
% 'Eippert_et_al_2009'
% 'Ellingsen_et_al_2013'
% 'Elsenbruch_et_al_2012'
% 'Freeman_et_al_2015'
% 'Geuter_et_al_2013'
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
% 'Atlas_et_al_2012'
'Bingel_et_al_2006'
% 'Bingel_et_al_2011'
% 'Choi_et_al_2013'
% 'Eippert_et_al_2009'
% 'Ellingsen_et_al_2013'
% 'Elsenbruch_et_al_2012'
% 'Freeman_et_al_2015'
% 'Geuter_et_al_2013'
'Huber_et_al_2013'
% 'Kessner_et_al_201314'
% 'Kong_et_al_2006'
% 'Kong_et_al_2009'
'Lui_et_al_2010'
% 'Ruetgen_et_al_2015'
% 'Schenk_et_al_2014'
% 'Theysohn_et_al_2014'
% 'Wager_at_al_2004a_princeton_shock'
% 'Wager_et_al_2004b_michigan_heat'
% 'Wrobel_et_al_2014'
% 'Zeidan_et_al_2015'
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

grey(cellfun(@isempty,grey))={NaN};
white(cellfun(@isempty,white))={NaN};
csf(cellfun(@isempty,csf))={NaN};
brain(cellfun(@isempty,brain))={NaN};
nobrain(cellfun(@isempty,nobrain))={NaN};

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

grey_abs(cellfun(@isempty,grey_abs))={NaN};
white_abs(cellfun(@isempty,white_abs))={NaN};
csf_abs(cellfun(@isempty,csf_abs))={NaN};
brain_abs(cellfun(@isempty,brain_abs))={NaN};
nobrain_abs(cellfun(@isempty,nobrain_abs))={NaN};

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