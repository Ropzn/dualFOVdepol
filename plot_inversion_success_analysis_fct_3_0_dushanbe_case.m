%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function analyses the inversion routine success rate.
%
%   Input: 
%                              
%
%   Output:                             
%   
%   example call:
%
%                               
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function plot_inversion_success_analysis_fct_3_0_dushanbe_case(cloudbase_inM_L, time_rof_clouds_res_L, ...
                                                depol_ratio_mean_above_CB_L, depolratio_allowed_range_L,...
                                                depol_in_mean_above_CB_L,...
                                                depol_out_mean_above_CB_L,...
                                                cloud_max_Mpcs_L, time_rof_clouds_L,...
                                                num_time_L,...
                                                xstart,xend,...
                                                save_all_plots_L, InputFile_L, result_path_L)





%% Plot in real (full) time scale



txt= [InputFile_L,'--Inversion Success Analysis' ];
aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

%xlimes=[0 400];                                                     %666*7.5m = 5km
ylimes_1=[min(cloudbase_inM_L) max(cloudbase_inM_L)];

% xlimes=[num_time_L(1) num_time_L(end)];
xlimes=[xstart xend];

num_time_rof_clouds_res=num_time_L(time_rof_clouds_res_L);
num_time_rof_clouds    =num_time_L(time_rof_clouds_L);


% date_tick_range = num_time_L(1:60:end);                         % 60 is a good idea since one measurement is of 30sec -> 60x30= 1/2 hour
date_tick_range = num_time_L(1:60:end);   % 20-> 10min,    60->1/2h std

date_minor_tick_range = num_time_L(1:10:end);

title(txt);






%%% cloudbase and location of max(Mcps)_tot_in in km----------------------------------------------------
subplot(4,1,1)
plot(xlimes,2,'w','HandleVisibility','off')   % my little invisble helper
hold on
% plot(num_time_L,cloud_max_Mpcs_height_bin_L(1,:)*7.5/1000,'DisplayName','height.PMax^{in}_{tot}','LineWidth',2);                          %channel 1 -> signal_total_in
% plot(num_time_L,cloud_max_Mpcs_height_bin_L(2,:)*7.5/1000,'DisplayName','height.PMax^{in}_{cross}','LineWidth',2);
% plot(num_time_L,cloud_max_Mpcs_height_bin_L(3,:)*7.5/1000,':','DisplayName','height.PMax^{out}_{tot}','LineWidth',2);
% plot(num_time_L,cloud_max_Mpcs_height_bin_L(4,:)*7.5/1000,':','DisplayName','height.PMax^{out}_{cross}','LineWidth',2);
%plot(x(~isnan(cloudbase_inM_L)), cloudbase_inM_L(~isnan(cloudbase_inM_L))/1000,'o','DisplayName','CB');
p1=plot(num_time_rof_clouds_res,cloudbase_inM_L/1000,'o','LineWidth',2,'DisplayName','cloudbase');
hold off
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
legend( 'Location', 'eastoutside');
% title('CB and location of max(Mcps(total,in))in km');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
ax=p1.Parent;
ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
datetick('x',15,'keepticks','keeplimits');  
set(gca,'xticklabel',[])                            % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten

ylim([0.5 4.0])   %arielle_case 14-15.5.2019 [3.0 4.7]
ax.YMinorTick = 'on' %more tick marks
ylabel('Height [km]');

%%% Max Mcps value---------------------------------------------------------------
subplot(4,1,2)
% plot(xlimes,50,'w','HandleVisibility','off')   % my little invisble helper

plot(num_time_rof_clouds,cloud_max_Mpcs_L(1,:),'o','DisplayName','PMax_{in}^{tot}','LineWidth',2);
hold on
plot(num_time_rof_clouds,cloud_max_Mpcs_L(2,:),'o','DisplayName','PMax_{in}^{_|}','LineWidth',2);
plot(num_time_rof_clouds,cloud_max_Mpcs_L(3,:),'s','DisplayName','PMax_{out}^{tot}','LineWidth',2);
p2=plot(num_time_rof_clouds,cloud_max_Mpcs_L(4,:),'s','DisplayName','PMax_{out}^{_|}','LineWidth',2);

yline(60,'--','color','black','HandleVisibility','off');
hold off
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
legend( 'Location', 'eastoutside');
    % title('max(Mcps(total,in))in Mcps');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');  
ax=p2.Parent;
ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
set(gca,'xticklabel',[])    % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten

% ylim([0 300])   %arielle_case 14-15.5.2019 [3.0 4.7]
% set(gca,'YScale','Log')

% set(gca,'ytick',[0 1 100 1000]);
ax.YMinorTick = 'on' %more tick marks
ylabel('Countrate [MHz]');




%%% depol in and out mean above cb ------------------------------------------
subplot(4,1,3)
p4=plot(xlimes,0.1,'w','HandleVisibility','off')   % my little invisble helper
hold on
plot(num_time_rof_clouds_res,depol_in_mean_above_CB_L,'o','LineWidth',2,'DisplayName','\delta^{in}_{int}');
plot(num_time_rof_clouds_res,depol_out_mean_above_CB_L,'o','LineWidth',2,'DisplayName','\delta^{out}_{int}');
legend( 'Location', 'eastoutside');
    % title('Integrated mean depol-in-mean-above-CB at max penetration depth');
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');

xlim(xlimes);
set(gca,'xtick',date_tick_range);
ax=p4.Parent;
ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
datetick('x',15,'keepticks','keeplimits');   
set(gca,'xticklabel',[])    % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten


% ylim([0.0 0.14])
ax.YMinorTick = 'on' %more tick marks



%%% depolratio ratio above cb -------------------------------------------------
subplot(4,1,4)
plot(xlimes,0.6,'w','HandleVisibility','off')   % my little invisble helper
hold on
plot(num_time_rof_clouds_res,depol_ratio_mean_above_CB_L,'o','LineWidth',2,'DisplayName','\delta_{r}');
plot(num_time_rof_clouds_res,depolratio_allowed_range_L(1,:),'LineWidth',0.2,'color','0.9 0.9 0.9','HandleVisibility','off');
p3=plot(num_time_rof_clouds_res,depolratio_allowed_range_L(2,:),'LineWidth',0.2,'color','0.9 0.9 0.9','HandleVisibility','off');
hold off
legend( 'Location', 'eastoutside');

set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
    % title('Integrated mean depol ratio at max penetration depth and boundaries of allowed values for inversion');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
ax=p3.Parent;
ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
datetick('x',15,'keepticks','keeplimits');  
datetick('x',15,'keepticks','keeplimits');   
xlabel('Time [UTC]');

% ylim([0.5 1.1])
ax.YMinorTick = 'on' %more tick marks







if (save_all_plots_L==1)
%     saveas(aa,strcat(result_path_L,txt(1:end-3),'.jpg'));
    % Als PDF
    set(aa,'Units','Inches');
    pos = get(aa,'Position');
    set(aa,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(aa,strcat(result_path_L,txt,'.pdf'),'-dpdf','-r0')

end





%% Experimentell : Plot der verschiedenfarbig hinterlegt ist, je nachdem ob inversion success oder nicht
% for t=1:length(depol_ratio_above_CB_L)
%     if ( (depolratio_allowed_range_L(1,t) < depol_ratio_above_CB_L(t))   &   (depol_ratio_above_CB_L(t) < depolratio_allowed_range_L(2,t) )  )
%         inversion_success(t,1)=1;
%         inversion_success(t,2)=0;
%         inversion_success(t,3)=1;
%     else
%         inversion_success(t,1)=0;
%         inversion_success(t,2)=0;
%         inversion_success(t,3)=1;
%     end
% end
% inversion_success_fulltime(1:720,1:3)=0;
% inversion_success_fulltime(time_rof_clouds_L,:)=inversion_success;
% 
% figure
% imc=image(inversion_success_fulltime)
% imc.AlphaData = 0.5;
% hold on
% plot(depol_ratio_fulltime,'o');
% plot(depolratio_allowed_range_fulltime(1,:),'x');
% plot(depolratio_allowed_range_fulltime(2,:),'x');
% hold off
% title('Integrated mean depol ratio at max penetration depth and boundaries of allowed values for inversion');
% %xlim(xlimes);
% 
% xlabel('');
% ylabel('');

%%







end