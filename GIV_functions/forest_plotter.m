function summary=ForestPlotter(MetaStats,varargin)

%% Function to create Forest Plots for meta-analysis
% by Matthias Zunhammer November 2016

% General form: ForestPlotter(MetaStats,varargin)
% Required arguments:
% 'MetaStats': a struct containing i by-study meta-analysis-results, as
% created by withinMetastats.m or betweenMetastats.m
%
% Optional arguments:
%studyIDtexts: vector with i study labels.
%outcomelabel: string lableing the x-axis.
%summarystat: string designating the desired outcome ('mu' for mean, 'd' or Cohen's d, 'g' for Hedges' g).
%type: String indicating whether 'fixed' or 'random' analysis is desired.
%fontsize: Double indicating the size of study text.
%textoffset: Scalar indicating whether additional distance between study
%info and graph is desired. Unit is "width of x-axis", so 0.5 will add half
%of the x-axis width.
%boxscaling: Scalar indicating how study weight and box-size relate: box
%size = one y-unit * weight
%printwidth: Two-element numeric vector indicating the desired with of image in px [x,y].
%Xscale: Scalar indicating the maximum scale value for X
%Example:
% ForestPlotter(stats,studyIDtexts,'NPS-Response (Hedge''s g)','random','g');


%% Parse optional inputs according to: https://de.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
p = inputParser;
%Check MetaStats 
addRequired(p,'MetaStats',@isstruct);
%Check studyIDtexts
defstudyIDtexts = {};
addParameter(p,'studyIDtexts',defstudyIDtexts,@iscell);
%Check outcomelabel
defOutcomelabel = 'Outcome';
addParameter(p,'outcomelabel',defOutcomelabel,@ischar);
%Check type
defType = 'random';
addParameter(p,'type',defType,@ischar);
%Check type
defSummarystat = 'g';
addParameter(p,'summarystat',defSummarystat,@ischar);
%Check fontsize
defFontsize=16; % Negative number will later be replaced by no change in resolution
addParameter(p,'fontsize',defFontsize,@isnumeric);
%Check textoffset (currently automatically determined)
deftextoffset=0; % Negative number will later be replaced by no change in resolution
addParameter(p,'textoffset',deftextoffset,@isnumeric);
%Check boxscaling
defBoxscaling=1; %
addParameter(p,'boxscaling',defBoxscaling,@isnumeric);   % basic unit is y (height of a study-line)
%Check printwidth
defprintwidth=1200; % printwidth in px, note that this may not surpass the maximum display size set by the system
addParameter(p,'printwidth',defprintwidth,@isnumeric);
%Check Withoutlier
defWithoutlier = 1;
addParameter(p,'withoutlier',defWithoutlier,@isnumeric);
%Check WIsubdata
defWIsubdata = 1;
addParameter(p,'WIsubdata',defWIsubdata,@isnumeric);
%Supress summary
defNOsummary = 0;
addParameter(p,'NOsummary',defNOsummary,@isnumeric);
%Xscale 
defXscale = NaN;%per default the scale is chosen based on the largest absolute single subject value: round(max(abs(val))).
addParameter(p,'Xscale',defXscale,@isnumeric);

parse(p,MetaStats,varargin{:});
% Re-format inputs for convenience
MetaStats=p.Results.MetaStats;
studyIDtexts=p.Results.studyIDtexts;
outcomelabel=p.Results.outcomelabel;
type=p.Results.type;
summarystat=p.Results.summarystat;
fontsize=p.Results.fontsize;
printwidth=p.Results.printwidth;
withoutlier=p.Results.withoutlier;
WIsubdata=p.Results.WIsubdata;
textoffset=p.Results.textoffset;
boxscaling=p.Results.boxscaling;
NOsummary=p.Results.NOsummary;
Xscale=p.Results.Xscale;

%% Summarize all studies, weighted by se_summary_total
% Summarize standardized using the generic inverse-variance weighting method
summary=GIVsummary(MetaStats,summarystat);

% Select the desired statistics
if strcmp(summarystat,'mu')
        short_summary= summary.mu;
        eff=vertcat(MetaStats.mu);
        n=vertcat(MetaStats.n);
        se_eff=vertcat(MetaStats.se_mu);
        ciLo=eff-se_eff.*1.96;
        ciHi=eff+se_eff.*1.96;
    elseif strcmp(summarystat,'d')
        short_summary= summary.d;
        eff=vertcat(MetaStats.d);
        n=vertcat(MetaStats.n);
        se_eff=vertcat(MetaStats.se_d);
        ciLo=eff-se_eff.*1.96;
        ciHi=eff+se_eff.*1.96;
    elseif strcmp(summarystat,'g')
        short_summary= summary.g;
        eff=vertcat(MetaStats.g);
        n=vertcat(MetaStats.n);
        se_eff=vertcat(MetaStats.se_g);
        ciLo=eff-se_eff.*1.96;
        ciHi=eff+se_eff.*1.96;
    elseif strcmp(summarystat,'r') 
        short_summary= summary.r;
        eff=vertcat(MetaStats.r);
        n=vertcat(MetaStats.n);
        se_eff_Z=sqrt(1./(n-3)); % SE for FISHER's
        ciLo_Z=r2fishersZ(eff)-se_eff_Z.*1.96;
        ciHi_Z=r2fishersZ(eff)+se_eff_Z.*1.96;
        ciLo=fishersZ2r(ciLo_Z);
        ciHi=fishersZ2r(ciHi_Z);
    elseif strcmp(summarystat,'ICC') 
        short_summary= summary.ICC;
        eff=vertcat(MetaStats.ICC);
        n=vertcat(MetaStats.n);
        se_eff_Z=sqrt(1./(n-3)); % SE for FISHER's
        ciLo_Z=r2fishersZ(eff)-se_eff_Z.*1.96;
        ciHi_Z=r2fishersZ(eff)+se_eff_Z.*1.96;
        ciLo=fishersZ2r(ciLo_Z);
        ciHi=fishersZ2r(ciHi_Z);
    elseif strcmp(summarystat,'r_external')        
        short_summary= summary.r_external;
        eff=vertcat(MetaStats.r_external);
        n=vertcat(MetaStats.n_r_external);
        se_eff_Z=sqrt(1./(n-3)); % SE for FISHER's
        ciLo_Z=r2fishersZ(eff)-se_eff_Z.*1.96;
        ciHi_Z=r2fishersZ(eff)+se_eff_Z.*1.96;
        ciLo=fishersZ2r(ciLo_Z);
        ciHi=fishersZ2r(ciHi_Z);
end

chisq=short_summary.heterogeneity.chisq;
p_het=short_summary.heterogeneity.p_het;
Isq=short_summary.heterogeneity.Isq;

if strcmp(type,'fixed')
    tausq=[];
    short_summary=short_summary.fixed;
elseif strcmp(type,'random')
    tausq=short_summary.heterogeneity.tausq;
    short_summary=short_summary.random;
end

df=short_summary.df;
rel_weight=vertcat(short_summary.rel_weight);
summary_total=short_summary.summary;
z=short_summary.z;
p=short_summary.p;
summary_ciLo=short_summary.CI_lo;
summary_ciHi=short_summary.CI_hi;



%% Forest Plot
%FIGURE WINDOW
figure_width=printwidth;
lineheight=printwidth/12;
figure_height=(length(studyIDtexts)+2)*lineheight;%figure height is defined as: (number of lines +one line for summary and one line for head)*line scaling

figure('Name','Forest Plot',...
        'Position', [0, 0, figure_width, figure_height],...
        'Units','pixels');% Position: left bottom width heigth;
hold on

%TEXT POSITION AND SIZE
font_size=fontsize;
font_name='Arial';

%SIZE OF GRAPH AREA VS TEXT
x_graphW=0.3333333; %relative size of x-axis in normalized space (rel to the whole graph)
    
%AXIS SCALE
if isnan(Xscale)
    if ~WIsubdata % no-single subj data-points >> scale x-axis to max(summary?CI) but at least Xscale
        x_axis_size=double(ceil(max(abs([ciLo;ciHi]))));
    elseif WIsubdata && withoutlier % single subj data-points (for WI-studies), yet points beyond max(summary?CI) not plotted > outliermarks instead
        x_axis_size=double(ceil(max(abs([ciLo;ciHi])))); 
    elseif WIsubdata && ~withoutlier % plot full range of wi-single subj data. x-axis are scaled to max(abs(indiv datapoint))
        x_axis_size=double(ceil(max(abs(vertcat(MetaStats.std_delta))))); 
    end    
else
    x_axis_size=Xscale;
end
if strcmp(summarystat,'r')|strcmp(summarystat,'ICC')
    x_axis_size=1;
end

y_axis_size=(length(studyIDtexts)+2);
if NOsummary
    y_axis_size=y_axis_size-1;
end

ax=gca;
set(ax,'box','off',...
 'ActivePositionProperty','position',...
 'OuterPosition',[x_graphW 0 x_graphW 0.9],...% Set outer figure borders to accomodate more text, Default: [left bottom width height], [0 0 1 1], in normalized units
 'Ylim',[0 y_axis_size],...
 'YTick',[],...
 'YTickLabel',[],...%
 'YColor','none',...
 'Xlim', [-x_axis_size x_axis_size],...
 'color','none',...
 'FontSize',font_size*0.90,...
 'FontName',font_name);
 xlabel({[outcomelabel,' with 95% CI; IV, ',type]});
 
 yscale=diff(get(ax,'Ylim'));
 set(gca,'DataAspectRatioMode','auto'); %https://de.mathworks.com/help/matlab/ref/axes-properties.html#prop_DataAspectRatio
 %set(gca,'DataAspectRatio',[1,figure_height/figure_width,1]);
 set(gca,'PlotBoxAspectRatioMode','manual'); %https://de.mathworks.com/help/matlab/ref/axes-properties.html#prop_DataAspectRatio
 set(gca,'PlotBoxAspectRatio',[1,figure_height/figure_width,1]);

 AR=get(gca, 'DataAspectRatio');
 xy_rel=(AR(1))/(AR(2)); %get relative size of axis in axis space, adding one to each, since we are counting the steps on the scale, not the difference of maxima!

% LINE APPEARANCE
 line_width=1;
 % Plot y-Axis
 line([0 0],[0 y_axis_size],'LineWidth',line_width/2, 'Color',[0 0 0]);

% SINGLE SUBJECT DOT APPEARANCE
 dot_size=8;
 dot_color=[.5 .5 .5];
 
%STUDY BOXES
%Sizing of all boxes shold represent study weight
studyIDweight=rel_weight; % get study weights from summary
 
% STUDY LABELS AND N'S

%Get left outer border of graph in data-units
ax_pos_norm = get(gca, 'Position'); % Get axis positition & size [left, bottom, width, heigth] in NORMALIZED units
%ax_pos_norm(1) Corresponds to x position of the left end of x_axis .
%Cax_pos_norm(3) orresponds to width of x axis in normalized figure units and therefore to x_axis_size*2
ori_times_axis=ax_pos_norm(1)/ax_pos_norm(3)*(-1); %"origin in times the axis widths"
max_times_axis=(1-ax_pos_norm(1))/ax_pos_norm(3); %"origin in times the axis widths"

fig_origin_x_data=ori_times_axis*2*x_axis_size; %Convert figure origin to data-units
fig_max_x_data=max_times_axis*2*x_axis_size;
fig_range_x=fig_max_x_data-fig_origin_x_data;

txt_position_study=fig_origin_x_data-fig_range_x*textoffset; %Text position in DATA (x-axis) units, since MATLAB does not easily allow mixing figure-coordinates and axis coordinates. Placebo 5% text border.

txt_position_eff= x_axis_size+x_axis_size*0.9;
txt_position_n=  txt_position_eff+x_axis_size*0.3;
txt_position_weight=txt_position_n+0.5*x_axis_size;

ytitle_position=yscale+1; % Studies+1 
%axpos=get(gca,'Position'); %[left bottom width height]
%y_entries=linspace(axpos(2),(axpos(2)+axpos(4)),length(studyIDtexts)+2);

% Sort effects by...
% Alphabetic author name, just as in tables
[~,ids] = sort(studyIDtexts);
ids=fliplr(ids')';
% Effect size
%[~,ids] = sort(d);

% PLOT EFFECTS
for i=1:length(ids)
    % Get current study data
    ii=ids(i); % Select current studyID
    
    if NOsummary
        y=i;         % If no summary is desired start with first line
    else
        y=i+1;       % If summary is desired shift lines up
    end
    
    x=eff(ii);  % Get current x yalue
    
    if ~isnan(x) % No plotting of stats for NaN Studies
        xsdleft=ciLo(ii);  % Set current x-error
        xsdright=ciHi(ii); % Set current x-error

        % Plot points representing standardized single-subject results
        if WIsubdata
            ss_delta=MetaStats(ii).std_delta;
            if ~isempty(ss_delta)
                plot(ss_delta,... % X
                     random('unif',-.1,.1,length(ss_delta),1)+y,... %Y
                    '.',...
                    'MarkerSize',dot_size,...
                    'Color',dot_color);
                % OPTIONAL: Additionally plot all outliers exceeding the axis
                if withoutlier
                    n_out_lo=sum(ss_delta<(-x_axis_size));
                    if n_out_lo>0
                           plot(-x_axis_size,...
                                y,...
                                '<',...
                                'MarkerSize',dot_size,...
                                'MarkerEdgeColor',dot_color,...
                                'MarkerFaceColor',dot_color)
                            text(-x_axis_size+0.02*x_axis_size, y, num2str(n_out_lo),...
                                 'HorizontalAlignment','left',...
                                 'VerticalAlignment','bottom',...
                                 'FontSize',font_size*0.80,...
                                 'FontName',font_name);
                    end
                    n_out_hi=sum(ss_delta>x_axis_size);
                    if n_out_hi>0
                           plot(x_axis_size,...
                                y,...
                                '>',...
                                'MarkerSize',dot_size,...
                                'MarkerEdgeColor',dot_color,...
                                'MarkerFaceColor',dot_color);
                            text(x_axis_size-0.02*x_axis_size, y, num2str(n_out_hi),...
                                 'HorizontalAlignment','right',...
                                 'VerticalAlignment','bottom',...
                                 'FontSize',font_size*0.80,...
                                 'FontName',font_name); 
                    end
                end
            end
        end
        
        
        
        % Plot lines representing error-bars
        line([xsdleft xsdright],[y y],'LineWidth',line_width);

        % Create box symbolizing effect and study weights
        % Note that box-size is in y-units... we have to use data-units, otherwise we cannot plot the rectangle correctly on x.
        h_box=sqrt(studyIDweight(ii))*boxscaling; %*boxscaling height of box is 1 unit of y (height of one full study row) times square root of weigth (to make area of box proportional to weight) times box_scaling (to flexibly make boxes larger and smaller)                                   
        w_box=sqrt(studyIDweight(ii))*xy_rel*boxscaling;%/xy_rel*boxscaling;  %same as with, but relative proportion of x to y has to be scaled
        %xy_rel
        %h_box=sqrt(studyIDweight(ii)*x_graphW)*xy_rel*box_scaling;    %same as width, but has to account for relative differences of y vs x axis scaling
        x_box=x-w_box/2; % Center box
        y_box=y-h_box/2; % Center box

        % Plot boxes symbolizing mean + sample weight
        rectangle('Position',[x_box y_box w_box h_box],'FaceColor',[0 0 0]); % Format: links, unten, w, h

    
        % Txt effect 
        formatSpec='%0.2f [%0.2f; %0.2f]';
        text(txt_position_eff, y, sprintf(formatSpec,x,xsdleft,xsdright),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontName',font_name);
        % Txt n  
        text(txt_position_n, y, num2str(n(ii)),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontName',font_name);
        % Txt weight
        formatSpec='%0.1f%%';
        text(txt_position_weight, y, sprintf(formatSpec,rel_weight(ii)*100),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontName',font_name);
    end
        % Plot Study-Description, also for NaN studies
        text(txt_position_study, y, studyIDtexts(ii),...
             'HorizontalAlignment','left',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontName',font_name);
end

 % Txt Study Title
    text(txt_position_study, ytitle_position, 'Study',...
         'HorizontalAlignment','left',...
         'VerticalAlignment','middle',...
         'FontSize',font_size,...
         'FontName',font_name);
  % Txt y-Axis Title
    text(0, yscale+0.025*yscale, 'reduction < > increase',...
         'HorizontalAlignment','center',...
         'VerticalAlignment','middle',...
         'FontSize',font_size*0.90,...
         'FontName',font_name);    
  % Txt effect Title
    text(txt_position_eff, ytitle_position, 'Effect, 95% CI',...
         'HorizontalAlignment','right',...
         'VerticalAlignment','middle',...
         'FontSize',font_size,...
         'FontName',font_name);
  % Txt n Title
    text(txt_position_n, ytitle_position, 'n',...
         'HorizontalAlignment','right',...
         'VerticalAlignment','middle',...
         'FontSize',font_size,...
         'FontName',font_name);
  % Txt n Title
    text(txt_position_weight, ytitle_position, 'Weight',...
         'HorizontalAlignment','right',...
         'VerticalAlignment','middle',...
         'FontSize',font_size,...
         'FontName',font_name);     

if ~NOsummary
    % Plot Summary Results as rhombus:
    rhoheight=1;
    % left  upper  right lower 
    x=[summary_ciLo summary_total summary_ciHi summary_total];
    y=[1 1+rhoheight/2 1 1-rhoheight/2];
    fill(x,y,[0.9 0.9 0.9]);
    %   Txt study Summary
        if p>=0.001
            formatSpec='Total effect (95%% CI): z=%0.2f, p=%0.3f';
            elseif p<0.001
            formatSpec='Total effect (95%% CI): z=%0.2f, p<.%0.0f01'; 
        end
        text(txt_position_study, 1, sprintf(formatSpec,z,p),...
             'HorizontalAlignment','left',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontWeight','bold',...
             'FontName',font_name);
    %   Txt study Summary 2 (Heterogeneity)
        if p_het>=0.001
            formatSpec='Heterogeneity: Chi^2(%d)=%0.2f, p=%0.3f\nTau^2=%0.2f, I^2=%0.2f%%';
            elseif p_het<0.001
            formatSpec='Heterogeneity: Chi^2(%d)=%0.2f, p<.%0.0f01\nTau^2=%0.2f, I^2=%0.2f%%';
        end
        text(txt_position_study, -0.5, sprintf(formatSpec,df,chisq,p_het,tausq,Isq),...
             'HorizontalAlignment','left',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontName',font_name);
    %   Txt effect Summary
        formatSpec='%0.2f [%0.2f; %0.2f]';
        text(txt_position_eff, 1, sprintf(formatSpec,summary_total,summary_ciLo,summary_ciHi),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontWeight','bold',...
             'FontName',font_name);
    %   Txt n Summary
        text(txt_position_n, 1, num2str(nansum(n)),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontWeight','bold',...
             'FontName',font_name);
    %   Txt weight Summary
        formatSpec='%0.1f%%';
        text(txt_position_weight, 1, sprintf(formatSpec,nansum(rel_weight)*100),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontWeight','bold',...
             'FontName',font_name);
end
hold off
