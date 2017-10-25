% Explore Bayes Factor Analysis
clear
load('B1_Full_Sample_Summary_Pain.mat')
load('B1_Full_Sample_Summary_Placebo.mat')
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')
brainmask='../../pattern_masks/brainmask_logical_50.nii';
statmask=df_full_masked.brainmask;
se0={'wb_sd'}; %.01,.05,.1, 0.5,

%% Pain
% Voxel-wise loop needed as bayesfactor function does not work for vectors
y=summary_pain.g.random.summary;
SE_y=summary_pain.g.random.SEsummary;
for j=1:length(se0)
    if isnumeric(se0(j))
        curr_se=se0(j);
    else
        curr_se=nanstd(y);
    end
    B=NaN(size(y));
    for i=1:length(y)
        B(i)=bayesfactor(y(i),SE_y(i),0,[0,curr_se,2],'verbose',0);
    end
    
    bname=matlab.lang.makeValidName(['B_',num2str(curr_se)]);
    summary_pain.g.random.(bname)=B;
    
    outimg=zeros(size(statmask));
    outimg(statmask)=B;
    printImage(outimg,brainmask,['./nii_results/full/pain/g/random/bayes_factor',bname]);

    outimg(statmask)=1./B;
    printImage(outimg,brainmask,['./nii_results/full/pain/g/random/bayes_factor_inv',bname]);
end

%% Placebo treatment RANDOM
y=summary_placebo.g.random.summary;
SE_y=summary_placebo.g.random.SEsummary;
for j=1:length(se0)
    if isnumeric(se0(j))
        curr_se=se0(j);
    else
        curr_se=nanstd(y);
    end
    B=NaN(size(y));
    for i=1:length(y)
        B(i)=bayesfactor(y(i),SE_y(i),0,[0,curr_se,2],'verbose',0);
    end
    
    bname=matlab.lang.makeValidName(['B_',num2str(curr_se)]);
    summary_placebo.g.random.(bname)=B;
    
    outimg=zeros(size(statmask));
    outimg(statmask)=B;
    printImage(outimg,brainmask,['./nii_results/full/pla/g/random/bayes_factor',bname]);

    outimg(statmask)=1./B;
    printImage(outimg,brainmask,['./nii_results/full/pla/g/random/bayes_factor_inv',bname]);
end

%% Placebo treatment FIXED
y=summary_placebo.g.fixed.summary;
SE_y=summary_placebo.g.fixed.SEsummary;
for j=1:length(se0)
    if isnumeric(se0(j))
        curr_se=se0(j);
    else
        curr_se=nanstd(y);
    end
    B=NaN(size(y));
    for i=1:length(y)
        B(i)=bayesfactor(y(i),SE_y(i),0,[0,curr_se,2],'verbose',0);
    end
    
    bname=matlab.lang.makeValidName(['B_',num2str(curr_se)]);
    summary_placebo.g.fixed.(bname)=B;
    
    outimg=zeros(size(statmask));
    outimg(statmask)=B;
    printImage(outimg,brainmask,['./nii_results/full/pla/g/fixed/bayes_factor',bname]);

    outimg(statmask)=1./B;
    printImage(outimg,brainmask,['./nii_results/full/pla/g/fixed/bayes_factor_inv',bname]);
end

%% Placebo correlation RANDOM
% Voxel-wise loop needed as bayesfactor function does not work for vectors
y=r2fishersZ(summary_placebo.r_external.random.summary);
SE_y=n2fisherZse(summary_placebo.r_external.n);
for j=1:length(se0)
    if isnumeric(se0(j))
        curr_se=se0(j);
    else
        curr_se=nanstd(y);
    end
    B=NaN(size(y));
    for i=1:length(y)
        B(i)=bayesfactor(y(i),SE_y(i),0,[0,curr_se,2],'verbose',0);
    end
    
    bname=matlab.lang.makeValidName(['B_',num2str(curr_se)]);
    summary_placebo.g.random.(bname)=B;
    
    outimg=zeros(size(statmask));
    outimg(statmask)=B;
    printImage(outimg,brainmask,['./nii_results/full/pla/rrating/random/bayes_factor',bname]);

    outimg(statmask)=1./B;
    printImage(outimg,brainmask,['./nii_results/full/pla/rrating/random/bayes_factor_inv',bname]);
end

%% Placebo correlation RANDOM
% Voxel-wise loop needed as bayesfactor function does not work for vectors
y=r2fishersZ(summary_placebo.r_external.fixed.summary);
SE_y=n2fisherZse(summary_placebo.r_external.n);
for j=1:length(se0)
    if isnumeric(se0(j))
        curr_se=se0(j);
    else
        curr_se=nanstd(y);
    end
    B=NaN(size(y));
    for i=1:length(y)
        B(i)=bayesfactor(y(i),SE_y(i),0,[0,curr_se,2],'verbose',0);
    end
    
    bname=matlab.lang.makeValidName(['B_',num2str(curr_se)]);
    summary_placebo.g.fixed.(bname)=B;
    
    outimg=zeros(size(statmask));
    outimg(statmask)=B;
    printImage(outimg,brainmask,['./nii_results/full/pla/rrating/fixed/bayes_factor',bname]);

    outimg(statmask)=1./B;
    printImage(outimg,brainmask,['./nii_results/full/pla/rrating/fixed/bayes_factor_inv',bname]);
end