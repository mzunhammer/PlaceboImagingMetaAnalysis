function outtable=refine_cluster_table(intable)
% Read table, split into parts
txt=fileread(intable);
txt=regexp(txt,'------------------------------------------+?', 'split');
raw_rtable=txt{1}; %actual table

if length(txt)==1 % In case there were no clusters
    outtable =[]
    return
end

raw_peak_lbls=txt{2}; %peak labels
raw_cluster_lbls=txt{3}; %cluster labels

% Read header info
header=regexp(txt,'\=\=\=\=\=\[\s(.+?)\s\|\s(.+?)\s\]\=\=\=\=\=','tokens'); 
imgpath=header{1}{1}{1};
[path,imgname,~]=fileparts(imgpath);
subpath=strsplit(path,'/');
stattype=subpath(end);
subpath=char(join(subpath(1:end-1),'/'));
imgnameparts=strsplit(imgname,'_');

atlas=header{1}{1}{2};

%Read table header
tblhdr=textscan(raw_rtable,'%s%s%s%s%s%s%s%s%s',1,...
        'Delimiter','\t',...
        'HeaderLines',1);
tblhdr=horzcat(tblhdr{:});
tblhdr=strtok(tblhdr,'(mm)');

%Read table content
tblcontent=textscan(raw_rtable,'%n%n%n%n%n%n%n%n%n',...
        'Delimiter','\t',...
        'HeaderLines',2);
tblcontent=horzcat(tblcontent{:});

%Read cluster lables
ncluster=regexp(raw_cluster_lbls,'\nCluster\s\#(\d*?)\n','tokens');
ncluster=[ncluster{:}];
clustertxt=regexp(raw_cluster_lbls,'\nCluster\s\#\d*?\n','split');
clustertxt=clustertxt(2:end);

clustertxt_clean=cell(size(clustertxt));
%Clean results from fsl's "Cluster":
%1)Sort by % anatomical label of cluster
%2)Keep only 2 labels at max
for i=1:length(clustertxt)
    if ~isempty(clustertxt{i}) %account for clusters with no atlas results
        clusterlines=strsplit(clustertxt{i},'\n'); %
        clustercells=cellfun(@(x) strsplit(x,':'), clusterlines,'UniformOutput',0)';% split labels and %
        clustercells=clustercells(~cellfun(@(x) isempty(x{1}),clustercells));% drop empty cells
        clustercells=vertcat(clustercells{:});
        clustercells(:,2)=cellfun(@(x) {str2double(x)}, clustercells(:,2));
        clustercells=sortrows(clustercells,-2);
        clustercells(:,2)=cellfun(@(x) {num2str(round(x,1))}, clustercells(:,2));
        clustertxt_clean{i}=cellfun(@(x,y) strcat(x,' (',y,'%)'), clustercells(:,1),clustercells(:,2),'UniformOutput',0);
    else
        clustertxt_clean{i}={'unknown'};
    end
    
    if length(clustertxt_clean{i})>1
        clustertxt_clean{i}=char(join(clustertxt_clean{i}(1:2),', ')); %limit to two labels
    else
        clustertxt_clean(i)=clustertxt_clean{i}; %limit to two labels
    end
end

%Create matlab table
rtable=array2table(tblcontent,'VariableNames',genvarname(tblhdr));
rtable.labels=clustertxt_clean'; %add lalbels

%For each cluster get n,SE,tausq,z-val,p-val(parametric,uncorrected),p-val(perm,uncorrected),p-val(perm,FWE)
switch stattype{:}
    case 'heterogeneity'
    paramOfInterest={'n','chisq','p_het','p_map','p_map_perm','p_map_perm_FWE','unthresh','SE'};
    mainstat='random';
    otherwise
    paramOfInterest={'n','SE','tausq','z','p_map','p_map_perm','p_map_perm_FWE'};
    mainstat=stattype;
end
addtable=array2table(NaN(height(rtable),length(paramOfInterest)),'VariableNames',paramOfInterest);
for i=1:height(rtable)
    MNI=[rtable.MAXX(i),rtable.MAXY(i),rtable.MAXZ(i)];
    for j=1:length(paramOfInterest)
        cparam=paramOfInterest(j);
        cimg=strcat(join([imgnameparts(1:3),cparam],'_'),'.nii');
        switch cparam{:}
            case 'n'
                cpath=subpath;
            case {'Isq','chisq','tausq','p_hetperm','p_het'}
                cpath=fullfile(subpath,'heterogeneity');
            case {'unthresh','SE','z','p_map','p_map_perm'}
                cpath=fullfile(subpath,mainstat);
        end
        cimg=fullfile(char(cpath),char(cimg));
        chdr=spm_vol(cimg);
        vxl=mni2mat(MNI,cimg);
        cdat=spm_read_vols(chdr);
        addtable{i,cparam}=cdat(vxl(1),vxl(2),vxl(3));
    end
end

% Beautify output tables
if strcmp(imgnameparts{end},'neg')
    rtable.MAX=rtable.MAX*-1; % Direction of effect has to be changed from "negative" contrast images
end

outtable=[rtable, addtable]; % Merge tables
outtable.ClusterIndex=flipud(outtable.ClusterIndex); % Number by cluster size

switch stattype{:}
    case 'heterogeneity'
        oldnames={'ClusterIndex','MAX','MAXX','MAXY','MAXZ','COGX','COGY','COGZ','p_het','p_het_perm','p_het_perm_FWE'};
        newnames={'No',imgnameparts{4},'X','Y','Z','COG_X','COG_Y','COG_Z','p_uncorr','p_uncorr_perm','p_FWE_perm'};
        outtable.Properties.VariableNames(oldnames)=newnames; %Rename columns
        outtable = outtable(:,[1 10 4:6 2 11 3 15 14]); %Reorder columns
    otherwise
        oldnames={'ClusterIndex','MAX','MAXX','MAXY','MAXZ','COGX','COGY','COGZ','p_map','p_map_perm','p_map_perm_FWE'};
        newnames={'No',imgnameparts{3},'X','Y','Z','COG_X','COG_Y','COG_Z','p_uncorr','p_uncorr_perm','p_FWE_perm'};
        outtable.Properties.VariableNames(oldnames)=newnames; %Rename columns
        outtable = outtable(:,[1 10 4:6 2 11 13 3 12 14 17]); %Reorder columns
end

