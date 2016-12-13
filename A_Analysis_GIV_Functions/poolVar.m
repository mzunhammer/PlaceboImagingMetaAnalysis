function var=poolVar(varargin)
%calculates pooled variance across several input-vectors
%see: https://en.wikipedia.org/wiki/Pooled_variance
    for i=1:length(varargin)
        if istable(varargin{i}) % Just in case table columns are entered
            varargin{i}=varargin{i}{:,:};
        end
    s(i,:)=nanvar(varargin{i});
    n(i,:)=sum(~isnan(varargin{i}));
    end
   var=sum(s.*(n-1))/sum((n-1));
end