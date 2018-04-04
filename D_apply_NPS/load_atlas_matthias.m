function mask=load_atlas_matthias(atlas_name)
% wrapper to obtain  fMRI object from atlas object
    curr_atlas = load_atlas(atlas_name);
    mask=fmri_data();
    mask.dat=full(curr_atlas.probability_maps);
    mask.removed_voxels=curr_atlas.removed_voxels;
    mask.volInfo=curr_atlas.volInfo; % Well, that was a pain to get right
end