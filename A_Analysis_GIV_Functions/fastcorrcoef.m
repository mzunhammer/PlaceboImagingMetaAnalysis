function r=fastcorrcoef(A,B)
    An=bsxfun(@minus,A,mean(A,1)); %%% zero-mean
    Bn=bsxfun(@minus,B,mean(B,1)); %%% zero-mean
    An=bsxfun(@times,An,1./sqrt(sum(An.^2,1))); %% L2-normalization
    Bn=bsxfun(@times,Bn,1./sqrt(sum(Bn.^2,1))); %% L2-normalization
    r=round(sum(An.*Bn,1),10); %% correlation
end