function npsCorrected=nps_rescale(npsValue,voxelVolume,xSpan,conSpan)
% NPS-values must be corrected for scaling differences between the data
% that the NPS was originally trained for and the test data.
% nps_rescale takes an array of NPS values (npsValue) and readjusts the
% scaling according to the parameters voxelVolume, xSpan, conSpan
% (arrays of equal length).
% #########
% 1.) voxelVolume (between-experiment scaling):
%     The NPS-mask was built with images resliced to 3*3*3 voxel size
%     (= 27 mm^3).
%     apply_nps.m resamples the mask to match the voxel-size of the testing
%     image. Resampling therefore increases the number of weights added by
%     a factor: OLDVolume/NEWVolume. Consequently, the resulting NPS values
%     are increased/decreased by the same factor:
%     Testing images with higher resolution (e.g. 2*2*2)
%     >> larger NPS values
%     Testing images with lower resolution (e.g. 3.5*3.5*3.75)
%     >> smaller NPS values
%     The NPS value must therefore be corrected by dividing by
%     (3*3*3/NewVolume).
%
%     Enter voxelVolume of the test images in mm^3 as a scalar number
%     (e.g. 8, 27), or just enter the equivalent formula for voxel volume
%     in round brackets
%     (e.g.: (2*2*2), (3*3*3))
% #########
% 2.) xSpan (between- and within-experiment scaling):
%     Does not apply if raw images are tested, or SPM first-level analysis
%     was applied without HRF-convolution. In these cases just enter
%     a value of 1. Very important in case beta/con images from SPM
%     first-level analysis are tested.
%     When SPM creates the SPM.mat during first level analysis
%     the stick function/box-car predictors (levels: 0 (off), 1 (on))
%     entered by the user (as "onsets" and "durations") are convolved
%     with the HRF. This has grave consequences, since HRF-convolution
%     changes the meaning of the (simple boxcar) beta weights from:
%       
%      "mean % whole brain signal change during condition X"
%       to
%      "% whole brain signal change expected for X assuming
%        a hrf-shaped response, that adds up linearly in case of blocks"
%
%           (aka "BOLD response" aka "brain activity")
%    
%     This messess up the scaling of the predictors x:
%     - The x values for events (blocks of 0 duration) range from approx.
%     max(X)=+0.2 to min(X)=-0.02
%     >> beta values are upscaled
%     - The x values for blocks successively increase with block length.
%     Around 10 seconds block length max(X) becomes larger than 1 (~1.15) and min(X) becomes smaller than
%     one (~-0.07).
%     Consequently, the scaling of beta values depends on block length.
%     This can make a huge (block length <10s) or a small difference (blocks >10 s)
%     in scaling.
%     For more details on this issue see: http://blogs.warwick.ac.uk/nichols/entry/spm_plot_units/

%     For each beta image, the range max(x)-min(x) (here termed xSpan)
%     has to be entered. There is a simple way to compute xSpan:
%     1.) load the particular SPM.mat (type: load SPM.mat)
%     2.) type:
%         cond = 2
%         [replace 2 by the beta number of the predictor of interest, e.g.
%          4 for, if the NPS value computed is based on beta_0004.img]
%     3.) type:    
%         xSpan=max(SPM.xX.X(:,cond))-min(SPM.xX.X(:,cond))
%    done.
%   
%    Careful: This has to be done separately for every condition with
%    involving different durations!

% #########
% 3.) conSpan:
%     Does only apply if con images are tested. In any other case. e.g.
%     beta images, or raw data, enter 1.
%     Differences in contrast-coding can be accounted for by entering
%     conSpan:
%     When contrasting beta images SPM user are asked to enter a vector
%     with contrast weights.
%     If the sum of  positive contrast values equals 1 then conSpan is 1.
%     (e.g.: [0 1 0 0 0]->1, [0.5 0.5 0 0]->1,[1 -1 0 0]->1)
%
%     If contrasts do not add up to 1, the resulting con values are
%     scaled by the amount of summed contrast weights.
%     (e.g.: sum([1 1 0 0 0])=2, sum([1 1 -1 -1])=2, sum([1 -3 1 1])=3)
%     In these cases NPS values will be upscaled *conSpan
%     #########
% 4.) Still to be included:
%     globalMeanSignal (between- and within-experiment scaling):
%     (Does even apply when raw images are tested!)
%     The NPS was trained on raw imaging data (raw %signal change)
%     obtained at a 1.5T scanner with the following imaging parameters
%     (EPI; TR = 2000 ms, TE = 34 ms, field of view = 224 mm, 64x64 matrix),
%     Other scanners and imaging parameters will produce systematically
%     higher or lower mean raw signal (even between imaging runs).
%     Accordingly, the scaling of results will differ.
%     Since field strength, TE, imaging sequence etc. all have different,
%     interacting (and most likely non-linear) effects on global signal
%     strenght it is advised to just normalize results according to the
%     observed mean signal for the training data.
%     The last beta image from the test data provides a good estimate of
%     global mean signal (SPM multiplies it by 100).
%     This value should be entered.
%
% created 16.09.2015 by Zunhammer


%all scaling factors are summarized as cf, which is 1 by default
cf=ones(size(npsValue));
% 1.) fieldStrength:

% if fieldStrength==1.5
%     cf=cf*1; % NPS was trained with 1.5 T data. No scaling.  
%     elseif fieldStrength==3
%     cf=cf*1.355; % NPS was trained with 1.5 T data. No scaling.
%     else
%     fprintf('ERROR in nps_rescale:\nA fieldStrength other than 3 or 1.5 Tesla has been entered.\nCurrently correction is available only for these fieldStrengths\n')
%     return
% end

% 1.) voxelVolume:

cf=cf.*27./voxelVolume;

% 2.) xSpan:
cf=cf.*(1./xSpan);

% 3.) conSpan:
cf=cf.*conSpan;

%Adjust NPS-Value by cf:
npsCorrected=npsValue./cf;