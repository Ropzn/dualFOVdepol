% Plot depol mean 2D
%
% 2 Graphs in one plot
%
%
% call examples:
% 
%  
%  


function plot_depol_in_out_mean_fct(s_in,s_out,height_L,sig_names,time_rof_profile_in_bins_L,save_all_plots_L,InputFile,result_path_L)

txt= ['Depol in and out: Mean(Time [' ,num2str(min(time_rof_profile_in_bins_L)), '..' ,num2str(max(time_rof_profile_in_bins_L)), '] of ',sig_names,'--',InputFile ];
txt2= [InputFile ,'--Depol in and out'];


aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

% shorten height to signal, and convert to km
height_L = height_L(1:length(s_in));%./1000;
height_L_in_km = height_L(1:length(s_in))./1000;


% Plot range in time domain                 
%       xlimes should be set, else xlim might be different for each plot
% xlimes=[0 max(size(s_in,2),size(s_in,1))];  

ylimes_large=[1000 4500];           %  Plot height range in km
xlimes_large=[0 0.3];        %  Plot Depolrange

ylimes_zoom=[3850 3980];
% xlimes_zoom=[0 0.1];        %  Plot Depolrange


% ymin=min([min(s_in),min(s_out)]);
% ymax=max([max(s_in),max(s_out)]);
% ylimesdepol=[ymin ymax];



%% Depol_in and Depol_out mean  ------------large scale-------------------------------------
subplot(1,2,1)
plot(s_in,height_L,'DisplayName','\delta_{in}','LineWidth',2);
hold on;
p1=plot(s_out,height_L,'DisplayName','\delta_{out}','LineWidth',2);
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
%   title(txt,'Interpreter', 'none');

legend;
ax=p1.Parent;

ylabel('Height [m]');
ax.YMinorTick = 'on' %more tick marks
ylim(ylimes_large);                       % if here comes an error-->                                     than probably depol_out could not be calculated, because C_out could not be calculated, because some CB was found below the range of "depol_out_cal_rof_height". adjust eg the latter     and it works again.                                                                                       
set(gca,'ytick',[0:500:5000]);

xlabel('Volume Depolarization Ratio');
xlim(xlimes_large);
ax.XMinorTick = 'on'; %more tick marks


%% Depol_in and Depol_out mean  ------------zoomed in-------------------------------------
subplot(1,2,2)
plot(s_in,height_L,'DisplayName','\delta_{in}','LineWidth',2);
hold on;
p1=plot(s_out,height_L,'DisplayName','\delta_{out}','LineWidth',2);
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
%   title(txt,'Interpreter', 'none');

legend;
ax=p1.Parent;

ylabel('Height [m]');
ax.YMinorTick = 'on'; %more tick marks
ylim(ylimes_zoom);                       % if here comes an error-->                                     than probably depol_out could not be calculated, because C_out could not be calculated, because some CB was found below the range of "depol_out_cal_rof_height". adjust eg the latter     and it works again.                                                                                       
set(gca,'ytick',[0:10:5000]);

xlabel('Volume Depolarization Ratio');
% xlim(xlimes_zoom);
ax.XMinorTick = 'on' %more tick marks







if (save_all_plots_L==1)
%     saveas(aa,strcat(result_path_L,'Mean_depol_in_out','_',InputFile_lidar_L(1:end-3),'.jpg'));
    set(aa,'Units','Inches');
    pos = get(aa,'Position');
    set(aa,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(aa,strcat(result_path_L,txt2,'.pdf'),'-dpdf','-r0')

end

end