function A_create_study_overview_table(datapath)

%% Creates an overview table for study-level information
% data collected from original publications, mat-files, and personal
% communication

study_ID={
'atlas'
'bingel06'
'bingel11'
'choi'
'eippert'
'ellingsen'
'elsenbruch'
'freeman'
'geuter'
'kessner'
'kong06'
'kong09'
'lui'
'ruetgen'
'schenk'
'theysohn'
'wager04a_princeton'
'wager04b_michigan'
'wrobel'
'zeidan'};

n=[
21 %'atlas'
19 %'bingel06'
22 %'bingel11'
15%'choi'
40 %'eippert'
28 %'ellingsen'
36 %'elsenbruch'
24 %'freeman'
40 %'geuter'
39 %'kessner'
10 %'kong06'
12 %'kong09'
31 %'lui'
102 %'ruetgen'
32 %'schenk'
30 %'theysohn'
24 %'wager04a_princeton'
23 %'wager04b_michigan'
38 %'wrobel'
17]; %'zeidan'

 study_dir={
'Atlas_et_al_2012' %'atlas'
'Bingel_et_al_2006' %'bingel06'
'Bingel_et_al_2011' %'bingel11'
'Choi_et_al_2011' %'choi'
'Eippert_et_al_2009' %'eippert'
'Ellingsen_et_al_2013' %'ellingsen'
'Elsenbruch_et_al_2012' %'elsenbruch'
'Freeman_et_al_2015' %'freeman'
'Geuter_et_al_2013' %'geuter'
'Kessner_et_al_201314' %kessner
'Kong_et_al_2006' %'kong06'
'Kong_et_al_2009' %'kong009'
'Lui_et_al_2010' %'lui'
'Ruetgen_et_al_2015' %'ruetgen'
'Schenk_et_al_2014' %'schenk'
'Theysohn_et_al_2014' %'theysohn'
'Wager_et_al_2004a_Princeton_shock' %'wager04a'
'Wager_et_al_2004b_Michigan_heat' %'wager04b'
'Wrobel_et_al_2014' %'wrobel14'
'Zeidan_et_al_2015'}; %'zeidan'

study_design={
'within' %'atlas'
'within' %'bingel06'
'within' %'bingel11'
'within' %'choi'
'within' %'eippert'
'within' %'ellingsen'
'within' %'elsenbruch'
'within' %'freeman'
'within' %'geuter'
'between' %'kessner' (mixed design, but "between-group" in respect to placebo conditioning)
'within' %'kong06'
'within' %'kong09'
'within' %'lui'
'between' %'ruetgen'
'within' %'schenk'
'within' %'theysohn'
'within' %'wager04a_princeton'
'within' %'wager04b_michigan'
'within' %'wrobel'
'within'}; %'zeidan'

img_modality={
'fMRI' %'atlas'
'fMRI' %'bingel06'
'fMRI' %'bingel11'
'fMRI' %'choi'
'fMRI' %'eippert'
'fMRI' %'ellingsen'
'fMRI' %'elsenbruch'
'fMRI' %'freeman'
'fMRI' %'geuter'
'fMRI' %'kessner'
'fMRI' %'kong06'
'fMRI' %'kong09'
'fMRI' %'lui'
'fMRI' %'ruetgen'
'fMRI' %'schenk'
'fMRI' %'theysohn'
'fMRI' %'wager04a_princeton'
'fMRI' %'wager04b_michigan'
'fMRI' %'wrobel'
'ASL'}; %'zeidan'

field_strength=[
1.5 %'atlas'
1.5 %'bingel06'
3.0 %'bingel11'
3.0 %'choi'
3.0 %'eippert'
3.0 %'ellingsen'
1.5 %'elsenbruch'
3.0 %'freeman'
3.0 %'geuter'
3.0 %'kessner'
3.0 %'kong06'
3.0 %'kong09'
3.0 %'lui'
3.0 %'ruetgen'
3.0 %'schenk'
1.5 %'theysohn'
3.0 %'wager04a_princeton'
3.0 %'wager04b_michigan'
3.0 %'wrobel'
3.0]; %'zeidan'

 TR=[
2000 %'atlas'
2600 %'bingel06'
3000 %'bingel11'
3000 %'choi'
2620 %'eippert'
2000 %'ellingsen'
3100 %'elsenbruch'
2000 %'freeman'
2580 %'geuter'
2580 %'kessner'
2000 %'kong06'
2000 %'kong09'
3014 %'lui'
1800 %'ruetgen'
2580 %'schenk'
2400 %'theysohn'
1800 %'wager04a_princeton'
1500 %'wager04b_michigan'
2580 %'wrobel'
4000]; %'zeidan'

 TE=[
34 %'atlas'
40 %'bingel06'
30 %'bingel11'
30 %'choi'
26 %'eippert'
30 %'ellingsen'
50 %'elsenbruch'
40 %'freeman'
26 %'geuter'
26 %'kessner'
40 %'kong06'
40 %'kong09'
35 %'lui'
33 %'ruetgen'
26 %'schenk'
26 %'theysohn'
22 %'wager04a_princeton'
20 %'wager04b_michigan'
25 %'wrobel'
12]; %'zeidan'

voxel_size_at_acq=[
3.5 3.5 4.0 %'atlas'
3.3 3.3 4.0 %'bingel06'
3.5 3.5 3.0 %'bingel11'
3.8 3.8 4.0 %'choi'
2.0 2.0 3.0 %'eippert'
3.0 3.0 3.3 %'ellingsen'
3.8 3.8 3.3 %'elsenbruch'
3.1 3.1 5.0 %'freeman'
2.0 2.0 3.0 %'geuter'
2.0 2.0 3.0 %'kessner'
3.1 3.1 5.0 %'kong06'
3.1 3.1 5.0 %'kong09'
1.9 1.9 3.5 %'lui'
1.5 1.5 2.0 %'ruetgen'
2.0 2.0 2.0 %'schenk'
2.6 2.6 3.0 %'theysohn'
3.8 3.8 5.0 %'wager04a_princeton'
3.0 3.0 4.0 %'wager04b_michigan'
2.0 2.0 3.0 %'wrobel'
3.4 3.4 6.0]; %'zeidan'

voxel_size_img=[
2.0 2.0 2.0 %'atlas'
3.0 3.0 3.0 %'bingel06'
2.0 2.0 2.0 %'bingel11'
2.0 2.0 2.0 %'choi'
2.0 2.0 2.0 %'eippert'
2.0 2.0 2.0 %'ellingsen'
2.0 2.0 2.0 %'elsenbruch'
2.0 2.0 2.0 %'freeman'
2.0 2.0 2.0 %'geuter'
2.0 2.0 2.0 %'kessner'
2.0 2.0 2.0 %'kong06'
2.0 2.0 2.0 %'kong09'
2.0 2.0 2.0 %'lui'
2.0 2.0 2.0 %'ruetgen'
2.0 2.0 2.0 %'schenk'
2.0 2.0 2.0 %'theysohn'
2.0 2.0 2.0 %'wager04a_princeton'
3.75 3.75 5.0 %'wager04b_michigan'
2.0 2.0 2.0 %'wrobel'
2.0 2.0 2.0]; %'zeidan'

analysis_software={
'SPM5' %'atlas'
'SPM2' %'bingel06'
'SPM5' %'bingel11'
'FSL' %'choi'
'SPM5' %'eippert'
'FSL' %'ellingsen'
'SPM5' %'elsenbruch'
'SPM8' %'freeman'
'SPM8' %'geuter'
'SPM8' %'kessner'
'SPM2' %'kong06'
'SPM2' %'kong09'
'SPM5' %'lui'
'SPM12' %'ruetgen'
'SPM8' %'schenk'
'SPM8' %'theysohn'
'SPM99' %'wager04a_princeton'
'SPM99' %'wager04b_michigan'
'SPM8' %'wrobel'
'FSL'}; %'zeidan'

slice_timing_correction=[
1 %'atlas'
0 %'bingel06'
1 %'bingel11'
0 %'choi'
1 %'eippert'
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
0 %'geuter'
1 %'kessner'
0 %'kong06'
0 %'kong09'
1 %'lui'
1 %'ruetgen'
0 %'schenk'
0 %'theysohn'
1 %'wager04a_princeton'
1 %'wager04b_michigan'
1 %'wrobel'
NaN]; %'zeidan'

spatial_smoothing_FWHM=[
8 8 8 %'atlas'
8 8 8 %'bingel06'
8 8 8 %'bingel11'
5 5 5 %'choi'
8 8 8 %'eippert'
5 5 5 %'ellingsen'
9 9 9 %'elsenbruch'
8 8 8 %'freeman'
6 6 6 %'geuter'
8 8 8 %'kessner'
8 8 8 %'kong06'
8 8 8 %'kong09'
4 4 8 %'lui'
6 6 6 %'ruetgen'
6 6 6 %'schenk'
8 8 8 %'theysohn'
6 6 6 %'wager04a_princeton'
9 9 9 %'wager04b_michigan'
8 8 8 %'wrobel'
9 9 9]; %'zeidan'

temporal_high_pass_filter=[
180 %'atlas'
128 %'bingel06'
128 %'bingel11'
50 %'choi'
128 %'eippert'
120 %'ellingsen'
140 %'elsenbruch'
128 %'freeman'
128 %'geuter'
128 %'kessner'
128 %'kong06'
128 %'kong09'
128 %'lui'
128 %'ruetgen'
128 %'schenk'
120 %'theysohn'
128 %'wager04a_princeton'
100 %'wager04b_michigan'
128 %'wrobel'
NaN]; %'zeidan'

image_type={
'beta' %'atlas'
'con' %'bingel06'
'beta' %'bingel11'
'beta' %'choi'
'con' %'eippert'
'con' %'ellingsen'
'beta' %'elsenbruch'
'con' %'freeman'
'con' %'geuter'
'beta' %'kessner'
'con' %'kong06'
'con' %'kong09'
'con' %'lui'
'con' %'ruetgen'
'beta' %'schenk'
'beta' %'theysohn'
'con' %'wager04a_princeton'
'beta' %'wager04b_michigan'
'beta' %'wrobel'
'con'}; %'zeidan'

contrast_imgs_only=[
0 %'atlas'
0 %'bingel06'
0 %'bingel11'
0 %'choi'
0 %'eippert'
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
0 %'geuter'
0 %'kessner'
0 %'kong06'
0 %'kong09'
0 %'lui'
0 %'ruetgen'
0 %'schenk'
0 %'theysohn'
1 %'wager04a_princeton'
0 %'wager04b_michigan'
0 %'wrobel'
1]; %'zeidan'

modeled_stimulus_duration={
14.2 %'atlas'
0.0 %'bingel06'
6.0 %'bingel11'
15.0 %'choi'
[10.0, 10.0] %'eippert' early+late
10.0 %'ellingsen'
31.0 %'elsenbruch'
7.0 %'freeman'
[10.0, 10.0] %'geuter' early+late
[10.0, 10.0] %'kessner' early+late
5.0 %'kong06'
7.0 %'kong09'
0 %'lui'
4.4 %'ruetgen'
20.0 %'schenk'
16.8 %'theysohn'
20.0 %'wager04a_princeton'
6.0 %'wager04b_michigan'
[10.0, 10.0] %'wrobel'
12.0}; %'zeidan'

stimulus_duration=[
10 %'atlas'
0.001 %'bingel06'
6 %'bingel11'
15 %'choi'
17 %'eippert'
10 %'ellingsen'
31 %'elsenbruch'
7 %'freeman'
16 %'geuter'
16 %'kessner'
5 %'kong06'
12 %'kong09'
0.005 %'lui'
0.5 %'ruetgen'
20 %'schenk'
16.8 %'theysohn'
6 %'wager04a_princeton'
17 %'wager04b_michigan'
17 %'wrobel'
12]; %'zeidan'

stim_type={
'contact heat' %'atlas'
'laser' %'bingel06'
'contact heat' %'bingel11'
'electrical' %'choi'
'contact heat' %'eippert'
'contact heat' %'ellingsen'
'rectal distension' %'elsenbruch'
'contact heat' %'freeman'
'contact heat' %'geuter'
'contact heat' %'kessner'
'contact heat' %'kong06'
'contact heat' %'kong09'
'laser' %'lui'
'electrical' %'ruetgen'
'capsaicin & contact heat' %'schenk'
'rectal distension' %'theysohn'
'electrical' %'wager04a_princeton'
'contact heat' %'wager04b_michigan'
'contact heat' %'wrobel'
'contact heat'}; %'zeidan'

stim_location={
'L forearm (v)' %'atlas'
'L & R hand (d)' %'bingel06'
'R calf (d)' %'bingel11'
'L hand (d)' %'choi'
'L forearm (v)' %'eippert'
'L forearm (d)' %'ellingsen'
'C rectal' %'elsenbruch'
'R forearm (v)' %'freeman'
'L forearm (v)' %'geuter'
'L forearm (v)' %'kessner'
'R forearm (v)' %'kong06'
'R forearm (v)' %'kong09'
'L or R foot (d)' %'lui'
'L hand (d)' %'ruetgen'
'L & R forearm (v)' %'schenk'
'C rectal' %'theysohn'
'R forearm (v)' %'wager04a_princeton'
'L forearm (v)' %'wager04b_michigan'
'L forearm (v)' %'wrobel'
'R leg (d)'}; %'zeidan'

placebo_form={
'intravenous drip' %'atlas'
'topical cream/gel/patch' %'bingel06'
'intravenous drip' %'bingel11'
'intravenous drip' %'choi'
'topical cream/gel/patch' %'eippert'
'nasal spray' %'ellingsen'
'intravenous drip' %'elsenbruch'
'topical cream/gel/patch' %'freeman'
'topical cream/gel/patch' %'geuter'
'topical cream/gel/patch' %'kessner'
'sham acupuncture' %'kong06'
'sham acupuncture' %'kong09'
'sham TENS' %'lui'
'pill' %'ruetgen'
'topical cream/gel/patch' %'schenk'
'intravenous drip' %'theysohn'
'topical cream/gel/patch' %'wager04a_princeton'
'topical cream/gel/patch' %'wager04b_michigan'
'topical cream/gel/patch' %'wrobel'
'topical cream/gel/patch'}; %'zeidan'

placebo_induction={
'suggestions' %'atlas'
'suggestions & conditioning' %'bingel06'
'suggestions & conditioning' %'bingel11'
'suggestions & conditioning' %'choi'
'suggestions & conditioning' %'eippert'
'suggestions' %'ellingsen'
'suggestions' %'elsenbruch'
'suggestions & conditioning' %'freeman'
'suggestions & conditioning' %'geuter'
'conditioning' %'kessner' >> within group also suggestions, but the between group contrast only involves conditioning differences
'suggestions & conditioning' %'kong06'
'suggestions & conditioning' %'kong09'
'suggestions & conditioning' %'lui'
'suggestions & conditioning' %'ruetgen'
'suggestions' %'schenk'
'suggestions' %'theysohn'
'suggestions' %'wager04a_princeton'
'suggestions & conditioning' %'wager04b_michigan'
'suggestions & conditioning' %'wrobel'
'suggestions & conditioning'}; %'zeidan'

contrast_ratings_only=[
0 %'atlas'
0 %'bingel06'
0 %'bingel11'
0 %'choi'
0 %'eippert'
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
0 %'geuter'
0 %'kessner'
0 %'kong06'
0 %'kong09'
0 %'lui'
0 %'ruetgen'
0 %'schenk'
0 %'theysohn'
1 %'wager04a_princeton'
1 %'wager04b_michigan'
0 %'wrobel'
1]; %'zeidan'

excluded_conservative_sample=logical([
0 %'atlas'
0 %'bingel06'
1 %'bingel11' due to fixed testing sequence of placebo and control
0 %'choi'
0 %'eippert'
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
0 %'geuter'
0 %'kessner'
1 %'kong06' due to missing data
0 %'kong09'
0 %'lui'
1 %'ruetgen' due to placebo responder selection
0 %'schenk'
0 %'theysohn'
0 %'wager04a_princeton'
1 %'wager04b_michigan' due to placebo responder selection
0 %'wrobel'
1]); %'zeidan' due to missing subjects and since this is the only ASL study

study_citations={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010';...
            'Ruetgen et al. 2015:';...
            'Schenk et al. 2015:';...
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:';...
            'Zeidan et al. 2015:';...
            };
        
study_citations_conservative={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:*';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:**';...
            'Kong et al. 2009:';...
            'Lui et al. 2010:';...
            'Ruetgen et al. 2015:***'
            'Schenk et al. 2015:'
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:***';...
            'Wrobel et al. 2014:'
            'Zeidan et al. 2015:**';...
            };
  %* excluded due to fixed testing sequence
  %** excluded due to incomplete data-set
  %*** excluded due to pre-selection of placebo responders.        
  
  
raw=cell(length(study_ID),1); %placeholder for image data-tables

df=table(study_ID,study_dir,n,study_design,...
      img_modality,field_strength,TR,TE,voxel_size_at_acq,...
      voxel_size_img,slice_timing_correction,temporal_high_pass_filter,spatial_smoothing_FWHM,...
      contrast_imgs_only,image_type,analysis_software,...
      modeled_stimulus_duration,stimulus_duration,stim_type,stim_location,...
      placebo_form, placebo_induction,contrast_ratings_only,...
      raw, excluded_conservative_sample, study_citations,...
      study_citations_conservative);

save(fullfile(datapath,'data_frame.mat'), 'df');
end