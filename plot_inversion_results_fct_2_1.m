% Plots inversion results

%         cdnc_in_cm
%         alpha_per_km
%         r_eff_in_microns
%         lwc_in_g_per_cubicmeter


function plot_inversion_results_fct_2_1(cdnc_in_cm_L,alpha_per_km_L,r_eff_in_microns_L,lwc_in_g_per_cubicmeter_L,...
                                                cloudbase_res_inM, time_rof_clouds_res,  num_time_L,...
                                                save_all_plots_L,InputFile,result_path_L)

full_length=length(num_time_L);
xlimes=[0 full_length];                                                     %666*7.5m = 5km
%ylimes=[0 80];




%% Plot in real (full) time scale

% cdnc_in_cm_fulltime(time_rof_clouds_res)=squeeze(cdnc_in_cm(end,:));                        % cdnc_in_cm(end,:) gives cdnc at max penetration depth
% alpha_per_km_fulltime(time_rof_clouds_res) = squeeze(alpha_per_km(end,:));
% r_eff_in_microns_fulltime(:,time_rof_clouds_res) = r_eff_in_microns(end,:);
% lwc_in_g_per_cubicmeter_fulltime(:,time_rof_clouds_res) = lwc_in_g_per_cubicmeter;

txt= [InputFile,'--Inversionresults' ];
aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

xlimes=[num_time_L(1) num_time_L(end)];

num_time_rof_clouds_res=num_time_L(time_rof_clouds_res);

date_tick_range = num_time_L(1:60:end);             % 60 is a good idea since one measurement is of 30sec -> 60x30= 1/2 hour
% has problems when there are gaps in the data

%%specify the range explicitely
%date_tick_range= datetime(2014,1,1,1,0,0):hours(1):datetime(2014,1,1,8424,0,0);

%xlimes=[0 400];                                                     %666*7.5m = 5km
%ylimes=[0 80];
% x=1:length(full_length);

title(txt);

%%% cloudbase in km
subplot(5,1,1)
% plot(x(~isnan(cloudbase_res_inM)),cloudbase_res_inM(~isnan(cloudbase_res_inM))/1000,'o');
% plot(xlimes,2,'w')
% hold on
plot(num_time_rof_clouds_res,cloudbase_res_inM/1000,'o');
title('CB in km');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic

%%% alpha_per_km
subplot(5,1,2)
% plot(xlimes,20,'w')
% hold on
plot(num_time_rof_clouds_res,alpha_per_km_L(end,:),'o');
title('alpha per km');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic

%%% r_eff_in_microns
subplot(5,1,3)
% plot(xlimes,10,'w')
% hold on
plot(num_time_rof_clouds_res,r_eff_in_microns_L(end,:),'o');
title('r eff in microns');
xlabel('');
ylabel('');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic

%%% LWC in g per m^3
subplot(5,1,4)
% plot(xlimes,0.03,'w')
% hold on
plot(num_time_rof_clouds_res,lwc_in_g_per_cubicmeter_L(end,:),'o');
title('LWC in [g / m^3]');
xlabel('');
ylabel('');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic

%%% cdnc_in_cm
% plot(xlimes,500,'w')
% hold on
subplot(5,1,5)
plot(num_time_rof_clouds_res,cdnc_in_cm_L(end,:),'o');
set(gca,'YScale','Log')
title('cdnc in cm');
ylabel('');
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic

if (save_all_plots_L==1)
    % als jpg
%     saveas(aa,strcat(result_path_L,txt(1:end-3),'.jpg'));
    % als pdf
    set(aa,'Units','Inches');
    pos = get(aa,'Position');
    set(aa,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(aa,strcat(result_path_L,txt,'.pdf'),'-dpdf','-r0')

end




end