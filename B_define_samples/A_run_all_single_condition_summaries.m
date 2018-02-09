function A_run_all_single_condition_summaries(datapath)
    %Run all single summaries, adds images to df.raw
    summarize_atlas(datapath);
    summarize_bingel06(datapath);
    summarize_choi(datapath);
    summarize_eippert(datapath);
    summarize_geuter(datapath);
    summarize_schenk(datapath);
    summarize_wager_princeton(datapath);
    summarize_wrobel(datapath);
end
