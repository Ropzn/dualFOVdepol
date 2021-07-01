% Plot profile mean 2D
%
% 2x2 2D-Plots in one figure
%
% each Plot might contain 1,2 or 3 graphs.
%
%
% call examples:
% 
%   1.Plotting only one graph per Plot (set sig2=0 !)
%       plot_profile_mean_fct(meano_time_raw_signal,0,'raw signal',time_rof_profile_in_bins_l,save_all_plots_l,InputFile_lidar_l,result_path_l);
%
%   2.Plotting 2 graphs per Plot 
%       plot_profile_mean_fct(meano_time_raw_signal,meano_time_signal_dc,'raw signal and dc-signal',time_rof_profile_in_bins_l,save_all_plots_l,InputFile_lidar_l,result_path_l);
%
%  


function plot_profile_mean_fct(sig1,sig2,sig_names,time_rof_profile_in_bins_l,save_all_plots_l,InputFile_lidar_l,result_path_l)

txt= ['Mean over Time bins ' ,num2str(min(time_rof_profile_in_bins_l)), '..' ,num2str(max(time_rof_profile_in_bins_l)), ' of ',sig_names ];
aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

xlimes=[0 400];                                                     %666*7.5m = 5km
ylimes=[0 80];

%%% Total_in Mean Signal 
subplot(2,2,1)
plot(sig1(1,:),'DisplayName','signal 1}');
if length(sig2)>1
    hold on;
    plot(sig2(1,:),'DisplayName','signal 2}');
end
set(gca,'FontSize',12,'YDir','normal');
title('Total_{in}');
ylabel('Mean Signal');
%xlim(xlimes);

%%% Perp_in Mean Signal 
subplot(2,2,2)
plot(sig1(2,:));
if length(sig2)>1
    hold on;
    plot(sig2(2,:));
end
set(gca,'FontSize',12,'YDir','normal');
title('Perp_{in}');
%xlim(xlimes);

%%% Total_out Mean Signal
subplot(2,2,3)
plot(sig1(3,:));
if length(sig2)>1
    hold on;
    plot(sig2(3,:));
end
set(gca,'FontSize',12,'YDir','normal');
title('Total_{out}');
xlabel('Height, [bins]');
ylabel('Mean Signal');
%xlim(xlimes);

%%% Perp_out Mean Signal 
subplot(2,2,4)
plot(sig1(4,:));
if length(sig2)>1
    hold on;
    plot(sig2(4,:));
end
set(gca,'FontSize',12,'YDir','normal');
title('Perp_{out}');
xlabel('Height, [bins]');
%xlim(xlimes);

if (save_all_plots_l==1)
    saveas(aa,strcat(result_path_l,'Mean_Signal','_',sig_names,'_',InputFile_lidar_l(1:end-3),'.jpg'));
end

end