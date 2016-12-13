% Print All

% Still to do FSL-Template gives weird results!
%
%t='/Users/matthiaszunhammer/Documents/MATLAB/spm12/canonical/fsl_standards/MNI152_T1_1mm_brain.nii';

t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/avg152T1.nii';
o={'/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/E_Meta_Analysis_SPM/GIV_sig_g_pain_pos.nii',...
   '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/E_Meta_Analysis_SPM/GIV_sig_g_pain_neg.nii'};

plot_nii_results(t,...
                 'overlays',o,... %Cell array of overlay volumes
                 'ov_color',{autumn,winter},... %Cell array of overlay colors (RGB)
                 'slices',[0,0,30],... %Cell array of slices (MNI)
                 'slice_ori',[1,2,3]); %Scalar or array designating slice orientation (x=1,y=2,z=3)
