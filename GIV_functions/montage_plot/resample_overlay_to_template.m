function resample_overlay_to_template(template,overlays)

for i=1:length(overlays)
outfilename=['overlay',num2str(i),'.nii'];
expression='ones(size(i1)).*i2'; %formula leaves everything in the overlay as-is, but imcalc automatically adapts resolution
spm_imcalc([template,overlays(i)],...
           outfilename,...
           expression)
end