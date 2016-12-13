clear
cd /Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis
load AllData
tic
path=fileparts(which('Batch_Apply_NPS'));
parent=cd(cd('../Datasets/'));
all_imgs=cellfun(@(x) fullfile(parent, x), df.img, 'UniformOutput',0);
results=apply_nps(all_imgs);
df.NPSraw=[results{:}]';
df.NPScorrected=nps_rescale(df.NPSraw,df.voxelVolMat,df.xSpan,df.conSpan);
%df.Properties.VariableNames{'NPSraw'} = 'NPSraw';
save AllData_w_NPS.mat df
writetable(df,'df.dat','Delimiter','\t');

toc/60, 'Minutes'
