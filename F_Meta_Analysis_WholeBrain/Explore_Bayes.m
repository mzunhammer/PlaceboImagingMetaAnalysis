% Explore Bayes Factor Analysis
clear
load('B1_Full_Sample_Summary_Pain.mat')
load('B1_Full_Sample_Summary_Placebo.mat')
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')
brainmask='../../pattern_masks/brainmask_logical_50.nii';
statmask=df_full_masked.brainmask;
se0=[.005,.01,.05,.1,.5, 5, 10];

%% Pain
% Voxel-wise loop needed as bayesfactor function does not work for vectors
y=summary_pain.g.random.summary;
SE_y=summary_pain.g.random.SEsummary;
for j=1:length(se0)
    B=NaN(size(y));
    for i=1:length(y)
        B(i)=bayesfactor(y(i),SE_y(i),0,[0,se0(j),2],'verbose',0);
    end
    
    bname=matlab.lang.makeValidName(['B_',num2str(se0(j))]);
    summary_pain.g.random.(bname)=B;
    
    outimg=zeros(size(statmask));
    outimg(statmask)=B;
    printImage(outimg,brainmask,['./nii_results/full/pain/g/random/bayes_factor',bname]);

    outimg(statmask)=1./B;
    printImage(outimg,brainmask,['./nii_results/full/pain/g/random/bayes_factor_inv',bname]);
end

%% Placebo treatment
y=summary_placebo.g.random.summary;
SE_y=summary_placebo.g.random.SEsummary;
for j=1:length(se0)
    B=NaN(size(y));
    for i=1:length(y)
        B(i)=bayesfactor(y(i),SE_y(i),0,[0,se0(j),2],'verbose',0);
    end
    
    bname=matlab.lang.makeValidName(['B_',num2str(se0(j))]);
    summary_placebo.g.random.(bname)=B;
    
    outimg=zeros(size(statmask));
    outimg(statmask)=B;
    printImage(outimg,brainmask,['./nii_results/full/pla/g/random/bayes_factor',bname]);

    outimg(statmask)=1./B;
    printImage(outimg,brainmask,['./nii_results/full/pla/g/random/bayes_factor_inv',bname]);
end

%% Placebo correlation
% Voxel-wise loop needed as bayesfactor function does not work for vectors
y=r2fishersZ(summary_placebo.r_external.random.summary);
SE_y=n2fisherZse(summary_placebo.r_external.n);
for j=1:length(se0)
    B=NaN(size(y));
    for i=1:length(y)
        B(i)=bayesfactor(y(i),SE_y(i),0,[0,se0(j),2],'verbose',0);
    end
    
    bname=matlab.lang.makeValidName(['B_',num2str(se0(j))]);
    summary_placebo.g.random.(bname)=B;
    
    outimg=zeros(size(statmask));
    outimg(statmask)=B;
    printImage(outimg,brainmask,['./nii_results/full/pla/rrating/random/bayes_factor',bname]);

    outimg(statmask)=1./B;
    printImage(outimg,brainmask,['./nii_results/full/pla/rrating/random/bayes_factor_inv',bname]);
end