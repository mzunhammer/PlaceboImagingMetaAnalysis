function polar_plot_matthias(m,se,networknames)
    toplot=[m+se; m; m-se]';
    %plot_colors=cbrewer('qual','Paired',3);
    color_mean=[.25,.25,.25];
    color_SE=[.75,.75,.75];
    create_figure('tor_polar');
    [hh, hhfill] = tor_polar_plot({toplot}, {color_SE,color_mean,color_SE}, {networknames}, 'nonneg');
    set(hh{1}(1:3:end), 'LineWidth', 1); %'LineStyle', ':', 'LineWidth', 2);
    set(hh{1}(3:3:end), 'LineWidth', 1); %'LineStyle', ':', 'LineWidth', 2);

    set(hh{1}(2:3:end), 'LineWidth', 4);
    set(hhfill{1}([3:3:end]), 'FaceAlpha', 1, 'FaceColor', 'w');
    set(hhfill{1}([2:3:end]), 'FaceAlpha', 0);
    set(hhfill{1}([1:3:end]), 'FaceAlpha', .3);

    handle_inds=1:3:length(hh{1});
    stats.line_handles = hh{1}(handle_inds:handle_inds+2);
    stats.fill_handles = hhfill{1}(handle_inds:handle_inds+2);

    % doaverage
    hhtext = findobj(gcf, 'Type', 'text'); set(hhtext, 'FontSize', 20);
end