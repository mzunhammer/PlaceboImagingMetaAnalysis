function A_run_all_single_condition_summaries(datapath)
    %Run all single summaries, adds images to df.raw
    summarize_atlas(datapath);
    summarize_bingel06(datapath);
    summarize_bingel11(datapath);
    summarize_choi(datapath);
    summarize_eippert(datapath);
    summarize_ellingsen(datapath);
    summarize_freeman(datapath);
    summarize_geuter(datapath);
    summarize_kong06(datapath);
    summarize_schenk(datapath);
    summarize_wager_princeton(datapath);
    summarize_wrobel(datapath);
    
    summarize_atlas_for_responder(datapath); %remifentanil contrast is  left out
    summarize_geuter_for_responder(datapath); %early/late is summarized, but only for the highly effective placebo
end
