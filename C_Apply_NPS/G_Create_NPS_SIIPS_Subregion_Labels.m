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
    A=load(fullfile(datadir, [runstudies{i},'.mat']),'cl*');
    pos_regions_siips(i,:)=A.clpos_siips;
    neg_regions_siips(i,:)=A.clneg_siips;
    pos_regions_NPS(i,:)=A.clpos_NPS;
    neg_regions_NPS(i,:)=A.clneg_NPS;
end

% Check size and MNI location of all negative clusters: NPS
voxelSizes_neg_NPS=arrayfun(@(x) x.numVox,neg_regions_NPS);
mm_center_x_neg_NPS=arrayfun(@(x) x.mm_center(1),neg_regions_NPS);
mm_center_y_neg_NPS=arrayfun(@(x) x.mm_center(2),neg_regions_NPS);
mm_center_z_neg_NPS=arrayfun(@(x) x.mm_center(3),neg_regions_NPS);

boxplot(voxelSizes_neg_NPS)
boxplot(mm_center_x_neg_NPS)
boxplot(mm_center_y_neg_NPS)
boxplot(mm_center_z_neg_NPS)

% Check size and MNI location of all negative clusters: SIIPS
voxelSizes_neg_siips=arrayfun(@(x) x.numVox,neg_regions_siips);
mm_center_x_neg_siips=arrayfun(@(x) x.mm_center(1),neg_regions_siips);
mm_center_y_neg_siips=arrayfun(@(x) x.mm_center(2),neg_regions_siips);
mm_center_z_neg_siips=arrayfun(@(x) x.mm_center(3),neg_regions_siips);

boxplot(voxelSizes_neg_siips)
boxplot(mm_center_x_neg_siips)
boxplot(mm_center_y_neg_siips)
boxplot(mm_center_z_neg_siips)


% Check size and MNI location of all positive clusters: NPS
voxelSizes_pos_NPS=arrayfun(@(x) x.numVox,pos_regions_NPS);
mm_center_x_pos_NPS=arrayfun(@(x) x.mm_center(1),pos_regions_NPS);
mm_center_y_pos_NPS=arrayfun(@(x) x.mm_center(2),pos_regions_NPS);
mm_center_z_pos_NPS=arrayfun(@(x) x.mm_center(3),pos_regions_NPS);

boxplot(voxelSizes_pos_NPS)
boxplot(mm_center_x_pos_NPS)
boxplot(mm_center_y_pos_NPS)
boxplot(mm_center_z_pos_NPS)

% Check size and MNI location of all positive clusters: SIIPS
voxelSizes_pos_siips=arrayfun(@(x) x.numVox,pos_regions_siips);
mm_center_x_pos_siips=arrayfun(@(x) x.mm_center(1),pos_regions_siips);
mm_center_y_pos_siips=arrayfun(@(x) x.mm_center(2),pos_regions_siips);
mm_center_z_pos_siips=arrayfun(@(x) x.mm_center(3),pos_regions_siips);

boxplot(voxelSizes_pos_siips)
boxplot(mm_center_x_pos_siips)
boxplot(mm_center_y_pos_siips)
boxplot(mm_center_z_pos_siips)


%% NPS Labels as of Wager et al. 2017, Supplementary Table 4
[~,hdr,~]=xlsread(fullfile(datadir,'NPS_Subregion_Labels.xlsx'),'A1:K1');
[num,region,~]=xlsread(fullfile(datadir,'NPS_Subregion_Labels.xlsx'),'A2:K16');

NPS_labels=[table(region),...
        array2table(num,'VariableNames',hdr(2:end))];

save(fullfile(datadir,'NPS_Subregion_labels'),'NPS_labels');



%% SIIPS Labels as of Woo et al. 2017, Supplementary Table 4
[~,hdr,~]=xlsread(fullfile(datadir,'SIIPS_Subregion_Labels.xlsx'),'A1:M1');
[num,region,~]=xlsread(fullfile(datadir,'SIIPS_Subregion_Labels.xlsx'),'A2:M45');

SIIPS_labels=[table(region,'VariableNames',hdr(1)),...
        array2table(num,'VariableNames',hdr(2:end))];
    
%Sort table w labels according to the order of sub-regions in dfs (as provided by apply_NPS) 
MNI_pos_data=[mm_center_x_pos_siips(1,:)', mm_center_y_pos_siips(1,:)', mm_center_z_pos_siips(1,:)'];
MNI_neg_data=[mm_center_x_neg_siips(1,:)', mm_center_y_neg_siips(1,:)', mm_center_z_neg_siips(1,:)'];

MNI_labels=[SIIPS_labels.x,SIIPS_labels.y,SIIPS_labels.z];
[~,order_pos]=ismember(MNI_pos_data,MNI_labels,'rows');
[~,order_neg]=ismember(MNI_neg_data,MNI_labels,'rows');
SIIPS_labels.regionNo_in_paper=[1:length(order_pos),1:length(order_neg)]';
SIIPS_labels=SIIPS_labels([order_pos;order_neg],:);
SIIPS_labels.regionNo_in_data=[1:length(order_pos),1:length(order_neg)]';

save(fullfile(datadir,'SIIPS_Subregion_labels'),'SIIPS_labels');
close all