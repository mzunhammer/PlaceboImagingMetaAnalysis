function sim = matthias_pattern_similarity(obj,mask)
% wrapper for canlab_pattern_similarity applying prepro from
% image_similarity_plot.
% WARNING: CURRENTLY REQUIRES A MASK THAT IS ALREADY RESAMPLED TO OBJ SPACE.
% UNCOMMENT BELOW WILL CHANGE THAT:

    mask = replace_empty(mask); % add zeros back in
    %mask = resample_space(mask, obj);
    obj = remove_empty(obj);
    obj = replace_empty(obj);
    sim = zeros(size(mask.dat, 2), size(obj.dat,2));
    for im = 1:size(mask.dat, 2) %loops over pattern masks
        sim(im, :) = canlab_pattern_similarity(obj.dat, mask.dat(:,im),...
                                               'cosine_similarity',...
                                               'ignore_missing');
    end
end
