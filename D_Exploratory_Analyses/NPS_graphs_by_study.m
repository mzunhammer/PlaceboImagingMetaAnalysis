%% Graph NPS Results


%Load Data
clear
basepath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis';
cd(basepath)
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets';
load(fullfile(datapath,'AllData.mat'))


% Throw out Kessner's anticipation data, they are not on the same scale
%df=df(~(strcmp(df.studyID,'kessner')&(df.pain==0)),:);

% Optional: Throw out all early pain data,
%df=df(~(df.pain==2),:);


%Basic Graphing Features
h_px=1024;
font_size=14;
font_name='Arial';

%Graph dimensions (optimally the same for all studies for comparability)
max_n_cond=8;
min_nps=-2;
max_nps=15;
%Appearance of lines representing mean
line_length_means=0.05;

%Appearance of lines representing error
line_width=5;


%Graph each study separately
studies=unique(df.studyID);
for i=15%:length(studies)
    
    % Get data for current study
    curr_table=df(strcmp(df.studyID,studies(i)),:);

    % Get conditions for current study
    conditions=unique(curr_table.cond);
    ncond=length(conditions);
    ctext=cellfun(@(x) strsplit(x,'_'),conditions,'UniformOutput',0);
%     ctext=cellfun(@(x) [x{:}],ctext);
    
    % Generate figure window for current study
    fig=figure('Name',[studies{i},'NPS'],...
        'Position', [0, 0, h_px/sqrt(2), h_px])% Position: left bottom width heigth
    hold on
    
    % Calculate by-condition stats for graphing
    X=[];
    for j=1:ncond
    curr_data=curr_table.MHEraw(strcmp(curr_table.cond,conditions(j)));
    meanNPS=nanmean(curr_data);
    errbar=nanstd(curr_data)/sqrt(length(curr_data))*1.96;
    
    % Plot single data-points
    plot(j,curr_data,'.')
    
    % Plot lines for mean and error
    line([j-line_length_means j+line_length_means],[meanNPS meanNPS],'LineWidth',line_width);
    line([j j],[meanNPS-errbar meanNPS+errbar],'LineWidth',line_width);
    %X=[X, curr_data]
    end
    %boxplot(X)
       % Graph properties
    ax=gca;
      ax=gca;
    set(ax,'box','off',...
        'Xlim',[0 (length(conditions)+1)],...
        'Xtick',1:length(conditions),...
        'xticklabel', [],...%'Ylim', [min_nps max_nps],...
        'color','none',...
        'FontSize',font_size*0.75,...
        'FontName',font_name)
    
    
    % Labels
    
        ylabel('NPS response (arbitrary units +- 95%CI)');
    
        yTicks = get(gca,'ytick');
        xTicks = get(gca, 'xtick');
        minY = min(yTicks);
        minX = min(xTicks);
        VerticalOffset = (max(yTicks)-minY)*0.01;
        HorizontalOffset = 0.2;
        text(xTicks,...
            repmat(minY - VerticalOffset,size(xTicks)),...
            ctext,...
            'HorizontalAlignment','center',...
            'VerticalAlignment','top',...
            'FontSize',font_size*0.75,...
            'FontName',font_name);
        OuterPosition=get(gca,'OuterPosition');
        set(gca,'OuterPosition',[OuterPosition(1) OuterPosition(2)+0.1 OuterPosition(3) OuterPosition(4)-0.2]) % Correct outer Figure borders, MATLAB2014 bug cuts of labels otherwise
    %saveas(fig,[basepath,'/Graphs/',studies{i},'.jpeg']);
    refline(0,0);%add a line through 0
    hold off
end