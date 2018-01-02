% SPM Check
% Plots crucial analysis parameters of current SPM
disp('Time unit used in analysis')
disp(SPM.xBF.UNITS)

figure(1)
plot(SPM.xBF.bf)

disp('High-pass-filter-used')
disp(vertcat(SPM.xX.K.HParam))

figure(2)
plot(SPM.xX.X)