function C2_create_results_tables()

%% Print and label results cluster-wise


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

atlases= {%'Harvard-Oxford Cortical Structural Atlas',...
          'Harvard-Oxford Subcortical Structural Atlas'};%,...
         %'Oxford Thalamic Connectivity Probability Atlas',...
         %'Talairach Daemon Labels',...
         %'Cerebellar Atlas in MNI152 space after normalization with FLIRT'};
         %{'Talairach Daemon Labels',...
         % 'Cerebellar Atlas in MNI152 space after normalization with FLIRT'}; %'Harvard-Oxford Cortical Structural Atlas',...
         
         %
          %','Harvard-Oxford Cortical Structural Atlas'};
satlases={'Hrvrd_Subcort'};%'Hrvrd_Cort', 'Thal','Talairach','Cerebellum'}; % {'Talairach','Cerebellum'}; %'TD', 'HO_cort','HO_subcort','Thalamus','Cerebellum',
%% Read all nii results images, filter thresholded ones
%select images for tables manually
img_path_pperm05={

%%Pain, g's, perm
  '../nii_results/full/pain/g/random/Full_pain_g_pperm_FWE05';

% Placebo, fixed, g's
  '../nii_results/full/pla/g/fixed/Full_pla_g_pperm_FWE05';

% Placebo, fixed, correlations
  '../nii_results/full/pla/rrating/fixed/Full_pla_rrating_pperm_FWE05';

% Placebo, random, g's
  '../nii_results/full/pla/g/random/Full_pla_g_pperm_FWE05';

% Placebo, Random, correlations
  '../nii_results/full/pla/rrating/random/Full_pla_rrating_pperm_FWE05';
 

  };

%% Print tables for p<0.05 permutation test based results
% Tabulate and label results full sample, negative and positive
for k=1:length(atlases)
    for i=1:length(img_path_pperm05)
        curr_img=img_path_pperm05{i};
        curr_img_pos=[curr_img,'_pos.nii'];
        curr_img_neg=[curr_img,'_neg.nii'];
        curr_img_name=strsplit(curr_img,'/');
        curr_img_name=[char(curr_img_name(end)),'_',char(curr_img_name(end-1))];
        if exist(curr_img_pos)==2 %if there is a pos/neg version for the current image
            print_clusters(curr_img_pos,...
                       eps,... %threshold cannot be 0
                       atlases{k},...
                       '../figure_results/temp_pos.txt');
            print_clusters(curr_img_neg,...
                       eps,... %threshold cannot be 0
                       atlases{k},...
                       '../figure_results/temp_neg.txt');

            postbl=refine_cluster_table('../figure_results/temp_pos.txt');
            negtbl=refine_cluster_table('../figure_results/temp_neg.txt');
            outtbl=[postbl;negtbl];
        else
            print_clusters([curr_img,'.nii'],...
                       eps,... %threshold cannot be 0
                       atlases{k},...
                       '../figure_results/temp.txt');
           outtbl=refine_cluster_table('../figure_results/temp.txt');
        end
        if ~isempty(outtbl)
            outtblcells=table2cell(outtbl);
            outtblcells(:,3:7)=cellfun(@(x) sprintf('%0.0f',x), outtblcells(:,3:7),'UniformOutput',0);
            outtblcells(:,8)=cellfun(@(x) sprintf('%0.2f',x), outtblcells(:,8),'UniformOutput',0);
            outtblcells(:,9:11)=cellfun(@(x) sprintf('%0.2f',x), outtblcells(:,9:11),'UniformOutput',0);
            outtblcells(:,12)=cellfun(@(x) sprintf('%0.3f',x), outtblcells(:,12),'UniformOutput',0);
            outtblcells(:,12)=cellfun(@(x) strrep(x,'0.','.'), outtblcells(:,12),'UniformOutput',0);
            outtblcells(:,12)=cellfun(@(x) strrep(x,'^.000','<.001'), outtblcells(:,12),'UniformOutput',0);
            outtxt=cell2table(outtblcells,'VariableNames',outtbl.Properties.VariableNames);

            delete(['../figure_results/',satlases{k},'_',curr_img_name,'.xlsx']); % Otherwise excel files will only be overwritten partially
            writetable(outtxt,['../figure_results/',satlases{k},'_',curr_img_name,'.xlsx']);
        end
    end
end
end