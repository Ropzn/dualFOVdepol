



%%
if 1==1

    
    
%% Plot 3d signal with cloudbase line

plot_color_3dSignal_plus_2dCloudbase_fct_2_0(signal(3,:,:),  cloudbase,...
                                        measurement_time_num,height,...
                                        cloudbase_inM_low_res,time_rof_clouds_low_res,...
                                        'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);

%% Mean(over time)Depol and ( only range resolved) (2Dim) 
plot_depol_in_out_mean_fct(depol_in_mean_smooth,depol_out_mean_smooth,...
                            height,...
                            'depol_in_mean_smooth and out',...
                            time_rof_profile_in_bins,...
                            save_all_plots,InputFiles_lidar{ff},result_path)



%% Plot inversion results
plot_inversion_results_fct_2_1(cdnc_in_cm,   alpha_per_km,   r_eff_in_microns,   lwc_in_g_per_cubicmeter,...
                        cloudbase_inM_low_res,...
                        time_rof_clouds_low_res,...
                        measurement_time_num,...          %just for the leght of the fullsignal
                        save_all_plots,InputFiles_lidar{ff},result_path);


%% Analysis of Inversion Success
xstart = measurement_time_num(1);
xend =measurement_time_num(size(signal,3));
plot_inversion_success_analysis_fct_3_0(cloudbase_inM_low_res, time_rof_clouds_low_res, ...
    depolratio_mean_above_CB_res_smooth_redutime_smooth, depolratio_allowed_range_res, ...
    depol_in_mean_above_CB_res_smooth_redutime_smooth,...
    depol_out_mean_above_CB_res_smooth_redutime_smooth,...
    max_Mcps_above_CB_in_cloudrange,time_rof_clouds,...
    measurement_time_num,...
    xstart,xend,...
    save_all_plots, InputFiles_lidar{ff}, result_path);




end




