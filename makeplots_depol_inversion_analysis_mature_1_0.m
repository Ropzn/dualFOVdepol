

%%
e_cdnc=0.7;   %percent
e_alpha=0.2;
e_reff=0.15;
e_lwc=0.35;
e_cb=0.01;      %meter
  

%% Zeig mir alles
xstart_bin  = 1;
xend_bin    = length(measurement_time_num);


xstart_overview     = measurement_time_num(xstart_bin);% 20:00
xend_overview       = measurement_time_num(xend_bin);   % 03:00



%% Arielle 14.-15.9.2019
xstart_bin  =435;
xend_bin    =1440;

xstart_overview     = measurement_time_num(xstart_bin);% 20:00
xend_overview       = measurement_time_num(xend_bin);   % 03:00

% % Mean depol for: 
% % 2019 - 11 - 13 - 21 - 37 - 0 - 
% % 2019 - 11 - 13 - 21 - 50 - 0 - 
% time_rof_profile_in_bins = 435:461;
% depol_xrange = [0.0 0.02];
% depol_yrange = [0.5 3];      %in km


% % Mean depol for: 
% % 2019 - 11 - 13 - 22 - 0 - 0 - 
% % 2019 - 11 - 13 - 23 - 00 - 0 --
time_rof_profile_in_bins = 481:601;
depol_xrange = [0.0 0.15];
depol_yrange = [0.5 3];      %in km

fprintf('Mean depol for:\n');
fprintf('%d - ',datevec(   measurement_time_num(  time_rof_profile_in_bins(1) ) )    );
fprintf('\n');
fprintf('%d - ',datevec(   measurement_time_num(  time_rof_profile_in_bins(end) ) )    );
fprintf('\n');

% fuer inversion plot
ylimes_cb       = [1.6 1.9];
ylimes_alpha    = [0 25];
ylimes_r        = [5 20];
ylimes_lwc      = [0 0.2];
ylimes_cdnc     = [0 30];

%fuer analysis plot
ylimes_cb_analysis  = [1.5 2.0];
ylimes_mcps         = [0 150];
ylimes_del_int      = [0.01 0.04];
ylimes_del_rat      = [0.35 1.0];











%% Dushanbe 14.-15.9.2019
xstart_bin  =120;
xend_bin    =1200;

xstart_overview     = measurement_time_num(xstart_bin);% 20:00
xend_overview       = measurement_time_num(xend_bin);   % 03:00

% % Mean depol for no Clouds
% % 2019 - 9 - 15 - 19 - 0 - 2 - 
% % 2019 - 9 - 15 - 20 - 0 - 2 - 
time_rof_profile_in_bins = 121:241;
depol_xrange = [0.0 0.2];  %---> log
depol_yrange = [0.5 5];      %in km


% % Mean depol for Clouds
% % 2019 - 9 - 16 - 2 - 41 - 2 - 
% % 2019 - 9 - 16 - 3 - 10 - 2 - 
% time_rof_profile_in_bins = 1043:1101;
time_rof_profile_in_bins = 1043:1151;

depol_xrange = [0.0 0.2];
depol_yrange = [0.5 5];      %in km


fprintf('Mean depol for:\n');
fprintf('%d - ',datevec(   measurement_time_num(  time_rof_profile_in_bins(1) ) )    );
fprintf('\n');
fprintf('%d - ',datevec(   measurement_time_num(  time_rof_profile_in_bins(end) ) )    );
fprintf('\n');

% fuer inversion plot
ylimes_cb       = [3.0 3.6];
ylimes_alpha    = [10 30];
ylimes_r        = [3 7];
ylimes_lwc      = [0.035 0.1];
ylimes_cdnc     = [0 400];

%fuer analysis plot
ylimes_cb_analysis  = [3.0 3.6];
ylimes_mcps         = [0 50];
ylimes_del_int      = [0.02 0.1];
ylimes_del_rat      = [0.4 1.1];











%%
if 1==1                     

%% Plot signal WITHOUT cloudbase line
% close all
plot_color_3dSignal_plus_2dCloudbase_fct_arielle_2ndcase(signal(1,:,:),  NaN,...
                                        measurement_time_num,height,...
                                        cloudbase_inM_low_res,time_rof_clouds_low_res,...
                                        xstart_overview,xend_overview,...
                                        'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);

%% Plot signal signal with cloudbase line
% close all
plot_color_3dSignal_plus_2dCloudbase_fct_arielle_2ndcase(signal(1,:,:),  cloudbase,...
                                        measurement_time_num,height,...
                                        cloudbase_inM_low_res,time_rof_clouds_low_res,...
                                        xstart_overview,xend_overview,...
                                        'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);
%% Plot DEPOL signal WITHOUT cloudbase line
plot_color_3dDepol_plus_2dCloudbase_fct_arielle_2ndcase(depol_in_smoothed,  NaN,...
                                        measurement_time_num,height,...
                                        cloudbase_inM_low_res,time_rof_clouds_low_res,...
                                        xstart_overview,xend_overview,...
                                        'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);

%% Plot DEPOL signal with cloudbase line
plot_color_3dDepol_plus_2dCloudbase_fct_arielle_2ndcase(depol_in_smoothed,  cloudbase,...
                                        measurement_time_num,height,...
                                        cloudbase_inM_low_res,time_rof_clouds_low_res,...
                                        xstart_overview,xend_overview,...
                                        'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);                                    

%% Mean(over time)Depol and ( only range resolved) (2Dim) 
% close all

cloudbase_mean = nanmean(cloudbase_inM(time_rof_profile_in_bins));

cloudbase_min = min(cloudbase_inM(time_rof_profile_in_bins));

% Calculate Calibrated Depol of Mean(over time) inner FOV
depol_in_mean_smooth = depol_fct(   smooth(nanmean(signal_smoothed(1,height_rof_profile_in_bins,time_rof_profile_in_bins),3),smooth_parameter_depol_mean),...
                                            smooth(nanmean(signal_smoothed(2,height_rof_profile_in_bins,time_rof_profile_in_bins),3),smooth_parameter_depol_mean),...
                                            C,Rt_in,Rc_in);
% Calculate Calibrated Depol of Mean(over time) outer FOV
depol_out_mean_smooth = depol_fct(    smooth(nanmean(signal_smoothed(3,height_rof_profile_in_bins,time_rof_profile_in_bins),3),smooth_parameter_depol_mean),...
                                                smooth(nanmean(signal_smoothed(4,height_rof_profile_in_bins,time_rof_profile_in_bins),3),smooth_parameter_depol_mean),...
                                                C_out,Rt_out,Rc_out);     
                                            
plot_depol_in_out_mean_options_fct(depol_in_mean_smooth,depol_out_mean_smooth,...
                            height,...
                            'depol_in_mean_smooth and out',...
                            time_rof_profile_in_bins,...
                            cloudbase_min,...
                            depol_xrange,...
                            depol_yrange,...
                            save_all_plots,InputFiles_lidar{ff},result_path)
                           
                                    


%% Analysis of Inversion Success

plot_inversion_success_analysis_mature_fct_1_0(cloudbase_inM_low_res, time_rof_clouds_low_res, ...
    depolratio_mean_above_CB_res_smooth_redutime_smooth, depolratio_allowed_range_res, ...
    depol_in_mean_above_CB_res_smooth_redutime_smooth,...
    depol_out_mean_above_CB_res_smooth_redutime_smooth,...
    max_Mcps_above_CB_in_cloudrange, max_Mpcs_in_cloudrange_height_bin, time_rof_clouds,...
    measurement_time_num,...
    xstart_overview,xend_overview,...
    ylimes_cb_analysis,...
    ylimes_mcps,...
    ylimes_del_int,...
    ylimes_del_rat,...
    save_all_plots, InputFiles_lidar{ff}, result_path);



%% Plot inversion results

plot_inversion_results_mature_fct_1_0(cdnc_in_cm,   alpha_per_km,   r_eff_in_microns,   lwc_in_g_per_cubicmeter,...
                        cloudbase_inM_low_res,...
                        time_rof_clouds_low_res,...
                        measurement_time_num,...          %just for the leght of the fullsignal
                        xstart_overview,xend_overview,...
                        ylimes_cb,...
                        ylimes_alpha,...
                        ylimes_r,...
                        ylimes_lwc,...
                        ylimes_cdnc,...
                        save_all_plots,InputFiles_lidar{ff},result_path);

                    
%% Plot inversion results with ERROR bars

plot_inversion_results_mature_error_fct_1_0(cdnc_in_cm, e_cdnc,...
                        alpha_per_km, e_alpha,...
                        r_eff_in_microns, e_reff,...
                        lwc_in_g_per_cubicmeter, e_lwc,...
                        cloudbase_inM_low_res, e_cb,...
                        time_rof_clouds_low_res,...
                        measurement_time_num,...          %just for the leght of the fullsignal
                        xstart_overview,xend_overview,...
                        ylimes_cb,...
                        ylimes_alpha,...
                        ylimes_r,...
                        ylimes_lwc,...
                        ylimes_cdnc,...
                        save_all_plots,InputFiles_lidar{ff},result_path);
                    
                    
                    

%%
plot_superdooper_plateau_mature_fct_1_0(cdnc_in_cm,alpha_per_km,r_eff_in_microns,lwc_in_g_per_cubicmeter,...
                                                cloudbase_inM_low_res, time_rof_clouds_low_res,  measurement_time_num,...
                                                depolratio_mean_above_CB_res_smooth_redutime_smooth, depolratio_allowed_range_res, ...
                                                depol_in_mean_above_CB_res_smooth_redutime_smooth,...
                                                depol_out_mean_above_CB_res_smooth_redutime_smooth,...
                                                max_Mcps_above_CB_in_cloudrange, max_Mpcs_in_cloudrange_height_bin, time_rof_clouds,...
                                                xstart_overview,xend_overview,...
                        ylimes_cb,...
                        ylimes_alpha,...
                        ylimes_r,...
                        ylimes_lwc,...
                        ylimes_cdnc,...
                        ylimes_mcps,...
    ylimes_del_int,...
    ylimes_del_rat,...
                                                save_all_plots,InputFiles_lidar{ff},result_path);
end




