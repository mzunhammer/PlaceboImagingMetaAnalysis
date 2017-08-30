clear
datadir='../../Datasets';

runstudies={...
'Atlas_et_al_2012'
'Bingel_et_al_2006'
'Bingel_et_al_2011'
'Choi_et_al_2013'
'Eippert_et_al_2009'
'Ellingsen_et_al_2013'
'Elsenbruch_et_al_2012'
'Freeman_et_al_2015'
'Geuter_et_al_2013'
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

for i=1:length(runstudies)
A=load(fullfile(datadir, [runstudies{i},'.mat']),'*_siips');
pos_regions(i,:)=A.clpos_siips;
neg_regions(i,:)=A.clneg_siips;
end

% Check size and MNI location of all negative clusters
voxelSizes=arrayfun(@(x) x.numVox,neg_regions);
mm_center_x=arrayfun(@(x) x.mm_center(1),neg_regions);
mm_center_y=arrayfun(@(x) x.mm_center(2),neg_regions);
mm_center_z=arrayfun(@(x) x.mm_center(3),neg_regions);

boxplot(voxelSizes)
boxplot(mm_center_x)
boxplot(mm_center_y)
boxplot(mm_center_z)

% Check size and MNI location of all positive clusters
voxelSizes=arrayfun(@(x) x.numVox,pos_regions);
mm_center_x=arrayfun(@(x) x.mm_center(1),pos_regions);
mm_center_y=arrayfun(@(x) x.mm_center(2),pos_regions);
mm_center_z=arrayfun(@(x) x.mm_center(3),pos_regions);

boxplot(voxelSizes)
boxplot(mm_center_x)
boxplot(mm_center_y)
boxplot(mm_center_z)
