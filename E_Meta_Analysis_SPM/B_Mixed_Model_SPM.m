datapath='/Volumes/Transcend/Boulder_Essen/Datasets/';
tic
load(fullfile(datapath,'dfMaskedBasicImg.mat'));
toc

%addpath /Applications/MATLAB_R2015b.app/toolbox/stats/stats/

% Temporarily remove spm8 and spm12, since their tcdf does not go well with
% the lmer functions
% rmpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/spm8/'));
% rmpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/spm12/'));

% Display NaN-Voxels (Vertical lines indicate import problems
%imagesc(isnan(Y))
%Y(isnan(Y))=0;

% Make sure that placebo-vector contains 1 and 0 - Values only
df.pla=logical(df.pla);

%Preallcoate
df.y=NaN(height(df),1);
beta_f=NaN(length(Y),2);
stats_f=cell(length(Y),1);
hessian=zeros(length(Y),1);
%Fixed-effects estimates and related statistics, returned as a dataset array that has one row for each of the fixed effects and one column for each of the following statistics.
    %Name	Name of the fixed effect coefficient
    %Estimate	Estimated coefficient value
    %SE	Standard error of the estimate
    %tStat	t-statistic for a test that the coefficient is zero
    %DF	Estimated degrees of freedom for the t-statistic
    %pValue	p-value for the t-statistic
    %Lower	Lower limit of a 95% confidence interval for the fixed-effect coefficient
    %Upper	Upper limit of a 95% confidence interval for the fixed-effect coefficient

% Parpool does not like replacing the y-Vector of a df with every loop.
% Whole table has to be created each loop anew
df1=df(:,[4,5,9]);
tic
parpool
toc

% Supress display of "Hessian" warnings on all workers
pctRunOnAll warning('off','stats:classreg:regr:lmeutils:StandardLinearMixedModel:Message_NotSPDCovarianceNaturalScale');
tic
parfor i=1:round(size(Y,2)/1000)%size(Y,2)
    %stats:classreg:regr:lmeutils:StandardLinearMixedModel:Message_NotSPDCovarianceNaturalScale
    lastwarn(''); %Set last warning to empty
    df2=[df1 table(Y(:,i))]; % First get current voxel into data-frame
    lme = fitlme(df2,'Var1~pla+(1|studyID)+(1|subID)',...
                    'FitMethod','REML',...
                    'CheckHessian',1); %Enable hessian warnings
                    %'Verbose',1,...
                    
    [~,~,stats]=fixedEffects(lme);
    stats_f(i,1)={stats};
    
    if ~strcmp(lastwarn,''); % Record Hessian warnings despite being suppressed for print
    hessian(i)=1;
    end
end
pctRunOnAll warning('on','stats:classreg:regr:lmeutils:StandardLinearMixedModel:Message_NotSPDCovarianceNaturalScale');
toc

delete(gcp('nocreate'))


