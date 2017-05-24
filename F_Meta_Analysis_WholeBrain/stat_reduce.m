function reduced_stat=stat_reduce(stats,i_voxel)

fields = fieldnames(stats);

reduced_stat=cell2struct(cell(length(stats),length(fields)),fields,2);
reduced_stat=reduced_stat';

    for i = 1:numel(fields)
        for j=1:length(stats)
            if ~isempty(stats(j).(fields{i}))
            reduced_stat(j).(fields{i})=stats(j).(fields{i})(i_voxel);
            end
        end
    end
end