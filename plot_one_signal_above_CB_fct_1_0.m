% Plot depol mean 2D
%
% 2 Graphs in one plot
%
%
% call examples:
% 
%  
%  


function plot_one_signal_above_CB_fct_1_0(sig_L,CB_L,timebin_to_plot_in_CB_res,C_in,C_out,save_all_plots_L,InputFile,result_path_L)



txt= ['One Signal above CB at 732=rangeofclouds(32)' ,InputFile ];
txt2= [InputFile ,'--one signal above CB '];


aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

% shorten height to signal, and convert to km
% height_L = height_L(1:length(s_in));%./1000;


% Plot range in time domain                 
%       xlimes should be set, else xlim might be different for each plot
% xlimes=[0 max(size(s_in,2),size(s_in,1))];  

ylimes_large=[1000 4500];           %  Plot height range in km
xlimes_large=[1*10^8 5*10^8];        %  Plot Depolrange



s_in_tot    =squeeze(sig_L(1,:,timebin_to_plot_in_CB_res));
s_in_cross  =squeeze(sig_L(2,:,timebin_to_plot_in_CB_res));

s_out_tot    =squeeze(sig_L(3,:,timebin_to_plot_in_CB_res));
s_out_cross  =squeeze(sig_L(4,:,timebin_to_plot_in_CB_res));


% Anpassung der sinhaftigkeiten laut cristofer
s_in_tot_A=s_in_tot./max(s_in_tot);
s_in_cross_A=s_in_cross./max(s_in_cross)./C_in;
s_out_tot_A=s_out_tot./max(s_out_tot);
s_out_cross_A=s_out_cross./max(s_out_cros)./C_out;



no_of_height_bins=length(s_in_tot);

CB_at_time = CB_L(timebin_to_plot_in_CB_res)
for i=1:length(s_in_tot)
    height(i) = CB_at_time + 7.5*(i-1);
end

%% Signal_in -------------------------------------
subplot(1,2,1)

p1=plot(s_in_tot_A,height,'o','DisplayName','<P_{t}>','LineWidth',2);
hold on
plot(s_in_cross_A,height,'o','DisplayName','<P_{\perp}>','LineWidth',2);

yline(CB_at_time,'Color','[0.5 0.5 0.5]','LineStyle','--','LineWidth',2,'HandleVisibility','off');
yline(CB_at_time+75,'Color','[0.5 0.5 0.5]','LineStyle','--','LineWidth',2,'HandleVisibility','off');

set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
%   title(txt,'Interpreter', 'none');

 legend;
ax=p1.Parent;

ylabel('Height [m]');
ax.YMinorTick = 'on'; %more tick marks
% ylim(ylimes_large);                       % if here comes an error-->                                     than probably depol_out could not be calculated, because C_out could not be calculated, because some CB was found below the range of "depol_out_cal_rof_height". adjust eg the latter     and it works again.                                                                                       
% set(gca,'ytick',[0:500:5000]);

xlabel('Rangecorrected Signal [a.u.]');
% xlim(xlimes_large);
ax.XMinorTick = 'on'; %more tick marks



subplot(1,2,2)


plot(s_out_tot_A,height,'o','DisplayName','<P_{t}>','LineWidth',2);
hold on;

p2=plot(s_out_cross_A,height,'o','DisplayName','<P_{\perp}>','LineWidth',2);

yline(CB_at_time,'Color','[0.5 0.5 0.5]','LineStyle','--','LineWidth',2,'HandleVisibility','off');
yline(CB_at_time+75,'Color','[0.5 0.5 0.5]','LineStyle','--','LineWidth',2,'HandleVisibility','off');


set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
 legend;
ax=p2.Parent;

ylabel('Height [m]');
ax.YMinorTick = 'on'; %more tick marks
% ylim(ylimes_large);                       % if here comes an error-->                                     than probably depol_out could not be calculated, because C_out could not be calculated, because some CB was found below the range of "depol_out_cal_rof_height". adjust eg the latter     and it works again.                                                                                       
% set(gca,'ytick',[0:500:5000]);

xlabel('Rangecorrected Signal [a.u.]');
% xlim(xlimes_large);
ax.XMinorTick = 'on'; %more tick marks





if (save_all_plots_L==1)
%     saveas(aa,strcat(result_path_L,'Mean_depol_in_out','_',InputFile_lidar_L(1:end-3),'.jpg'));
    set(aa,'Units','Inches');
    pos = get(aa,'Position');
    set(aa,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(aa,strcat(result_path_L,txt2,'.pdf'),'-dpdf','-r0')

end

end