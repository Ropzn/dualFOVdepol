% Plot depol mean and ratio 2D
%
% 2x2 2D-Plots in one figure
%
%
% call examples:
% 
%  
%  


function plot_ratios_for_deadtime_correction_effect_fct(signal_Mcps_bc_rc,...
                                                        signal_dc_bc_rc,...
                                                        depol_in_mean_Mcps_bc_rc,...
                                                        depol_out_mean_Mcps_bc_rc,...
                                                        depol_in_mean_dc_bc_rc,...
                                                        depol_out_mean_dc_bc_rc,...
                                                        depol_in_Mcps_bc_rc,...
                                                        depol_out_Mcps_bc_rc,...
                                                        depol_in_dc_bc_rc,...
                                                        depol_out_dc_bc_rc,...
                                                        time_rof_profile_in_bins,height_rof_profile_in_bins,...
                                                        save_all_plots_l,InputFile_lidar_l,result_path_l)

txt= ['Ratios for DC-Effect TimeMean[' ,num2str(min(time_rof_profile_in_bins)), '..' ,num2str(max(time_rof_profile_in_bins)),']'];
aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

% Plot range in time domain                 
%       xlimes should be set, else xlim might be different for each plot
%xlimes=[0 size(s_in1,2)];  
%xlimes=[0 500];

% Plotrange for depol_in/depol_out
%ylimesdepol=[0 0.04];
%ylimesratio=[0.5 2];

%% calculations
in_par_tauzero  = nanmean(signal_Mcps_bc_rc(1,height_rof_profile_in_bins,time_rof_profile_in_bins),3);
in_par_tau      = nanmean(signal_dc_bc_rc(1,height_rof_profile_in_bins,time_rof_profile_in_bins),3);

in_perp_tauzero = nanmean(signal_Mcps_bc_rc(2,height_rof_profile_in_bins,time_rof_profile_in_bins),3);
in_perp_tau     = nanmean(signal_dc_bc_rc(2,height_rof_profile_in_bins,time_rof_profile_in_bins),3);

out_tot_tauzero  = nanmean(signal_Mcps_bc_rc(3,height_rof_profile_in_bins,time_rof_profile_in_bins),3);
out_tot_tau      = nanmean(signal_dc_bc_rc(3,height_rof_profile_in_bins,time_rof_profile_in_bins),3);

out_perp_tauzero = nanmean(signal_Mcps_bc_rc(4,height_rof_profile_in_bins,time_rof_profile_in_bins),3);
out_perp_tau     = nanmean(signal_dc_bc_rc(4,height_rof_profile_in_bins,time_rof_profile_in_bins),3);

d_ratio_tauzero = depol_in_Mcps_bc_rc ./depol_out_Mcps_bc_rc;
d_ratio_tau     = depol_in_dc_bc_rc   ./depol_out_dc_bc_rc;

depol_ratio_tauzero = nanmean(d_ratio_tauzero(height_rof_profile_in_bins,time_rof_profile_in_bins),2);
depol_ratio_tau     = nanmean(    d_ratio_tau(height_rof_profile_in_bins,time_rof_profile_in_bins),2);



%% plots
%---inner FOV
subplot(6,2,1)
plot(in_par_tauzero,'DisplayName','Tau=0');
hold on;
plot(in_par_tau,'DisplayName','Tau');
title('Parallel_{in}');
legend;
hold off;

subplot(6,2,2)
plot( in_par_tauzero ./in_par_tau) ;
title('in_ par_ tauzero /in_ par_ tau');
hold off;


subplot(6,2,3)
plot(in_perp_tauzero,'DisplayName','Tau=0');
hold on;
plot(in_perp_tau,'DisplayName','Tau');
title('Perp_{in}');
legend;
hold off;

subplot(6,2,4)
plot( in_perp_tauzero ./in_perp_tau) ;
title('in_ perp_ tauzero /in_ perp_ tau');

%---outer FOV

subplot(6,2,5)
plot(out_tot_tauzero,'DisplayName','Tau=0');
hold on;
plot(out_tot_tau,'DisplayName','Tau');
title('Total_{out}');
legend;
hold off;

subplot(6,2,6)
plot( out_tot_tauzero ./out_tot_tau) ;
title('out_ tot_ tauzero /out_ tot_ tau');
hold off;


subplot(6,2,7)
plot(out_perp_tauzero,'DisplayName','Tau=0');
hold on;
plot(out_perp_tau,'DisplayName','Tau');
title('Perp_{out}');
legend;
hold off;

subplot(6,2,8)
plot( out_perp_tauzero ./out_perp_tau) ;
title('out_ perp_ tauzero /out_ perp_ tau');






%---depols
subplot(6,2,9)
plot( depol_in_mean_Mcps_bc_rc ./ depol_in_mean_dc_bc_rc) ;
title('depol_ in tauzero / depol_ in tau');

subplot(6,2,10)
plot( depol_out_mean_Mcps_bc_rc ./ depol_out_mean_dc_bc_rc) ;
title('depol out tauzero / depol out tau');

%---ratio of depols
subplot(6,2,11)
plot( depol_ratio_tauzero ./depol_ratio_tau) ;
title('ratio_ tauzero / ratio_ tau');

    


if (save_all_plots_l==1)
    saveas(aa,strcat(result_path_l,'Deadtime_analysis_',InputFile_lidar_l(1:end-3),'.jpg'));
end

end


























