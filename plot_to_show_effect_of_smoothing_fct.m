%
% Just for test
% to see the effect of smoothing
%  
%  


function plot_to_show_effect_of_smoothing_fct(smoothed,unsmoothed,time_rof_clouds_res,save_all_plots_l,InputFile_lidar_l,result_path_l)

txt= ['depolratio_mean_above_CB_res smoothed and unsmoothed in CB range ' ];
aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

% Plot range in time domain                 
%       xlimes should be set, else xlim might be different for each plot
%xlimes=[0 size(smoothed,2)];                   
%xlimes=[0 800];                                                     

% Plotrange for depol_in/depol_out
%ylimes2=[0 1];




%%
unsmoothed_fulltime(time_rof_clouds_res)= unsmoothed;
smoothed_fulltime(time_rof_clouds_res)=smoothed;
plot(unsmoothed_fulltime,'o');                                                       % unsmoothed data plotted as circles
set(gca,'FontSize',12,'YDir','normal');
title(txt);
ylabel('timebins');
%ylim(ylimes2);
%xlim(xlimes);
hold on
plot(smoothed_fulltime,'s');                                                                % smoothed data plottet as squares




if (save_all_plots_l==1)
    saveas(aa,strcat(result_path_l,txt,'_',InputFile_lidar_l(1:end-3),'.jpg'));
end

end