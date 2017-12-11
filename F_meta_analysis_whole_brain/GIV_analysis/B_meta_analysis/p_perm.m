function p=p_perm(values,perm_dist,type,tails)

v_size=size(values);
v=reshape(values,numel(values),1);
p=NaN(size(v));

for i=1:length(v)
    value=v(i);
    if  strcmp(type,'full')&strcmp(tails,'one-tailed-smaller')
            p(i) = sum(perm_dist <= value)./length(perm_dist);
        elseif  strcmp(type,'monte-carlo' )& strcmp(tails,'one-tailed-smaller')
            p(i) = (sum(perm_dist <= value)+1)./(length(perm_dist)+1);
        elseif  strcmp(type,'full' )& strcmp(tails,'one-tailed-larger')
            p(i) = sum(perm_dist >= value)./length(perm_dist);
        elseif  strcmp(type,'monte-carlo' )& strcmp(tails,'one-tailed-larger')
            p(i) = (sum(perm_dist >= value)+1)./(length(perm_dist)+1);
        elseif  strcmp(type,'full') & strcmp(tails,'two-tailed')
            p(i) = sum(abs(perm_dist) >= abs(value))./length(perm_dist);
        elseif  strcmp(type,'monte-carlo') & strcmp(tails,'two-tailed')
            p(i) = (sum(abs(perm_dist) >= abs(value))+1)./(length(perm_dist)+1);
        else
            disp('Wrong arguments enterd for ''type'' (must be ''full''|''monte-carlo'') and/or ''tails'' (must be ''one-tailed-smaller''|''one-tailed-larger''|''two-tailed'')')
            return
    end
p=reshape(p,v_size);
end