function reduced_stat=stat_reduce(stats,i_voxel)

fields = fieldnames(stats);

reduced_stat=cell2struct(cell(length(stats),length(fields)),fields,2);
reduced_stat=reduced_stat';

maxvoxels=size(stats(1).(fields{1}),2);
    for i = 1:numel(fields)
        for j=1:length(stats)
            if ~isempty(stats(j).(fields{i}))&&size(stats(j).(fields{i}),2)==maxvoxels
                reduced_stat(j).(fields{i})=stats(j).(fields{i})(i_voxel);
            else
                reduced_stat(j).(fields{i})=NaN;
            end
        end
    end
end