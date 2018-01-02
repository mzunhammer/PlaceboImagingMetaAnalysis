%% Set working environment
clear
datadir = '../../Datasets/';

%% Predefine empty variables and data table
%% Import all study df's
load([datadir, 'Atlas_et_al_2012.mat'])
load([datadir, 'Bingel_et_al_2006.mat'])
load([datadir, 'Bingel_et_al_2011.mat'])
load([datadir, 'Choi_et_al_2013.mat'])
load([datadir, 'Eippert_et_al_2009.mat'])
load([datadir, 'Ellingsen_et_al_2013.mat'])
load([datadir, 'Elsenbruch_et_al_2012.mat'])
load([datadir, 'Freeman_et_al_2015.mat'])
load([datadir, 'Geuter_et_al_2013.mat'])
%load([datadir, 'Huber_et_al_2013.mat']) % Duplicate! Use Lui et al.
load([datadir, 'Kessner_et_al_201314.mat'])
load([datadir, 'Kong_et_al_2006.mat'])
load([datadir, 'Kong_et_al_2009.mat'])
load([datadir, 'Lui_et_al_2010.mat'])
load([datadir, 'Ruetgen_et_al_2015.mat'])
load([datadir, 'Schenk_et_al_2014.mat'])
load([datadir, 'Theysohn_et_al_2014.mat'])
load([datadir, 'Wager_at_al_2004a_princeton_shock.mat'])
load([datadir, 'Wager_et_al_2004b_michigan_heat.mat'])
load([datadir, 'Wrobel_et_al_2014.mat'])
load([datadir, 'Zeidan_et_al_2015.mat'])

%% Combine the studies
df=[atlas;bingel06;bingel11;choi;eippert;ellingsen;elsenb;freeman;geuter;kessner;kong06;kong09;lui;ruetgen;schenk;they;wager_princeton;wager_michigan;wrobel;zeidan];
%% Save all studies as df
save(fullfile(datadir,'AllData.mat'), 'df')