function v=nii2vector(nii_imgs,mask_img)

if (exist('mask_img'))
    % Load mask
    maskheader=spm_vol(mask_img);
    mask=logical(spm_read_vols(maskheader)); 
else
    sample_img=spm_read_vols(spm_vol(nii_imgs{1}));
    mask=ones(size(sample_img));
end
masking=mask(:);


%Load image headers
headers=spm_vol(nii_imgs);
nimg=length(headers);
%Preallocate target matrix
v=NaN(nimg,sum(masking));
tic
for i=1:nimg
    %Load image data
    [currdat,~]=spm_read_vols(headers{i});
    
    % In most images NaN regions were replaced with 0's by SPM or fsl
    % Even worse in some images NaN regions were replaced with an non-zero
    % constant...
    % This will lead to computational problems later making it difficult to
    % distinguish "filled" form "actual" zeros
    % Solution:
    % The most frequent value in the map should represent non-brain
    
    n_nans=sum(isnan(currdat(:))); %Count number of nans (nans are not captured by mode)
    curr_mode=mode(currdat(:));    %Get most frequent non-nan value
    n_mode_non_nan=sum(currdat(:)==curr_mode); %Count number of mode values
    
    if n_mode_non_nan>n_nans % if non-brain areas are not defined as nan
    currdat(abs(currdat-curr_mode)<eps)=NaN; %replace values that are identical with mode (within double-precision error) with NaNs
    end
    v(i,:)=currdat(masking)'; % Finally, extract only values within brainmask
end
toc/60;

end