%% Print and label results cluster-wise
clear
% Available atlases (see: https://brainder.org/2012/07/30/automatic-atlas-queries-in-fsl/, or atlasquery --dumpatlases)
%     ?Cerebellar Atlas in MNI152 space after normalization with FLIRT?
%     ?Cerebellar Atlas in MNI152 space after normalization with FNIRT?
%     ?Harvard-Oxford Cortical Structural Atlas?
%     ?Harvard-Oxford Subcortical Structural Atlas?
%     ?JHU ICBM-DTI-81 White-Matter Labels?
%     ?JHU White-Matter Tractography Atlas?
%     ?Juelich Histological Atlas?
%     ?MNI Structural Atlas?
%     ?Oxford Thalamic Connectivity Probability Atlas?
%     ?Oxford-Imanova Striatal Connectivity Atlas 3 sub-regions?
%     ?Oxford-Imanova Striatal Connectivity Atlas 7 sub-regions?
%     ?Oxford-Imanova Striatal Structural Atlas?
%     ?Talairach Daemon Labels?

atlases={'Talairach Daemon Labels','Harvard-Oxford Cortical Structural Atlas','Harvard-Oxford Subcortical Structural Atlas'};
satlases={'TD','Hrvrd_Cort','Hrvrd_Subcort'};
%% Read all nii results images, filter thresholded ones
 nii_results=dir('./nii_results/');
 nii_results={nii_results.name}';
% imgs_d001=regexp(nii_results,'(.*_p001\.nii)','tokens');
% imgs_d001=[imgs_d001{:}]';
% imgs_d001=[imgs_d001{:}]';
% [~,imgs_d001,~]=cellfun(@fileparts,imgs_d001,'UniformOutput',0);
% 
% imgs_pperm05=regexp(nii_results,'(.*_pperm05\.nii)','tokens');
% imgs_pperm05=[imgs_pperm05{:}]';
% imgs_pperm05=[imgs_pperm05{:}]';
% [~,imgs_pperm05,~]=cellfun(@fileparts,imgs_pperm05,'UniformOutput',0);

%select tables manually (thresholded Isquare maps for pain contain too many clusters to tabulate)
imgs_pperm05={%'Conservative_pain_g_Isq_pperm05';
 %'Conservative_pain_g_pperm05';
 %'Conservative_pla_g_Isq_pperm05';
 'Conservative_pla_g_pperm05';
 %'Conservative_pla_rrating_Isq_pperm05';
 'Conservative_pla_rrating_pperm05';
 %'Full_pain_g_Isq_pperm05';
 'Full_pain_g_pperm05';
 %'Full_pla_g_Isq_pperm05';
 'Full_pla_g_pperm05';
 %'Full_pla_rrating_Isq_pperm05';
 'Full_pla_rrating_pperm05'};

%% Print tables for p<0.05 permutation test based results
% Tabulate and label results full sample, negative and positive
for k=1:length(atlases)
    for i=1:length(imgs_pperm05)
        curr_img=imgs_pperm05{i};
        curr_img_pos=[curr_img,'_pos.nii'];
        curr_img_neg=[curr_img,'_neg.nii'];
        if any(strcmp(nii_results,curr_img_pos)) %if there is a pos/neg version for the current image
            print_clusters(fullfile('./nii_results/',curr_img_pos),...
                       eps,... %threshold cannot be 0
                       atlases{k},...
                       './figure_results/temp_pos.txt');
            print_clusters(fullfile('./nii_results/',curr_img_neg),...
                       eps,... %threshold cannot be 0
                       atlases{k},...
                       './figure_results/temp_neg.txt');

            postbl=refine_cluster_table('./figure_results/temp_pos.txt');
            negtbl=refine_cluster_table('./figure_results/temp_neg.txt');
            outtbl=[postbl;negtbl];
        else
            print_clusters(fullfile('./nii_results/',curr_img),...
                       eps,... %threshold cannot be 0
                       atlases{k},...
                       './figure_results/temp.txt');
           outtbl=refine_cluster_table('./figure_results/temp.txt');
        end
        outtblcells=table2cell(outtbl);
        outtblcells(:,3:7)=cellfun(@(x) sprintf('%0.0f',x), outtblcells(:,3:7),'UniformOutput',0);
        outtblcells(:,8)=cellfun(@(x) sprintf('%0.0f%%',x), outtblcells(:,8),'UniformOutput',0);
        outtblcells(:,9:11)=cellfun(@(x) sprintf('%0.2f',x), outtblcells(:,9:11),'UniformOutput',0);
        outtblcells(:,12)=cellfun(@(x) sprintf('%0.3f',x), outtblcells(:,12),'UniformOutput',0);
        outtblcells(:,12)=cellfun(@(x) strrep(x,'0.','.'), outtblcells(:,12),'UniformOutput',0);
        outtblcells(:,12)=cellfun(@(x) strrep(x,'.000','<.001'), outtblcells(:,12),'UniformOutput',0);
        outtxt=cell2table(outtblcells,'VariableNames',outtbl.Properties.VariableNames);

        writetable(outtxt,['./figure_results/',satlases{k},'_',curr_img,'.xlsx']);
    end
end
