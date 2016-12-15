%% Graph NPS Results
%Load Data
clear
basepath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis';
cd(basepath)
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets';
load(fullfile(datapath,'AllData_w_NPS_MHE.mat'))

% Basic Graphing Features
h_px=1024;
font_size=15;
font_name='Arial';

studies=unique(df.studyID);
%% Histograms by study, only for pain

for i=1:length(studies)
   istudyID=strcmp(df.studyID,studies(i))& logical(df.pain);
   figure('name',[studies{i}],'Position', [0, 0, h_px, h_px]);
   histogram(df.NPScorrected(istudyID),10);
   k(i)=kurtosis(df.NPScorrected(istudyID));
end

% Freeman includes High-pain-low pain contrasts that skew the comparison...
histogram(df.NPScorrected(strcmp(df.studyID,'freeman')&strcmp(df.cond,'pain_post')),10);

   figure('name','Kurtosis','Position', [0, 0, h_px, h_px]);
   histogram(k);
%% Histograms for all datasets
for i=1:length(studies)
   istudyID=strcmp(df.studyID,studies(i)); 
   conditions=unique(df.cond(istudyID));
   for j=1:length(conditions)
   iscond=strcmp(df.cond,conditions(j));
   istudyIDcond=istudyID & iscond;
   figure('name',[studies{i}, conditions{j}])
        histogram(df.NPScorrected(istudyIDcond),10)
    end
end

%% Boxplots by study, only for pain

for i=1:length(studies)
   istudyID=strcmp(df.studyID,studies(i))& logical(df.pain);
   figure('name',[studies{i}],'Position', [0, 0, h_px, h_px])
   boxplot(df.NPScorrected(istudyID),'jitter',0.1);
end

%% Boxplots by study and condition
for i=1:length(studies)
   istudyID=strcmp(df.studyID,studies(i)); 
   conditions=unique(df.cond(istudyID));
   for j=1:length(conditions)
   iscond=strcmp(df.cond,conditions(j));
   istudyIDcond=istudyID & iscond;
   figure('name',[studies{i}, conditions{j}],'Position', [0, 0, h_px, h_px])
   boxplot(df.NPScorrected(istudyIDcond),'jitter',0.1);
    end
end

