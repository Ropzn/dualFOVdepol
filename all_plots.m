
%%
if 1==1

%%  Colorplots mit Hoehe vs Zeit (3Dim) unkalibriertes signal%%%%%%%%%%%%%%%

% Nur Mcps (ohne RC,BC,DC)
%     plot_color_4ch_fct(raw_signal_Mcps,'raw_signal_Mcps',save_all_plots,InputFiles_lidar{ff},result_path);

% Without deadtime (mit RC,BC, ohne DC)
plot_color_4ch_fct(raw_signal,'signal_Mcps_bc_rc',save_all_plots,InputFiles_lidar{ff},result_path);

%     % WITH deadtime (DC,BC,RC)
%     plot_color_4ch_fct(signal,'signal',save_all_plots,InputFiles_lidar{ff},result_path);
%
disp('Color Plots - done');



%% Profil-Plots fuer Zeitausschnitt (2Dim) %%%%%%%%%%%%%%%%%%%%%%%

%%%% (Time)Mean of Backgr.- and Rangecorrected signal
% Without deadtime
meano_time_signal_bc_rc_plotscript = nanmean(signal_Mcps_bc_rc(:,height_rof_profile_in_bins,time_rof_profile_in_bins),3);
% WITH deadtime
meano_time_signal_plotscript = nanmean(signal(:,height_rof_profile_in_bins,time_rof_profile_in_bins),3);
% Plot the 2 signals
plot_profile_mean_fct(meano_time_signal_bc_rc_plotscript,meano_time_signal_plotscript,' sig_bc_rc , sig',time_rof_profile_in_bins,save_all_plots,InputFiles_lidar{ff},result_path);

disp('Profile Plots done');



%% Plot 3d signal with cloudbase line
% plot_color_3dSignal_plus_2dCloudbase_fct(signal_Mcps_bc_rc(1,:,:),cloudbase_Mcps_bc_rc,'signal McpsBcRc total_{in}',save_all_plots,InputFiles_lidar{ff},result_path);
plot_color_3dSignal_plus_2dCloudbase_fct(signal(1,:,:),  cloudbase,  'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);



%% Mean(over time)Depol and Ratio( only range resolved) (2Dim) %%  and plot %%%%%%%%%%%%%%



%%% Plot the two depols and ratio of (without DC) and (with DC) --------
plot_depol_mean_fct(depol_in_mean_smooth , depol_out_mean_smooth , ratio_depol_mean_inout_smooth ,...
                     depol_in_mean_smooth , depol_out_mean_smooth , ratio_depol_mean_inout_smooth , ...
                     'dc_bc_rc_smooth and dc_bc_rc_smooth',time_rof_profile_in_bins,save_all_plots,InputFiles_lidar{ff},result_path)
                 

                 

    %%% Plot ratios of the Non-Deadtimecorrected and Deadtimecorrected signals and depols and depolratio
%     plot_ratios_for_deadtime_correction_effect_fct(signal_Mcps_bc_rc,...
%                                                         signal,...
%                                                         depol_in_mean_Mcps_bc_rc,...
%                                                         depol_out_mean_Mcps_bc_rc,...
%                                                         depol_in_mean,...
%                                                         depol_out_mean,...
%                                                         depol_in_Mcps_bc_rc,...
%                                                         depol_out_Mcps_bc_rc,...
%                                                         depol_in,...
%                                                         depol_out,...
%                                                         time_rof_profile_in_bins,height_rof_profile_in_bins,...
%                                                         save_all_plots,InputFiles_lidar{ff},result_path)

%% Plot to show effect of smoothing


% plot_to_show_effect_of_smoothing_fct(depolratio_mean_above_CB_res_smooth_redutime,depolratio_mean_above_CB_res_inCB_range,time_rof_clouds_res,save_all_plots,InputFiles_lidar{ff},result_path);
%clear depolratio_mean_above_CB_res_inCB_range;







%% Plot inversion results
plot_inversion_results_fct_2_0(cdnc_in_cm,   alpha_per_km,   r_eff_in_microns,   lwc_in_g_per_cubicmeter,...
                        cloudbase_inM_low_res,...
                        time_rof_clouds_low_res,...
                        measurement_time_num,...          %just for the leght of the fullsignal
                        save_all_plots,InputFiles_lidar{ff},result_path);


%% Analysis of Inversion Success

plot_inversion_success_analysis_fct_2_0(cloudbase_inM_low_res, time_rof_clouds_low_res, ...
    depolratio_mean_above_CB_res_smooth_redutime_smooth, depolratio_allowed_range_res, ...
    depol_in_mean_above_CB_res_smooth_redutime_smooth,...
    max_Mcps_in_cloudrange, max_Mpcs_in_cloudrange_height_bin,...
    save_all_plots, InputFiles_lidar{ff}, result_path);

end




