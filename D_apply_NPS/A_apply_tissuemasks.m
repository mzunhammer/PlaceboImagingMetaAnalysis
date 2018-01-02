clear
addpath(genpath('~/Documents/MATLAB/CanlabCore/CanlabCore/'));

p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
datadir=fullfile(filesep,splitp{1:end-2},'datasets');
maskdir=fullfile(filesep,splitp{1:end-2},'pattern_masks');
addpath(maskdir);

df_path=fullfile(datadir,'data_frame.mat');
load(df_path);

n=size(df,1);
h = waitbar(0,'Calculating tissue mask averages, studies completed:');
for i=1:n
    curr_fields=fieldnames(df.full(i));
    for j=1:length(curr_fields)
        if istable(df.full(i).(curr_fields{j}))
        if ~isempty(df.full(i).(curr_fields{j}))
            
        curr_imgs= df.full(i).(curr_fields{j}).norm_img;
        
        grey=apply_patternmask(fullfile(datadir,curr_imgs),fullfile(maskdir,'grey.nii'));
        white=apply_patternmask(fullfile(datadir,curr_imgs),fullfile(maskdir,'white.nii'));
        csf=apply_patternmask(fullfile(datadir,curr_imgs),fullfile(maskdir,'csf.nii'));
        brain=apply_patternmask(fullfile(datadir, curr_imgs),fullfile(maskdir,'brainmask.nii'));
        nobrain=apply_patternmask(fullfile(datadir, curr_imgs),fullfile(maskdir,'inverted_brainmask.nii'));
        
        grey(cellfun(@isempty,grey))={NaN};
        white(cellfun(@isempty,white))={NaN};
        csf(cellfun(@isempty,csf))={NaN};
        brain(cellfun(@isempty,brain))={NaN};
        nobrain(cellfun(@isempty,nobrain))={NaN};

        df.full(i).(curr_fields{j}).grey=[grey{:}]';
        df.full(i).(curr_fields{j}).white=[white{:}]';
        df.full(i).(curr_fields{j}).csf=[csf{:}]';
        df.full(i).(curr_fields{j}).brain=[brain{:}]';
        df.full(i).(curr_fields{j}).nobrain=[nobrain{:}]';

        % Same but with absolute signal values in pattern masks
        grey_abs=apply_patternmask_abs(fullfile(datadir,curr_imgs),fullfile(maskdir,'grey_abs.nii'));
        white_abs=apply_patternmask_abs(fullfile(datadir,curr_imgs),fullfile(maskdir,'white_abs.nii'));
        csf_abs=apply_patternmask_abs(fullfile(datadir,curr_imgs),fullfile(maskdir,'csf_abs.nii'));
        brain_abs=apply_patternmask_abs(fullfile(datadir, curr_imgs),fullfile(maskdir,'brainmask.nii'));
        nobrain_abs=apply_patternmask_abs(fullfile(datadir, curr_imgs),fullfile(maskdir,'inverted_brainmask.nii'));
        
        grey_abs(cellfun(@isempty,grey_abs))={NaN};
        white_abs(cellfun(@isempty,white_abs))={NaN};
        csf_abs(cellfun(@isempty,csf_abs))={NaN};
        brain_abs(cellfun(@isempty,brain_abs))={NaN};
        nobrain_abs(cellfun(@isempty,nobrain_abs))={NaN};

        df.full(i).(curr_fields{j}).grey_abs=[grey_abs{:}]';
        df.full(i).(curr_fields{j}).white_abs=[white_abs{:}]';
        df.full(i).(curr_fields{j}).csf_abs=[csf_abs{:}]';
        df.full(i).(curr_fields{j}).brain_abs=[brain_abs{:}]';
        df.full(i).(curr_fields{j}).nobrain_abs=[nobrain_abs{:}]';
        end
        end
        end
    save(df_path,'df');
    h =waitbar(i / n);
end
    
close(h)