% Plot depol mean 2D
%
% 2 Graphs in one plot
%
%
% call examples:
% 
%  
%  


function plot_depol_in_out_mean_options_fct(s_in,s_out,...
                                                height_L,sig_names,...
                                                time_rof_profile_in_bins_L,...
                                                save_all_plots_L,InputFile,result_path_L)

txt= ['Depol in and out: Mean(Time [' ,num2str(min(time_rof_profile_in_bins_L)), '..' ,num2str(max(time_rof_profile_in_bins_L)), '] of ',sig_names,'--',InputFile ];
txt2= [InputFile ,'--Depol in and out'];


aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

% shorten height to signal, and convert to km
height_L = height_L(1:length(s_in))./1000;



% Plot range in time domain                 
%       xlimes should be set, else xlim might be different for each plot
% xlimes=[0 max(size(s_in,2),size(s_in,1))];  
% xlimes=[-0.03 0.7];        %  Plot Depolrange
xlimes=[-0.015 0.7];
ylimes=[0 8];           %  Plot height range in km


% ymin=min([min(s_in),min(s_out)]);
% ymax=max([max(s_in),max(s_out)]);
% ylimesdepol=[ymin ymax];



%% Depol_in and Depol_out mean
plot(s_in,height_L,'DisplayName','Depol_{in}');
hold on;
plot(s_out,height_L,'DisplayName','Depol_{out}');
set(gca,'FontSize',12,'YDir','normal');
title(txt,'Interpreter', 'none');
ylabel('Height [km]');
xlabel('Time-Mean of Depol');
ylim(ylimes);                       % if here comes an error-->                                     than probably depol_out could not be calculated, because C_out could not be calculated, because some CB was found below the range of "depol_out_cal_rof_height". adjust eg the latter     and it works again.                                                                                       
xlim(xlimes);
legend;
     ax = gca;
     ax.XAxis.MinorTick = 'on';
     ax.XAxis.MinorTickValues = 0:0.01:1;
     grid on;
     ax.XMinorGrid = 'on';

     
     
     
     

if (save_all_plots_L==1)
%     saveas(aa,strcat(result_path_L,'Mean_depol_in_out','_',InputFile_lidar_L(1:end-3),'.jpg'));
    set(aa,'Units','Inches');
    pos = get(aa,'Position');
    set(aa,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(aa,strcat(result_path_L,txt2,'.pdf'),'-dpdf','-r0')

end

end