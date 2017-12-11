clear

%Create logical mask
%Load mask
maskheader=spm_vol('../../pattern_masks/brainmask.nii');
mask=spm_read_vols(maskheader);
mask=mask>0.5;
maskpath='../../pattern_masks/brainmask_logical.nii';
outheader=maskheader;
outheader.fname=maskpath;
spm_write_vol(outheader,mask);

datapath='../../Datasets';
runstudies={...
 'Atlas_et_al_2012'
 'Bingel_et_al_2006'
 'Bingel_et_al_2011'
 'Choi_et_al_2013'
 'Eippert_et_al_2009'
 'Ellingsen_et_al_2013'
 'Elsenbruch_et_al_2012'
 'Freeman_et_al_2015'
 'Geuter_et_al_2013'
%'Huber_et_al_2013' % Excluded as same sample as Lui
 'Kessner_et_al_201314'
 'Kong_et_al_2006'
 'Kong_et_al_2009'
 'Lui_et_al_2010'
 'Ruetgen_et_al_2015'
 'Schenk_et_al_2014'
 'Theysohn_et_al_2014'
 'Wager_at_al_2004a_princeton_shock'
 'Wager_et_al_2004b_michigan_heat'
 'Wrobel_et_al_2014'
 'Zeidan_et_al_2015'
};

tic
h = waitbar(0,'Calculating NPS, studies completed:');
for i=1:length(runstudies)
    %Load table into a struct
    varload=load(fullfile(datapath,[runstudies{i},'.mat']));
    %Every table will be named differently, so get the name
    varnames=fieldnames(varload);
    currtablename=varnames(structfun(@istable,varload));
    %Load the variably named table into "df"
    df=varload.(currtablename{:});
    infile=df.img;
    %Construct full image path for output
    [path,filename,ext]=cellfun(@fileparts,infile,'UniformOutput',0);
    smooth_img=fullfile(path,strcat(strcat('s_',filename),ext)); %does not go to df as only needed intermediately
    df.smooth_norm_img=fullfile(path,strcat(strcat('sr_',filename),ext));
    
    % Smooth
    spm_jobman('run', matlabbatch);
    matlabbatch
    
    
    % Reslice and mask
    clear matlabbatch
    for j=1:length(infile)
        matlabbatch{j}.spm.util.imcalc.input = {
                                                maskpath
                                                fullfile(datapath,infile(j))
                                                };
        matlabbatch{j}.spm.util.imcalc.output = fullfile(datapath,df.norm_img(i));
        matlabbatch{j}.spm.util.imcalc.outdir = {};
        matlabbatch{j}.spm.util.imcalc.expression = 'logical(i1).*i2';
        matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{j}.spm.util.imcalc.options.mask = 0;
        matlabbatch{j}.spm.util.imcalc.options.interp = 1;
        matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    end
    spm_jobman('run', matlabbatch);
    
    % Lastly, push df into a table with the name of the original table
    eval([currtablename{1} '= df;']);
    % Eval statement saving results with original table name
    eval(['save(fullfile(datapath,[runstudies{i}]),''',currtablename{1},''');']);
    
    waitbar(i / length(runstudies));
end
close(h)
%% Version for the collective df  (in the end I preferred the single-study version)
% By default, imcalc will change matrix and voxel size to 
% the size of the first image entered... here: the mask's

% load(fullfile(datapath,'AllData.mat'));
% df.norm_img=cell(size(df.img));
% for i=1:length(df.img)
%     infile=fullfile(datapath,df.img{i});
%     [path,filename,ext]=fileparts(df.img{i});
%     df.norm_img{i}=fullfile(path,['r_',filename,ext]);
%     disp(['Masking ',df.norm_img{i}])    
%     matlabbatch{1}.spm.util.imcalc.input = {
%                                             maskpath
%                                             infile
%                                             };
%     matlabbatch{1}.spm.util.imcalc.output = fullfile(datapath,df.norm_img{i});
%     matlabbatch{1}.spm.util.imcalc.outdir = {};
%     matlabbatch{1}.spm.util.imcalc.expression = 'logical(i1).*i2';
%     matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
%     matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
%     matlabbatch{1}.spm.util.imcalc.options.mask = 0;
%     matlabbatch{1}.spm.util.imcalc.options.interp = 1;
%     matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
%     spm_jobman('run', matlabbatch);
% end
% save(fullfile(datapath,'AllData.mat'),'df');
