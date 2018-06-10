function forest_plot(eff,se_eff,n,summary,varargin)
%% Function to create Forest Plots for meta-analysis
% by Matthias Zunhammer November 2016
% ##### Required arguments ######:
% 'eff':
% a vector of effect sizes (e.g. mean, Cohen's d, Hedge's g, Pearson's r),
% one effect per study.
% Important note: If variables are entered that do not follow a normal
% distribution (e.g. Pearson's r, ICC), the optional argument type should be set
% to "r". Otherwise, confidence intervals will be calculated incorrectly.
% Can be created by summarize_within.m or summarize_between.m
% 
%'se_eff':
% a corresponding vector of standard errors.
% Can be created by summarize_within.m or summarize_between.m
%
% 'n':
% The number of individuals per study
%
% 'summary':
% a summary struct containing the fixed, random, and heterogeneity
% estimates. Can be obtained by GIV_summary (in combination with
% summarize_within.m / summarize_between.m), or more generally, with GIV_weight.m.
%
%
% ###### Optional arguments ######:
% 'study_ID_texts': vector with i study labels.
% 'outcome_label': string lableing the x-axis.
% 'summary_stat': string designating the desired outcome ('mu' for mean, 'd' or Cohen's d, 'g' for Hedges' g).
% 'type': String indicating whether 'fixed' or 'random' analysis is desired.
% 'font_size': Double indicating the size of study text.
% 'text_offset': Scalar indicating whether additional distance between study
%       info and graph is desired. Unit is "width of x-axis", so 0.5 will add half
%       of the x-axis width.
% 'box_scaling': Scalar indicating how study weight and box-size relate: box
%   size = one y-unit * weight
% 'print_width': Two-element numeric vector indicating the desired with of image in px [x,y].
% 'X_scale': Scalar indicating the maximum scale value for X
% 'WI_subdata': Prints single-subject data-points below by-study means +
% error bars. this requires

% ###### Example ######:
% forest_plot(r,...
%            SE_r,...
%            n,...
%            summary_r,...
%            'study_ID_texts',df.study_ID,...
%            'type','random',...
%            'summary_stat','r');

%% Parse optional inputs according to: https://de.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
p = inputParser;
%Check summary 
addRequired(p,'eff',@isnumeric)
%Check summary 
addRequired(p,'se_eff',@isnumeric)
%Check summary 
addRequired(p,'n',@isnumeric)
%Check summary 
addRequired(p,'summary',@isstruct);
%Check study_ID_texts
def_study_ID_texts = {};
addParameter(p,'study_ID_texts',def_study_ID_texts,@iscell);
%Check outcomelabel
def_outcome_labels = 'Outcome';
addParameter(p,'outcome_labels',def_outcome_labels,@ischar);
%Check type
defType = 'random';
addParameter(p,'type',defType,@ischar);
%Check type
def_summary_stat = 'g';
addParameter(p,'summary_stat',def_summary_stat,@ischar);
%Check font_size
def_fontsize=16; % Negative number will later be replaced by no change in resolution
addParameter(p,'font_size',def_fontsize,@isnumeric);
%Check text_offset (currently automatically determined)
def_text_offset=0; % Negative number will later be replaced by no change in resolution
addParameter(p,'text_offset',def_text_offset,@isnumeric);
%Check box_scaling
def_box_scaling=1; %
addParameter(p,'box_scaling',def_box_scaling,@isnumeric);   % basic unit is y (height of a study-line)
%Check print_width
def_print_width=1200; % print_width in px, note that this may not surpass the maximum display size set by the system
addParameter(p,'print_width',def_print_width,@isnumeric);
%Check Withoutlier
def_with_outlier = 1;
addParameter(p,'with_outlier',def_with_outlier,@isnumeric);
%Check WI_subdata
def_WI_sub_data = {};
addParameter(p,'WI_subdata',def_WI_sub_data,@iscell);
%Supress summary
def_NO_summary = 0;
addParameter(p,'NO_summary',def_NO_summary,@isnumeric);
%X_scale 
def_X_scale = NaN;%per default the scale is chosen based on the largest absolute single subject value: round(max(abs(val))).
addParameter(p,'X_scale',def_X_scale,@isnumeric);

parse(p,eff,se_eff,n,summary,varargin{:});
% Re-format inputs for convenience
summary=p.Results.summary;
study_ID_texts=p.Results.study_ID_texts;
outcomelabel=p.Results.outcome_labels;
type=p.Results.type;
summary_stat=p.Results.summary_stat;
font_size=p.Results.font_size;
print_width=p.Results.print_width;
withoutlier=p.Results.with_outlier;
WI_subdata=p.Results.WI_subdata;
text_offset=p.Results.text_offset;
box_scaling=p.Results.box_scaling;
NO_summary=p.Results.NO_summary;
X_scale=p.Results.X_scale;

% Check whether Fisher's z transform is necessary for valid CIs
if ismember(summary_stat,{'r','ICC','r_external'})
    se_eff_Z=n2fishersZse(n); % SE for FISHER's
    ciLo_Z=r2fishersZ(eff)-se_eff_Z.*1.96;
    ciHi_Z=r2fishersZ(eff)+se_eff_Z.*1.96;
    ciLo=fishersZ2r(ciLo_Z);
    ciHi=fishersZ2r(ciHi_Z);
else
    ciLo=eff-se_eff.*1.96;
    ciHi=eff+se_eff.*1.96;
end        

chisq=summary.heterogeneity.chisq;
p_het=summary.heterogeneity.p_het;
Isq=summary.heterogeneity.Isq;

if strcmp(type,'fixed')
    tausq=[];
    summary=summary.fixed;
elseif strcmp(type,'random')
    tausq=summary.heterogeneity.tausq;
    summary=summary.random;
end

df=summary.df;
rel_weight=vertcat(summary.rel_weight);
summary_total=summary.summary;
z=summary.z;
p=summary.p;
summary_ciLo=summary.CI_lo;
summary_ciHi=summary.CI_hi;



%% Forest Plot
%FIGURE WINDOW
figure_width=print_width;
lineheight=print_width/12;
figure_height=(length(study_ID_texts)+2)*lineheight;%figure height is defined as: (number of lines +one line for GIV_summary and one line for head)*line scaling

figure('Name','Forest Plot',...
        'Position', [0, 0, figure_width, figure_height],...
        'Units','pixels');% Position: left bottom width heigth;
hold on

%TEXT POSITION AND SIZE
font_size=font_size;
font_name='Arial';

%SIZE OF GRAPH AREA VS TEXT
x_graphW=0.3333333; %relative size of x-axis in normalized space (rel to the whole graph)
    
%AXIS SCALE
if isnan(X_scale)
    if isempty(WI_subdata) % no-single subj data-points >> scale x-axis to max(GIV_summary?CI) but at least X_scale
        %x_axis_size=double(ceil(max(abs([ciLo;ciHi]))));
        x_axis_size=double(round(max(abs([ciLo;ciHi])),1,'significant'));
    elseif ~isempty(WI_subdata) && withoutlier % single subj data-points (for WI-studies), yet points beyond max(GIV_summary?CI) not plotted > outliermarks instead
        %x_axis_size=double(ceil(max(abs([ciLo;ciHi]))));
        x_axis_size=double(round(max(abs([ciLo;ciHi])),1,'significant')); 
    elseif ~isempty(WI_subdata) && ~withoutlier % plot full range of wi-single subj data. x-axis are scaled to max(abs(indiv datapoint))
        if length(WI_subdata)~=length(eff)
            error('Single within-subject data-points requested, but not passed properly ''WI_subdata''.');
        else
            %x_axis_size=double(ceil(max(abs(vertcat(WI_subdata{:})))));
            x_axis_size=double(round(max(abs(vertcat(WI_subdata{:}))),1,'significant')); 
        end 
    end
else
    x_axis_size=X_scale;
end
if strcmp(summary_stat,'r')|strcmp(summary_stat,'ICC')
    x_axis_size=1;
end

y_axis_size=(length(study_ID_texts)+2);
if NO_summary
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
studyIDweight=rel_weight; % get study weights from GIV_summary
 
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

txt_position_study=fig_origin_x_data-fig_range_x*text_offset; %Text position in DATA (x-axis) units, since MATLAB does not easily allow mixing figure-coordinates and axis coordinates. Placebo 5% text border.

txt_position_eff= x_axis_size+x_axis_size*0.9;
txt_position_n=  txt_position_eff+x_axis_size*0.3;
txt_position_weight=txt_position_n+0.5*x_axis_size;

ytitle_position=yscale+1; % Studies+1 
%axpos=get(gca,'Position'); %[left bottom width height]
%y_entries=linspace(axpos(2),(axpos(2)+axpos(4)),length(study_ID_texts)+2);

% Sort effects by...
% Alphabetic author name, just as in tables
[~,ids] = sort(study_ID_texts);
ids=fliplr(ids')';
% Effect size
%[~,ids] = sort(d);

% PLOT EFFECTS
for i=1:length(ids)
    % Get current study data
    ii=ids(i); % Select current studyID
    
    if NO_summary
        y=i;         % If no GIV_summary is desired start with first line
    else
        y=i+1;       % If GIV_summary is desired shift lines up
    end
    
    x=eff(ii);  % Get current x yalue
    
    if ~isnan(x) % No plotting of stats for NaN Studies
        xsdleft=ciLo(ii);  % Set current x-error
        xsdright=ciHi(ii); % Set current x-error

        % Plot points representing standardized single-subject results
        if ~isempty(WI_subdata)
            ss_delta=WI_subdata{ii};
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
        h_box=sqrt(studyIDweight(ii))*box_scaling; %*box_scaling height of box is 1 unit of y (height of one full study row) times square root of weigth (to make area of box proportional to weight) times box_scaling (to flexibly make boxes larger and smaller)                                   
        w_box=sqrt(studyIDweight(ii))*xy_rel*box_scaling;%/xy_rel*box_scaling;  %same as with, but relative proportion of x to y has to be scaled
        %xy_rel
        %h_box=sqrt(studyIDweight(ii)*x_graphW)*xy_rel*box_scaling;    %same as width, but has to account for relative differences of y vs x axis scaling
        x_box=x-w_box/2; % Center box
        y_box=y-h_box/2; % Center box

        % Plot boxes symbolizing mean + sample weight
        rectangle('Position',[x_box y_box w_box h_box],'FaceColor',[0 0 0]); % Format: links, unten, w, h

    
        % Txt effect 
        formatSpec='%0.2g [%0.2g; %0.2g]';
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
        text(txt_position_study, y, study_ID_texts(ii),...
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

if ~NO_summary
    % Plot GIV_summary Results as rhombus:
    rhoheight=1;
    % left  upper  right lower 
    x=[summary_ciLo summary_total summary_ciHi summary_total];
    y=[1 1+rhoheight/2 1 1-rhoheight/2];
    fill(x,y,[0.9 0.9 0.9]);
    %   Txt study GIV_summary
        if p>=0.01
            formatSpec='Total effect (95%% CI): z=%0.2f, p=%0.2f';
        elseif p<0.01 && p>=0.001
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
    %   Txt study GIV_summary 2 (Heterogeneity)
        if p_het>=0.01
            formatSpec='Heterogeneity: Chi^2(%d)=%0.2f, p=%0.2f\nTau^2=%0.2f, I^2=%0.2f%%';
        elseif p_het<0.01 && p_het>=0.001
            formatSpec='Heterogeneity: Chi^2(%d)=%0.2f, p=%0.3f\nTau^2=%0.2f, I^2=%0.2f%%';
        elseif p_het<0.001
            formatSpec='Heterogeneity: Chi^2(%d)=%0.2f, p<.%0.0f01\nTau^2=%0.2f, I^2=%0.2f%%';
        end
        text(txt_position_study, -0.5, sprintf(formatSpec,df,chisq,p_het,tausq,Isq),...
             'HorizontalAlignment','left',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontName',font_name);
    %   Txt effect GIV_summary
        formatSpec='%0.2g [%0.2g; %0.2g]';
        text(txt_position_eff, 1, sprintf(formatSpec,summary_total,summary_ciLo,summary_ciHi),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontWeight','bold',...
             'FontName',font_name);
    %   Txt n GIV_summary
        text(txt_position_n, 1, num2str(nansum(n)),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontWeight','bold',...
             'FontName',font_name);
    %   Txt weight GIV_summary
        formatSpec='%0.1f%%';
        text(txt_position_weight, 1, sprintf(formatSpec,nansum(rel_weight)*100),...
             'HorizontalAlignment','right',...
             'VerticalAlignment','middle',...
             'FontSize',font_size*0.90,...
             'FontWeight','bold',...
             'FontName',font_name);
end
hold off
end