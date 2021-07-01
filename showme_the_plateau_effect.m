%% compare corrected and uncorrected dead-time thingi arielle 13.11.

%% save uncorrected / normal
% cloudbase_inM_low_res;
% time_rof_clouds_low_res;
% depolratio_allowed_range_res;
% time_rof_clouds;
% measurement_time_num;

del_rat_2   = depolratio_mean_above_CB_res_smooth_redutime_smooth;
del_in_2    = depol_in_mean_above_CB_res_smooth_redutime_smooth;
del_out_2   = depol_out_mean_above_CB_res_smooth_redutime_smooth;
Mcps_2      = max_Mcps_above_CB_in_cloudrange;
a_2         = alpha_per_km;
r_2         = r_eff_in_microns;
lwc_2       = lwc_in_g_per_cubicmeter;
cdnc_2      = cdnc_in_cm;

save(strcat('C:\Robert\Master\Software\ND-Filter\deadtime_plateau_new.mat'),...
            'del_rat_2',...
            'del_in_2',...
            'del_out_2',...
            'Mcps_2',...
            'a_2',...
            'r_2',...
            'lwc_2',...
            'cdnc_2');
                                                            
                                                          
disp('saved all plateau stuff');