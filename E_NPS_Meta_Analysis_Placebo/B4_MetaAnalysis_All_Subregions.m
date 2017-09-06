%% Meta-Analysis & Plots For NPS and SIIPS Subregions (Full Sample)
clear
% Add folder with Generic Inverse Variance Methods Functions first
datadir='../../Datasets';
addpath('../A_Analysis_GIV_Functions/');
load('A1_Full_Sample.mat');
load(fullfile(datadir,'NPS_Subregion_labels.mat'));
load(fullfile(datadir,'SIIPS_Subregion_labels.mat'));

% !!!!! These must be in the same order as listed under "studies" !!!!
studyIDtexts={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010';...
            'Ruetgen et al. 2015:';...
            'Schenk et al. 2015:';...
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:';...
            'Zeidan et al. 2015:';...
            };

%% One Analysis and Forrest plot per NPS Sub-Region
varnames={'NPS_Pos_Region1_Region001'
        'NPS_Pos_Region2_Region002'
        'NPS_Pos_Region3_Region003'
        'NPS_Pos_Region4_Region004'
        'NPS_Pos_Region5_Region005'
        'NPS_Pos_Region6_Region006'
        'NPS_Pos_Region7_Region007'
        'NPS_Pos_Region8_Region008'
        'NPS_Neg_Region1_Region001'
        'NPS_Neg_Region2_Region002'
        'NPS_Neg_Region3_Region003'
        'NPS_Neg_Region4_Region004'
        'NPS_Neg_Region5_Region005'
        'NPS_Neg_Region6_Region006'
        'NPS_Neg_Region7_Region007'};

summary=[];

for j=1:numel(varnames)
    v=find(strcmp(df_full.variables,varnames(j)));
    for i=1:length(df_full.studies) % Calculate for all studies except...
        if df_full.consOnlyNPS(i)==0 %...data-sets where both pla and con is available
            if df_full.BetweenSubject(i)==0 %Within-subject studies
               stats.(varnames{j})(i)=withinMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
            elseif df_full.BetweenSubject(i)==1 %Between-subject studies
               stats.(varnames{j})(i)=betweenMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
            end        
        end
    end
    % Calculate for those studies where only pla>con contrasts are available
    conOnly=find(df_full.consOnlyNPS==1);
    impu_r=nanmean([stats.(varnames{j}).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=conOnly'
    stats.(varnames{j})(i)=withinMetastats(df_full.pladata{i}(:,v),impu_r);
    end
end

% for i = 1:numel(varnames)
%     summary.(varnames{i})=ForestPlotter([stats.(varnames{i})],...
%                   'studyIDtexts',studyIDtexts,...
%                   'outcomelabel',[varnames{i},' (Hedges'' g)'],...
%                   'type','random',...
%                   'summarystat','g',...
%                   'withoutlier',0,...
%                   'WIsubdata',0,...
%                   'boxscaling',1,...
%                   'textoffset',0);
%     pubpath='../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/NPS_subregions';
%     hgexport(gcf, fullfile(pubpath,['B1_Meta_All_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
%     hgexport(gcf, fullfile(pubpath,['B1_Meta_All_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
%     crop(fullfile(pubpath,['B1_Meta_All_',varnames{i},'.png']));
%     close all;
% end

for i = 1:numel(varnames)
    summary.(varnames{i})=GIVsummary(stats.(varnames{i}));
end

% Plot subregions side by side
g=structfun(@(x) x.g.random.summary,summary);
CI_g=structfun(@(x) x.g.random.SEsummary,summary).*1.96;

miny=floor(min(g-CI_g)*100)/100;
maxy=ceil(max(g+CI_g)*100)/100;

miny=max([abs(miny),abs(maxy)])*(-1);
maxy=max([abs(miny),abs(maxy)]);

figure
errorbar(g,CI_g,'o')

axis([0, numel(varnames)+1, miny, maxy]);
xticks(1:numel(varnames))
xtickangle(45)
% Instead of the varnames from apply_nps use the labels taken from the
% Wager 2013 paper. (NPS_labels was already sorted to match the order of regions in the df)
xticklabels(NPS_labels.region);
h=refline(0,0);
h.Color='k';

h=rectangle('FaceColor',[255,220,200]./255,...
            'LineStyle','none',...
            'Position',[0 miny 8.5 maxy-miny]);
uistack(h,'bottom') % send rectangle to bottom
h=rectangle('FaceColor',[240,248,255]./255,...
            'LineStyle','none',...
            'Position',[8.5 miny 15 maxy-miny]);
uistack(h,'bottom'); % send rectangle to bottom
set(gca,'layer','top'); % put axes on top

text(0.05,0.9,...
     'Positive weights',...
     'Position',[],...
     'Color',[127,64,64]./255,...
     'Units','normalized',...
     'HorizontalAlignment', 'left');
text(0.95,0.9,...
     'Negative weights',...
     'Color',[64,64,127]./255,...
     'Units','normalized',...
     'HorizontalAlignment', 'right');

hgexport(gcf, '../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/NPS_subregions', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, '../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/NPS_subregions', hgexport('factorystyle'), 'Format', 'png');
crop('../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/NPS_subregions.png');
%% One Analysis and Forrest plot per Sub-Variable
varnames={  'SIIPS_Pos_Region1_LCB'
            'SIIPS_Pos_Region2_CB_vermis_'
            'SIIPS_Pos_Region3_RCB'
            'SIIPS_Pos_Region4_RMTG'
            'SIIPS_Pos_Region5_RSN'
            'SIIPS_Pos_Region6_RMid_dpINS'
            'SIIPS_Pos_Region7_LAINS'
            'SIIPS_Pos_Region8_RVlPFC'
            'SIIPS_Pos_Region9_LCOp'
            'SIIPS_Pos_Region10_RCOp'
            'SIIPS_Pos_Region11_LMidINS'
            'SIIPS_Pos_Region12_LDpINS'
            'SIIPS_Pos_Region13_LThal'
            'SIIPS_Pos_Region14_LCaud'
            'SIIPS_Pos_Region15_RCaud'
            'SIIPS_Pos_Region16_dmPFC'
            'SIIPS_Pos_Region17_MCC_SMA'
            'SIIPS_Pos_Region18_RPrecen'
            'SIIPS_Pos_Region19_LPrecu'
            'SIIPS_Pos_Region20_RSPL'
            'SIIPS_Pos_Region21_LSPL'
            'SIIPS_Neg_Region1_LTP'
            'SIIPS_Neg_Region2_LHC_PHC'
            'SIIPS_Neg_Region3_RTP'
            'SIIPS_Neg_Region4_RHC'
            'SIIPS_Neg_Region5_LTP'
            'SIIPS_Neg_Region6_vmPFC'
            'SIIPS_Neg_Region7_LNAc'
            'SIIPS_Neg_Region8_RLG'
            'SIIPS_Neg_Region9_RSTG'
            'SIIPS_Neg_Region10_LMTG'
            'SIIPS_Neg_Region11_RNAc'
            'SIIPS_Neg_Region12_RCun'
            'SIIPS_Neg_Region13_LSTG'
            'SIIPS_Neg_Region14_LMOG'
            'SIIPS_Neg_Region15_LDlPFC'
            'SIIPS_Neg_Region16_RDlPFC'
            'SIIPS_Neg_Region17_RS2'
            'SIIPS_Neg_Region18_RSMC'
            'SIIPS_Neg_Region19_RPrecu'
            'SIIPS_Neg_Region20_LSMC'
            'SIIPS_Neg_Region21_LSPL'
            'SIIPS_Neg_Region22_MidPrecen'
            'SIIPS_Neg_Region23_LPrecu'};

summary=[];

for j=1:numel(varnames)
    v=find(strcmp(df_full.variables,varnames(j)));
    for i=1:length(df_full.studies) % Calculate for all studies except...
        if df_full.consOnlyNPS(i)==0 %...data-sets where both pla and con is available
            if df_full.BetweenSubject(i)==0 %Within-subject studies
               stats.(varnames{j})(i)=withinMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
            elseif df_full.BetweenSubject(i)==1 %Between-subject studies
               stats.(varnames{j})(i)=betweenMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
            end        
        end
    end
    % Calculate for those studies where only pla>con contrasts are available
    conOnly=find(df_full.consOnlyNPS==1);
    impu_r=nanmean([stats.(varnames{j}).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=conOnly'
    stats.(varnames{j})(i)=withinMetastats(df_full.pladata{i}(:,v),impu_r);
    end
end
% 
% for i = 1:numel(varnames)
%     summary.(varnames{i})=ForestPlotter([stats.(varnames{i})],...
%                   'studyIDtexts',studyIDtexts,...
%                   'outcomelabel',[varnames{i},' (Hedges'' g)'],...
%                   'type','random',...
%                   'summarystat','g',...
%                   'withoutlier',0,...
%                   'WIsubdata',0,...
%                   'boxscaling',1,...
%                   'textoffset',0);
%     pubpath='../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/SIIPS_subregions';
%     hgexport(gcf, fullfile(pubpath,['B1_Meta_All_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
%     hgexport(gcf, fullfile(pubpath,['B1_Meta_All_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
%     crop(fullfile(pubpath,['B1_Meta_All_',varnames{i},'.png']));
%     close all;
% end
for i = 1:numel(varnames)
    summary.(varnames{i})=GIVsummary(stats.(varnames{i}));
end

% Plot subregions side by side
g=structfun(@(x) x.g.random.summary,summary);
CI_g=structfun(@(x) x.g.random.SEsummary,summary).*1.96;

miny=floor(min(g-CI_g)*100)/100;
maxy=ceil(max(g+CI_g)*100)/100;

miny=max([abs(miny),abs(maxy)])*(-1);
maxy=max([abs(miny),abs(maxy)]);

figure
errorbar(g,CI_g,'o')

axis([0, numel(varnames)+1, miny, maxy]);
xticks(1:numel(varnames))
xtickangle(45)
xticklabels(SIIPS_labels.region)
refline(0,0)

h=rectangle('FaceColor',[255,220,200]./255,...
            'LineStyle','none',...
            'Position',[0 miny 21.5 maxy-miny])
uistack(h,'bottom') % send rectangle to bottom
h=rectangle('FaceColor',[240,248,255]./255,...
            'LineStyle','none',...
            'Position',[21.5 miny length(varnames) maxy-miny])
uistack(h,'bottom') % send rectangle to bottom
set(gca,'layer','top') % put axes on top

text(0.05,0.9,...
     'Positive weights',...
     'Position',[],...
     'Color',[127,64,64]./255,...
     'Units','normalized',...
     'HorizontalAlignment', 'left');
text(0.95,0.9,...
     'Negative weights',...
     'Color',[64,64,127]./255,...
     'Units','normalized',...
     'HorizontalAlignment', 'right');

%Increase figure size 
figsize=get(gcf,'Position');
set(gcf,'Position',[figsize(1:2),figsize(3)*1.5,figsize(4)])
hgexport(gcf, '../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/SIIPS_subregions', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, '../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/SIIPS_subregions', hgexport('factorystyle'), 'Format', 'png');
crop('../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/SIIPS_subregions.png');



close all