clc
clear

%Run all single summaries, adds images to df.raw
impFolder='./A_summarize_inappropriate_conditions/';
%run([impFolder,'summarize_atlas.m'])
run([impFolder,'summarize_bingel06.m'])
run([impFolder,'summarize_choi.m'])
run([impFolder,'summarize_eippert.m'])
run([impFolder,'summarize_geuter.m'])
run([impFolder,'summarize_schenk.m'])
run([impFolder,'summarize_wrobel.m'])

