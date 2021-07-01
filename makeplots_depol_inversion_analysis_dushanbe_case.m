

%%
if 1==1

% Tadjikistan

% to find depol 2d

xstart_overview_bin=51;         % 12:25
% xend_overview_bin=571;          % 16:45
xend_overview_bin=421;          % 15:30
xstart_overview=measurement_time_num(xstart_overview_bin); 
xend_overview=measurement_time_num(xend_overview_bin);    

xstart= xstart_overview;
xend= xend_overview;

% xstart = 7.379259854166667e+05;
% xstartbin=661;
% 
% xend= 7.379260649305555e+05;
% xendbin= 903-1;
% xend=measurement_time_num(xendbin);
% 
% 
% xstart_mean=    7.379260010416667e+05;  % 719
% xend_mean=      7.379260059027778e+05 ; % 733
% 
% 
% tbin_low_res=32;  % tbin = 732;

% xstart_mean=    7.379260013888889e+05  % 720
% xend_mean=      7.379260055555556e+05  % 732

% 
% xstart  = measurement_time_num(1);
% xend    = measurement_time_num(end);

  


%% Plot 3d signal overview
% plot_color_3dSignal_plus_2dCloudbase_fct(signal_Mcps_bc_rc(1,:,:),cloudbase_Mcps_bc_rc,'signal McpsBcRc total_{in}',save_all_plots,InputFiles_lidar{ff},result_path);
plot_color_3dSignal_OVERVIEW_fct_dushanbe_case(signal(1,:,:),...
                                        measurement_time_num,height,...
                                        xstart_overview,xend_overview,...
                                        'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);


                                    


%% Plot 3d signal with cloudbase line
% plot_color_3dSignal_plus_2dCloudbase_fct(signal_Mcps_bc_rc(1,:,:),cloudbase_Mcps_bc_rc,'signal McpsBcRc total_{in}',save_all_plots,InputFiles_lidar{ff},result_path);
plot_color_3dSignal_plus_2dCloudbase_fct_dushanbe_case(signal(1,:,:),  cloudbase,...
                                        measurement_time_num,height,...
                                        cloudbase_inM_low_res,time_rof_clouds_low_res,...
                                        xstart,xend,...
                                        'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);


    
%% Plot 3d signal with cloudbase line  (AUSSCHNITT)
% plot_color_3dSignal_plus_2dCloudbase_fct(signal_Mcps_bc_rc(1,:,:),cloudbase_Mcps_bc_rc,'signal McpsBcRc total_{in}',save_all_plots,InputFiles_lidar{ff},result_path);
plot_color_3dSignal_plus_2dCloudbase_PART_fct_arielle_case(signal(1,:,:),  cloudbase,...
                                        measurement_time_num,height,...
                  cloudbase_inM_low_res,time_rof_clouds_low_res,...
                                        xstart_mean,xend_mean,...
                                        'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);


                                    
                                    
%% Mean(over time)Depol and Ratio( only range resolved) (2Dim) 

plot_depol_in_out_mean_fct_arielle_case(depol_in_mean_smooth,depol_out_mean_smooth,...
                            height,...
                            'depol_in_mean_smooth and out',...
                            time_rof_profile_in_bins,...
                            save_all_plots,InputFiles_lidar{ff},result_path)


% %% Plot one signal above CB
% plot_one_signal_above_CB_fct_1_0(signal_low_res_above_CB_smoothed,...
%                                 cloudbase_inM_low_res,...
%                                 tbin_low_res,...
%                                 save_all_plots,InputFiles_lidar{ff},result_path)
% 


%% Plot inversion results
plot_inversion_results_fct_2_3_arielle_159(cdnc_in_cm,   alpha_per_km,   r_eff_in_microns,   lwc_in_g_per_cubicmeter,...
                        cloudbase_inM_low_res,...
                        time_rof_clouds_low_res,...
                        measurement_time_num,...          %just for the leght of the fullsignal
                        xstart,xend,...
                        save_all_plots,InputFiles_lidar{ff},result_path);




%%
plot_inversion_success_analysis_fct_3_0_dushanbe_case(cloudbase_inM_low_res, time_rof_clouds_low_res, ...
    depolratio_mean_above_CB_res_smooth_redutime_smooth, depolratio_allowed_range_res, ...
    depol_in_mean_above_CB_res_smooth_redutime_smooth,...
    depol_out_mean_above_CB_res_smooth_redutime_smooth,...
    max_Mcps_above_CB_in_cloudrange,time_rof_clouds,...
    measurement_time_num,...
    xstart,xend,...
    save_all_plots, InputFiles_lidar{ff}, result_path);

%%
%% 
%% plot mit weniger datenpunkten (wie low res CB)

closestIndex = find_closest_index_fct(time_rof_clouds_low_res, time_rof_clouds)%% Analysis of Inversion Success

plot_inversion_success_analysis_fct_3_0_dushanbe_case(cloudbase_inM_low_res, time_rof_clouds_low_res, ...
    depolratio_mean_above_CB_res_smooth_redutime_smooth, depolratio_allowed_range_res, ...
    depol_in_mean_above_CB_res_smooth_redutime_smooth,...
    depol_out_mean_above_CB_res_smooth_redutime_smooth,...
    max_Mcps_above_CB_in_cloudrange(:,closestIndex),time_rof_clouds_low_res,...
    measurement_time_num,...
    xstart,xend,...
    save_all_plots, InputFiles_lidar{ff}, result_path);

end




