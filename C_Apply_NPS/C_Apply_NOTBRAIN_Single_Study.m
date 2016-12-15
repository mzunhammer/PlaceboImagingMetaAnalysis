clear
datadir='../Datasets/';

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
% 'Ruetgen_et_al_2015_NPS_MHE'
% 'Schenk_et_al_2014_NPS_MHE'
% 'Theysohn_et_al_2014_NPS_MHE'
% 'Wager_at_al_2004a_princeton_shock_NPS_MHE'
% 'Wager_et_al_2004b_michigan_heat_NPS_MHE'
% 'Wrobel_et_al_2014_NPS_MHE'
% 'Zeidan_et_al_2015_NPS_MHE'

runstudies={...
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
% 'Ruetgen_et_al_2015_NPS_MHE'
'Schenk_et_al_2014_NPS_MHE'
% 'Theysohn_et_al_2014_NPS_MHE'
% 'Wager_at_al_2004a_princeton_shock_NPS_MHE'
% 'Wager_et_al_2004b_michigan_heat_NPS_MHE'
% 'Wrobel_et_al_2014_NPS_MHE'
% 'Zeidan_et_al_2015_NPS_MHE'
};

tic
for i=1:length(runstudies)
%Load table into a struct
varload=load(strcat(datadir,runstudies{i},'.mat'))
%Every table will be named differently, so get the name
currtablename=fieldnames(varload);
%Load the variably named table into "df"
df=varload.(currtablename{:});

% Compute MHE (The CAN Toolbox must be added to path!!!!)
all_imgs= df.img;

%mask = '/Users/matthiaszunhammer/Documents/MATLAB/zun_pain_pattern/b_Weights_for_PCA_469_y_temp_x.nii';

grey=apply_patternmask(strcat(datadir,all_imgs),'./B_Apply_NPS/pattern_masks/grey.nii');
white=apply_patternmask(strcat(datadir,all_imgs),'./B_Apply_NPS/pattern_masks/white.nii');
csf=apply_patternmask(strcat(datadir,all_imgs),'./B_Apply_NPS/pattern_masks/csf.nii');
brain=apply_patternmask(strcat(datadir, all_imgs),'./B_Apply_NPS/pattern_masks/brainmask.nii');
nobrain=apply_patternmask(strcat(datadir, all_imgs),'./B_Apply_NPS/pattern_masks/inverted_brainmask.nii');

df.grey=[grey{:}]';
df.white=[white{:}]';
df.csf=[csf{:}]';
df.brain=[brain{:}]';
df.nobrain=[nobrain{:}]';

% Push the data in df into a table with the name of the original table
eval([currtablename{1} '= df']);
% Eval statement saving results with original table name
eval(['save([datadir,runstudies{i},''_NOBRAIN.mat''],''',currtablename{1},''')'])

toc/60, 'Minutes'
end