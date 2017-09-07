function summary=compareGIVsummary(summary1,summary2)

%Get fieldnames
stat1=fieldnames(summary1);
stat2=fieldnames(summary2);

if any(~strcmp(stat1,stat2))
   disp('Warning in compareGIVsummary, summary1 and summary2 contain different stats. Limiting comparison to stats that are present in both summaries.')
   stat=stat1(strcmp(stat1,stat2));
else
   stat=stat1;
end

summary=struct;
model={'fixed','random'};
%For each common field
for i = 1:length(stat)
    % See Borenstein Introduction to Meta-Analysis, 2009: Chapter 19,
    % Analysis of sub-group differences for fixed & random analyses.
    % See Formulas 19.6ff for fixed and 19.24ff for random (both are equivalent)
    for j=1:length(model)
        %Get Values
        cmodel=model{j};
        outstat=[stat{i},'_diff'];
        z_CI=abs(icdf('normal',0.025,0,1));
        
        eff_1=summary1.(stat{i}).(cmodel).summary;
        eff_2=summary2.(stat{i}).(cmodel).summary;
        SE_1=summary1.(stat{i}).(cmodel).SEsummary;
        SE_2=summary2.(stat{i}).(cmodel).SEsummary;
        
        % Transform r's to Fisher's z
        if ismember(stat{i},{'r','ICC','r_external'})
            eff_1=r2fishersZ(eff_1);
            eff_2=r2fishersZ(eff_2);
            SE_1=r2fishersZ(SE_1);
            SE_2=r2fishersZ(SE_2);
        end
        
        %Calculate Difference in means, SE, Z, p, CIs
        delta=eff_1-eff_2;
        SEdelta=sqrt(SE_1.^2+SE_2.^2); % Also see: Borenstein 2009 Chapter 4, Formula 4.29
        z=delta./SEdelta;
        p=normcdf(-abs(z),0,1).*2;
        
        CI_lo=delta-SEdelta.*z_CI;
        CI_hi=delta+SEdelta.*z_CI;
        
        % Backtransform Fisher's z to r
        if ismember(stat{i},{'r','ICC','r_external'})
            delta=fishersZ2r(delta);
            SEdelta=fishersZ2r(SEdelta);
        end
        
        % Provide results in summary struct
        summary.(outstat).(cmodel).delta=delta;
        summary.(outstat).(cmodel).SEdelta=SEdelta;
        summary.(outstat).(cmodel).CI_lo=CI_lo;
        summary.(outstat).(cmodel).CI_hi=CI_hi;
        summary.(outstat).(cmodel).z=z;
        summary.(outstat).(cmodel).p=p;
    end
end
end