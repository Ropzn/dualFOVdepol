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


function plot_inversion_success_analysis_2_0_fct(cloudbase_inM_L, time_rof_clouds_L, ...
                                                depol_ratio_mean_above_CB_L, depolratio_allowed_range_L,...
                                                depol_in_mean_above_CB_L,...
                                                cloud_max_Mpcs_L, cloud_max_Mpcs_height_bin_L,...
                                                num_time_L,...
                                                save_all_plots_L, InputFile_L, result_path_L)


xlimes=[0 size(cloud_max_Mpcs_height_bin_L,2)];                                                     %666*7.5m = 5km
%ylimes=[0 80];


%% Plot in real (full) time scale



txt= [InputFile_L,'--Inversion Success Analysis' ];
aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

%xlimes=[0 400];                                                     %666*7.5m = 5km
ylimes_1=[min(cloudbase_inM_L) max(cloudbase_inM_L)];

xlimes=[num_time_L(1) num_time_L(end)];

num_time_rof_clouds_res=num_time_L(time_rof_clouds_L);

date_tick_range = num_time_L(1:60:end);                         % 60 is a good idea since one measurement is of 30sec -> 60x30= 1/2 hour





title(txt);

%%% cloudbase and location of max(Mcps)_tot_in in km
subplot(4,1,1)
hold on
plot(num_time_L,cloud_max_Mpcs_height_bin_L(1,:)*7.5/1000,'DisplayName','{in.tot}');                          %channel 1 -> signal_total_in
plot(num_time_L,cloud_max_Mpcs_height_bin_L(2,:)*7.5/1000,'DisplayName','{in}.{cross}');
plot(num_time_L,cloud_max_Mpcs_height_bin_L(3,:)*7.5/1000,'DisplayName','{out}.{tot}');
plot(num_time_L,cloud_max_Mpcs_height_bin_L(4,:)*7.5/1000,'DisplayName','{in}.{cross}');
%plot(x(~isnan(cloudbase_inM_L)), cloudbase_inM_L(~isnan(cloudbase_inM_L))/1000,'o','DisplayName','CB');
plot(num_time_rof_clouds_res,cloudbase_inM_L/1000,'o','DisplayName','cloudbase');
hold off
set(gca,'FontSize',12,'YDir','normal');
legend;
title('CB and location of max(Mcps(total,in))in km');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks');  

%%% Max Mcps value
subplot(4,1,2)
plot(num_time_L,cloud_max_Mpcs_L(1,:),'DisplayName','Mcps^{in}_{tot}');
hold on
plot(num_time_L,cloud_max_Mpcs_L(2,:),'DisplayName','Mcps^{in}_{cross}');
plot(num_time_L,cloud_max_Mpcs_L(3,:),'DisplayName','Mcps^{out}_{tot}');
plot(num_time_L,cloud_max_Mpcs_L(4,:),'DisplayName','Mcps^{out}_{cross}');
hold off
set(gca,'FontSize',12,'YDir','normal');
legend;
title('max(Mcps(total,in))in Mcps');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks');  

%%% depolratio mean above cb
subplot(4,1,3)
plot(num_time_rof_clouds_res,depol_ratio_mean_above_CB_L,'o');
hold on
plot(num_time_rof_clouds_res,depolratio_allowed_range_L(1,:),'x');
plot(num_time_rof_clouds_res,depolratio_allowed_range_L(2,:),'x');
hold off
title('Integrated mean depol ratio at max penetration depth and boundaries of allowed values for inversion');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks');  

%%% depol in mean above cb
subplot(4,1,4)
plot(num_time_rof_clouds_res,depol_in_mean_above_CB_L,'o');
title('Integrated mean depol-in-mean-above-CB at max penetration depth');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks');  

xlabel('');
ylabel('');





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