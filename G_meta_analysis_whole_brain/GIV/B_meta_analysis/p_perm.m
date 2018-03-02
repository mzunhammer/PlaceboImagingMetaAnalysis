function [p_uncorr,p_FWE]=p_perm(values,perm_dist,tails,power_transform)
% values: Original values
% perm: Permutation object
% tails: "one-tailed-larger","one-tailed-smaller","two-tailed"
%
% Wrapper for the "tail approximation" method of Knijenburg.
% available at: https://shmulevich.systemsbiology.org/bio/theo-knijnenburg/
% Knijnenburg TA, Wessels LFA, Reinders MJT, Shmulevich I. Fewer permutations, more accurate P-values. Bioinformatics. 2009;25(12):161-168. doi:10.1093/bioinformatics/btp211.
% ####### WARNING ####:
% 1.) Ppermest only provides p-Values for right-tailed tests, the function
% re-formats the permutation distribution + target-values accordingly
% 2.) Ppermest shall only receive a scalar as target value and a 1d-array as
% permutation distribution. Feeding it with 1d-array of target values and a
% 2d-array of permutation distributions will yield faulty p-values, so
% don't!
% 3.) Ppermest will yield p-Values of 0 for very extreme values...
% according to Theo Knijenburg this is an unresolved issue. Therefore, we
% go for the upper 95% CI of p-Value estimates, instead of the actual p-Value estimates.
addpath(fullfile(userpath,'PermutationTestPvalueEstimation_EPEPT'))

% Power-transform original and unpermuted values for better tail fit (does
% not affect p-values outside of tails.
values=values.^power_transform;
perm_dist=perm_dist.^power_transform;
%% Uncorrected permuted p-Values (voxel-wise)
    p_uncorr=NaN(size(values));
    for i=1:size(values,2) %unfortunately Ppermest seems to handle matrixes incorrectly >> loop req
        if strcmp(tails,"one-tailed-larger")
                p_uncorr(i)=Ppermest(values(i),perm_dist(:,i));
        elseif strcmp(tails,"one-tailed-smaller")
                p_uncorr(i)=Ppermest(values(i)*-1,perm_dist(:,i)*-1); % invert, as Ppermest can only do one-tailed-larger
        elseif strcmp(tails,"two-tailed")
            %p_uncorr(i)=Ppermest(abs(values(i)),abs(perm_dist(:,i)));
            % Different version, should also work for values not centered
            % at 0 and asymmetric distributions. But since we are only dealing with z-Values and tfce values here, we
            % can assume all zero-distributions to be centered.
            mdn=median(perm_dist(:,i));
            if values(i)>mdn % for values larger than the median (usually 0
                p_uncorr(i)=Ppermest(values(i),perm_dist(:,i)).*2; % ... get upper one-sided p, multiply by two.
            elseif values(i)<=mdn % for values smaller or equal  the median (usually 0)
                p_uncorr(i)=Ppermest(values(i)*-1, perm_dist(:,i)*-1).*2;% ... flip distribution and value by multiplying with -1, get upper one-sided p, multiply by two.
            end
            p_uncorr(i)=min([p_uncorr(i),1]); % Cludge needed as the ecdf p-Value from Ppermest will sometimes be larger 1 if very close to the median.
        end
    end
    % Ppermest will eventually yield p-values of 0 despite ok tail fit. As this is not possible with permutation testing per definition and will be problematic with FDR control, I replace any p-values of 0 with a small value of p (0.0001).
    p_uncorr(p_uncorr==0)=0.0001;
%% FWE corrected p-Values according to the "maximum-t" (here: "maximum-z") method by Nichols

perm_min=nanmin(perm_dist,[],2);
perm_max=nanmax(perm_dist,[],2);
perm_dist=[perm_min;perm_max];
p_FWE=NaN(size(values));
for i=1:size(values,2)  %unfortunately Ppermest seems to handle matrixes incorrectly >> loop req
    if strcmp(tails,"one-tailed-larger")
            p_FWE(i)=Ppermest(values(i),perm_max);
    elseif strcmp(tails,"one-tailed-smaller")
            p_FWE(i)=Ppermest(values(i)*-1,perm_min*-1); % invert, as Ppermest can only do one-tailed-larger
    elseif strcmp(tails,"two-tailed")
            %p_FWE(i)=Ppermest(abs(values(i)),abs(perm_dist));
        % Different version, should also work for values not centered
        % at 0  and asymmetric distributions. But since we are only dealing with z-Values and tfce values here, we
        % can assume all zero-distributions to be centered.
            if values(i)>0 % for values larger than the median (using 0 here, as the combination of max distributions has a gap in the middle)
                p_FWE(i)=Ppermest(values(i),perm_dist).*2; % ... get upper one-sided p, multiply by two.
            elseif values(i)<=0 % for values smaller or equal  the median (using 0 here, as the combination of max distributions has a gap in the middle)
                p_FWE(i)=Ppermest(values(i)*-1, perm_dist*-1).*2;% ... flip distribution and value by multiplying with -1, get upper one-sided p, multiply by two.
            end
            p_FWE(i)=min([p_FWE(i),1]); % Cludge needed as the ecdf p-Value from Ppermest will sometimes be larger 1 if very close to the median.
    end
end
 % Ppermest will eventually yield p-values of 0 despite ok tail fit. As this is not possible with permutation testing per definition and will be problematic with FDR control, I replace any p-values of 0 with a small value of p (0.0001).
p_FWE(p_FWE==0)=0.0001;

end