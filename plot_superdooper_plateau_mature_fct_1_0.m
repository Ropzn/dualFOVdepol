% Plots inversion results

%         cdnc_in_cm
%         alpha_per_km
%         r_eff_in_microns
%         lwc_in_g_per_cubicmeter


function plot_superdooper_plateau_mature_fct_1_0(cdnc_in_cm_L,alpha_per_km_L,r_eff_in_microns_L,lwc_in_g_per_cubicmeter_L,...
                                                cloudbase_inM_lowres_L, time_rof_clouds_res,  num_time_L,...
                                                depol_ratio_mean_above_CB_L, depolratio_allowed_range_L,...
                                                depol_in_mean_above_CB_L,...
                                                depol_out_mean_above_CB_L,...
                                                cloud_max_Mpcs_L, cloud_max_Mpcs_height_bin_L,time_rof_clouds_highres_L,...
                                                xstart,xend,...
                                                ylimes_cb_analysis_L,...
                                                ylimes_alpha_L,...
                                                ylimes_r_L,...
                                                ylimes_lwc_L,...
                                                ylimes_cdnc_L,...
                                                ylimes_mcps_L,...
                                                 ylimes_del_int_L,...
                                                 ylimes_del_rat_L,...
                                                save_all_plots_L,InputFile,result_path_L)

txt= [InputFile,'--Plateaustuff' ];
aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen
                                            
                                            
full_length=length(num_time_L);
% xlimes=[0 full_length];     

xlimes=[xstart xend];   % in numdate                                              
%ylimes=[0 80];

date_tick_range = num_time_L(1:120:end);   % 20-> 10min,    60->1/h std

date_minor_tick_range = num_time_L(1:20:end);




num_time_rof_clouds_res=num_time_L(time_rof_clouds_res);
num_time_rof_clouds_HIGH_res = num_time_L(time_rof_clouds_highres_L);


title(txt);



%% cloudbase and location of max(Mcps)_tot_in in km----------------------------------------------------
subplot(8,1,1)
% plot(xlimes,2,'w','HandleVisibility','off')   % my little invisble helper

%plot(x(~isnan(cloudbase_inM_L)), cloudbase_inM_L(~isnan(cloudbase_inM_L))/1000,'o','DisplayName','CB');
p1=plot(num_time_rof_clouds_res,cloudbase_inM_lowres_L/1000,'o','LineWidth',2);
set(gca,'fontweight','bold','fontsize',20,'YDir','normal');
% title('CB and location of max(Mcps(total,in))in km');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
ax=p1.Parent;
ax.LineWidth=2;
ax.FontName='times';

ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
datetick('x',15,'keepticks','keeplimits');  
set(gca,'xticklabel',[])                            % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten

ylim(ylimes_cb_analysis_L)   %arielle_case 14-15.5.2019 [3.0 4.7]
ax.YMinorTick = 'on' %more tick marks
                                  % arielle 13.11. none
% set(gca,'ytick',[3 3.2 3.4 3.6]); % tadj 16.9.       
ylabel({'Height';'[km]'});




%% Max Mcps value---------------------------------------------------------------
subplot(8,1,2)
plot(num_time_rof_clouds_HIGH_res,cloud_max_Mpcs_L(4,:),'-','LineWidth',2);
hold on
p2=plot(num_time_rof_clouds_HIGH_res,Mcps_2(4,:),':','LineWidth',2);
hold off
set(gca,'fontweight','bold','fontsize',20,'YDir','normal');
    % title('max(Mcps(total,in))in Mcps');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');  
ax=p2.Parent;
ax.LineWidth=2;
ax.FontName='times';

ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
set(gca,'xticklabel',[])    % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten

set(gca,'ytick',[0 50 100]);  % arielle 13.11.
% set(gca,'ytick',[0 20 40]); % tadj 16.9.       

ylim(ylimes_mcps_L)   %arielle_case 14-15.5.2019 [3.0 4.7]
ax.YMinorTick = 'on' %more tick marks
ylabel({'Countrate' ;'[MHz]'});
% set(gca,'YScale','Log')


%% depol in and out mean above cb ------------------------------------------
subplot(8,1,3)
% p4=plot(xlimes,0.1,'w','HandleVisibility','off')   % my little invisble helper

p4=plot(num_time_rof_clouds_res,depol_out_mean_above_CB_L,'o','LineWidth',2);
hold on
plot(num_time_rof_clouds_res,del_out_2,'x','LineWidth',2);

    % title('Integrated mean depol-in-mean-above-CB at max penetration depth');
set(gca,'fontweight','bold','fontsize',20,'YDir','normal');

xlim(xlimes);
set(gca,'xtick',date_tick_range);
ax=p4.Parent;
ax.LineWidth=2;
ax.FontName='times';

ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
datetick('x',15,'keepticks','keeplimits');   
set(gca,'xticklabel',[])    % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten

set(gca,'ytick',[0.01 0.02 0.03 0.04]); % arielle 13.11.
% set(gca,'ytick',[0 0.04 0.06 0.08 0.1]);    % tadj 16.9. 
ylim(ylimes_del_int_L)
ax.YMinorTick = 'on' %more tick marks
ylabel({'\delta^{out}_{int}'});


%% depolratio ratio above cb -------------------------------------------------
subplot(8,1,4)
% plot(xlimes,0.6,'w','HandleVisibility','off')   % my little invisble helper for 
% hold on
plot(num_time_rof_clouds_res,depol_ratio_mean_above_CB_L,'o','LineWidth',2);
hold on
plot(num_time_rof_clouds_res,del_rat_2,'x','LineWidth',2);

plot(num_time_rof_clouds_res,depolratio_allowed_range_L(1,:),'LineWidth',2,'color','black','HandleVisibility','off');
hold on
p3=plot(num_time_rof_clouds_res,depolratio_allowed_range_L(2,:),'LineWidth',2,'color','black','HandleVisibility','off');

hold off

set(gca,'fontweight','bold','fontsize',20,'YDir','normal');
    % title('Integrated mean depol ratio at max penetration depth and boundaries of allowed values for inversion');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
ax=p3.Parent;
ax.LineWidth=2;
ax.FontName='times';

ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
datetick('x',15,'keepticks','keeplimits');   
set(gca,'xticklabel',[])    % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten

ylim(ylimes_del_rat_L)
ax.YMinorTick = 'on' %more tick marks
set(gca,'ytick',[0.4 0.6 0.8 1]);% arielle 13.11. and tadj 16.9.

ylabel('');
ylabel('\delta_{rat}');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




%%% alpha_per_km-------------------------------------------------------------
subplot(8,1,5)
% plot(xlimes,20,'w','HandleVisibility','off')
% hold on
p2=plot(num_time_rof_clouds_res,alpha_per_km_L(end,:),'o','LineWidth',2);
hold on
p2=plot(num_time_rof_clouds_res,a_2(end,:),'x','LineWidth',2);

    % title('alpha per km');
set(gca,'fontweight','bold','fontsize',20,'YDir','normal');

xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic
set(gca,'xticklabel',[])                            % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten
ax=p2.Parent;
ax.LineWidth   =2;
ax.FontName='times';

ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;

ylim(ylimes_alpha_L)
ylabel({'\alpha ';'[km^{-1}]'});
ax.YMinorTick = 'on' %more tick marks
hold off

%%% r_eff_in_microns------------------------------------------------------
subplot(8,1,6)
% plot(xlimes,10,'w','HandleVisibility','off')
% hold on
p3=plot(num_time_rof_clouds_res,r_eff_in_microns_L(end,:),'o','LineWidth',2);
hold on
p3=plot(num_time_rof_clouds_res,r_2(end,:),'x','LineWidth',2);
hold off
    % title('r eff in microns');
set(gca,'fontweight','bold','fontsize',20,'YDir','normal');

xlabel('');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic
set(gca,'xticklabel',[])                            % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten
ax=p3.Parent;
ax.LineWidth   =2;
ax.FontName='times';

ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;

ylim(ylimes_r_L)
ylabel({'r_{eff} ';' [\mu m]'});
ax.YMinorTick = 'on' %more tick marks


%%% LWC in g per m^3------------------------------------------------
subplot(8,1,7)
% plot(xlimes,0.03,'w','HandleVisibility','off')
% hold on
p4=plot(num_time_rof_clouds_res,lwc_in_g_per_cubicmeter_L(end,:),'o','LineWidth',2);
hold on
p4=plot(num_time_rof_clouds_res,lwc_2(end,:),'x','LineWidth',2);
hold off
    % title('LWC in [g / m^3]');
set(gca,'fontweight','bold','fontsize',20,'YDir','normal');

xlabel('');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic
set(gca,'xticklabel',[])                            % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten
ax=p4.Parent;
ax.LineWidth   =2;
ax.FontName='times';

ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;

ylim(ylimes_lwc_L)
ylabel({'LWC ';'[g / m^3]'});
ax.YMinorTick = 'on' %more tick marks

%%% cdnc_in_cm--------------------------------------------------
% plot(xlimes,500,'w','HandleVisibility','off')
% hold on
subplot(8,1,8)
p5=plot(num_time_rof_clouds_res,cdnc_in_cm_L(end,:),'o','LineWidth',2);
set(gca,'YScale','Linear') %Log
hold on
p5=plot(num_time_rof_clouds_res,cdnc_2(end,:),'x','LineWidth',2);
hold off
% title('cdnc in cm');
set(gca,'fontweight','bold','fontsize',20,'YDir','normal');
ax=p5.Parent;
ax.LineWidth   =2;
ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;

xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic
xlabel('Time [UTC]');

ylim(ylimes_cdnc_L)
ylabel({'CDNC ';' [cm^{-3}]'});
ax.YMinorTick = 'on' %more tick marks












% if (save_all_plots_L==1)
%     % als jpg
% %     saveas(aa,strcat(result_path_L,txt(1:end-3),'.jpg'));
%     % als pdf
%     set(aa,'Units','Inches');
%     pos = get(aa,'Position');
%     set(aa,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
%     print(aa,strcat(result_path_L,txt,'.pdf'),'-dpdf','-r0')
% 
% end




end