%% translate to time UTC
% disp('-------------');
% bin_cn=2119;
% hours_from_start = time(bin_cn);
% hours_cn = floor(hours_from_start);
% minutes_cn = mod(hours_from_start*60,60);
% 
% fprintf('how much time passed: %2.0f hours   and  %2.2f min \n\n',hours_cn,minutes_cn);


%%

%% range einkuerzen
%  bin_start_cn=2119;
%  bin_end_cn=3514;
%  tagesgrenze ist zwichen bin_cn=2815 u 2816
% bin_end_cn-bin_start_cn;
%  
% clear t_max;
% clear lwc_cn time_cn
% 
% lwc_cn = lwc(:,bin_start_cn:bin_end_cn);
% time_cn=time(bin_start_cn:bin_end_cn);



%% Zeit in time_num umwandeln
clear time_num_cn time_cn

time_cn=time;

start_time_num_13_11_18uhr = 737742;%7.377427500000000e+05;
start_time_num_14_11_00uhr = 737743;

for t=1:2815%697 %length(time_cn)
time_num_cn(t) = start_time_num_13_11_18uhr + time_cn(t)/24;
end

for t=2816:length(time_cn)
time_num_cn(t) = start_time_num_14_11_00uhr + time_cn(t)/24;
end
%%
fprintf('\n-----------\n');
fprintf('%.0f - ' ,datevec(   time_num_cn(1)));



%% values= -999  --> NaN
for t=1:size(lwc,2)
    for h=1:size(lwc,1)
        if lwc(h,t)==-999
            lwc(h,t)=NaN;
        end
    end
    if lwp(t)==-999
        lwp(t)=NaN;
    end
end
lwc_error(lwc_error==-999) =NaN;
lwc_error_percent=10.^(lwc_error./10);

%% cloudbase and cloudtop
clear cb_cloudNet cT_cloudNet;
for t=1:size(lwc,2)
    if isempty(find(lwc(:,t),1,'first'))
        cb_cloudNet(t)=NaN;
        cT_cloudNet(t)=NaN;
           
    elseif isnan(lwc((find(lwc(:,t),1,'first')),t))
        cb_cloudNet(t)=NaN;
        cT_cloudNet(t)=NaN;
        
    else
    cb_cloudNet(t) = find(lwc(:,t),1,'first');   %finds first non-zero element (includes NANs !!1)
    cT_cloudNet(t) = find(lwc(:,t),1,'last');   
    end
end


%% extract n-th lwc above cloud base
clear lwc_1 lwc_2 lwc_3 lwc_7 lwc_top
for t=1:length(time_cn)
    if ~isnan(cb_cloudNet(t))
        lwc_1(t) = lwc(cb_cloudNet(t)+0,t);
        lwc_2(t) = lwc(cb_cloudNet(t)+1,t);
        lwc_3(t) = lwc(cb_cloudNet(t)+2,t);
        lwc_4(t) = lwc(cb_cloudNet(t)+3,t);
        lwc_7(t) = lwc(cb_cloudNet(t)+6,t);
        lwc_top(t)  = lwc(cT_cloudNet(t),t);
        
        lwc_error_percent_1(t) = lwc_error_percent(cb_cloudNet(t)+0,t);
        lwc_error_percent_2(t) = lwc_error_percent(cb_cloudNet(t)+1,t);

    else
        lwc_1(t) = NaN;
        lwc_2(t) = NaN;
        lwc_3(t) = NaN;
        lwc_4(t) = NaN;
        lwc_7(t) = NaN;
        lwc_top(t)  = NaN;
        
        lwc_error_percent_1(t) = NaN;
        lwc_error_percent_2(t) = NaN;
        
    end
end



%% cloudbase in meter
clear cb_cloudNet_inM cT_cloudNet_inM

for t=1:length(cb_cloudNet)
    if ~isnan(cb_cloudNet(t))
        cb_cloudNet_inM(t) = height(cb_cloudNet(t));
        cT_cloudNet_inM(t) = height(cT_cloudNet(t));
    else
        cb_cloudNet_inM(t) = NaN;
        cT_cloudNet_inM(t) = NaN;
    end
end

cT_cloudNet_in_dualFOV_bins = floor(cT_cloudNet_inM ./ 7.5);


%% Finde die nächstliegenste CloudNet-zeit zu dual-FOV-zeit
closestIndex_cb_cN = find_closest_index_fct(measurement_time_num, time_num_cn);

closestIndex_lowres_cN = find_closest_index_fct(measurement_time_num(time_rof_clouds_low_res), time_num_cn);


%% deviation cb_CloudNet and cb_dualFOV    Funktioniert so nicht, wegen verschieden zeitangaben
clear cb_deviation
for t=1:length(measurement_time_num)
%     cb_deviation(t) = cb_cloudNet_inM(closestIndex_cb_cN(t))-15-cloudbase_inM(t)-3.75;
    cb_deviation(t) = cb_cloudNet_inM(closestIndex_cb_cN(t))-cloudbase_inM(t);

end

% mean deviation
disp('cloudNet estimates CB by this amount larger than dualFOV');
mean_cb_deviation = nanmean(cb_deviation)




%% Integriere LWC dual-FOV von CB_dualFOV  bis cT_CloudNet
%   R_eff  [   (z-z_b)  / (z_ref - z_b)   ] ^ 1/3        z=z_b... z_b+400m  --> in bins:  z=1...50    (50*7.5m ~ 400m)
%     
clear r_eff_above_CB bins_above_CB alpha_eff_above_CB lwc_above_CB
bins_above_CB = 1:100;
bins_above_CB = bins_above_CB';

r_eff_above_CB = r_eff(depth_into_cloud_depol_mean,:) .* ( bins_above_CB ./ depth_into_cloud_depol_mean ).^(1/3);

alpha_above_CB = alpha(depth_into_cloud_depol_mean,:) .* ( bins_above_CB ./ depth_into_cloud_depol_mean ).^(2/3);

lwc_above_CB   =  2/3 .* alpha_above_CB .* r_eff_above_CB  ; 

% mittle lwc auf 3min
%%
clear cB_cloudNet_low_res cT_cloudNet_low_res lwp_cn_low_res cB_cloudNet_low_res_inM cT_cloudNet_low_res_inM
for t=1:length(closestIndex_lowres_cN)
    cB_cloudNet_low_res(t) = floor ( nanmean(cb_cloudNet(  ( closestIndex_lowres_cN(t) - 3) :   ( closestIndex_lowres_cN(t) + 2  )  )    ));
    cT_cloudNet_low_res(t) = floor ( nanmean(cT_cloudNet(  ( closestIndex_lowres_cN(t) - 3) :   ( closestIndex_lowres_cN(t) + 2  )  )    ));
    
    lwp_cn_low_res(t)  = nanmean(lwp (( closestIndex_lowres_cN(t) - 3) :   ( closestIndex_lowres_cN(t) + 2  )  )) ;
end
cB_cloudNet_low_res_inM = height(floor(cB_cloudNet_low_res));
cT_cloudNet_low_res_inM = height(floor(cT_cloudNet_low_res));



%% transform cb_CN to cb_dualFOV
clear cb_CN_in_dualFOVbinunits  cT_CN_in_dualFOVbinunits   cloudbase_inbins_low_res
cB_cloudNet_low_res_in_dualFOVbinunits = floor(cB_cloudNet_low_res_inM./7.5 )  ;
cT_cloudNet_low_res_in_dualFOVbinunits = floor(cT_cloudNet_low_res_inM./7.5 )  ;

cloudbase_inbins_low_res = floor(cloudbase_inM_low_res ./7.5);

%%

% integrate lwc over full cloudheight
clear lwp_dualFOV cb_thickness


for t=1:length(lwc_above_CB)
%     cb_thickness(t)= cT_cloudNet_low_res_in_dualFOVbinunits(t) - cloudbase_inbins_low_res(t)+2;
      cb_thickness_lowres_indualFOVunits(t)= (cT_cloudNet_low_res(t) - cB_cloudNet_low_res(t))*4+4;

%         lwp_dualFOV(t) = nansum(lwc_above_CB (   cloudbase_inbins_low_res(t) : ( cloudbase_inbins_low_res(t)+cb_thickness(t) )  )    ) ;
%     lwp_dualFOV(t) = nansum(lwc_above_CB (   (1 : +cb_thickness(t)) ,t  )    ) ;
    lwp_dualFOV(t) = nansum(lwc_above_CB(1:cb_thickness_lowres_indualFOVunits(t),t)); 

end
lwp_dualFOV(lwp_dualFOV==0) = NaN; 





%% mean over lwc_dualFOV over some bins
clear lwc_dualFOV_1 lwc_dualFOV_int_1_to_2 lwc_dualFOV_int_1_to_3 lwc_dualFOV_int_1_to_4
for t=1:length(lwc_above_CB)
        lwc_dualFOV_1(t) = lwc_above_CB(1,t) ;    
        lwc_dualFOV_mean_1_to_2(t) = nanmean(lwc_above_CB(1:2,t) );    
        lwc_dualFOV_mean_1_to_3(t) = nanmean(lwc_above_CB(1:3,t) );    
        lwc_dualFOV_mean_1_to_4(t) = nanmean(lwc_above_CB(1:4,t) );  
        
        lwc_dualFOV_mean_1_to_5(t) = nanmean(lwc_above_CB(1:5,t) );    
        lwc_dualFOV_mean_1_to_6(t) = nanmean(lwc_above_CB(1:6,t) );    
        lwc_dualFOV_mean_1_to_7(t) = nanmean(lwc_above_CB(1:7,t) );    
        lwc_dualFOV_mean_1_to_8(t) = nanmean(lwc_above_CB(1:8,t) );    

               
end

% lwc_dualFOV_mean_equivalent_to_lowest_cn_lwc = (lwc_dualFOV_1+lwc_dualFOV_mean_1_to_2+lwc_dualFOV_mean_1_to_3+lwc_dualFOV_mean_1_to_4)./4;

lwc_dualFOV_mean_equivalent_to_lowest_cn_lwc = (lwc_dualFOV_mean_1_to_5+ lwc_dualFOV_mean_1_to_6+ lwc_dualFOV_mean_1_to_7+ lwc_dualFOV_mean_1_to_8)./4;
% lwc_dualFOV_mean_equivalent_to_lowest_cn_lwc = (lwc_dualFOV_mean_equivalent_to_lowest_cn_lwc +gg_2)./2;



lwc_dualFOV_mean_equivalent_to_lowest_cn_lwc ( lwc_dualFOV_mean_equivalent_to_lowest_cn_lwc==0)=NaN;




%% lwc error
figure
% errorbar(lwc_1,lwc_1.*lwc_error_percent_1)
plot(lwc_1)
hold on
plot(lwc_1+lwc_1.*lwc_error_percent_1)
plot(lwc_1-lwc_1.*lwc_error_percent_1)

    
    
%% plot lwc equivalent

xlimes=[xstart_overview xend_overview]; % in numdate   %kommt aus makeplots parameter-prae-ambel

ylimes=[0 0.1]

date_tick_range = measurement_time_num(1:120:end);   % 20-> 10min,    60->1/h std

date_minor_tick_range = measurement_time_num(1:20:end);

figure

plot(time_num_cn,smooth((lwc_1+lwc_2)/2*1000,10),'LineWidth',2,'Color',[0.8500, 0.3250, 0.0980],'DisplayName','CloudNet');
hold on
plot(time_num_cn,smooth((lwc_1+lwc_2)/2.*(1+(lwc_error_percent_1+lwc_error_percent_2)/2)*1000,10),'Color',[0.8500, 0.3250, 0.0980]+0.14,'HandleVisibility','off')
% plot(time_num_cn,smooth((lwc_1+lwc_2)/2.*(1-lwc_error_percent_1)*1000,10))

p1=errorbar(measurement_time_num(time_rof_clouds_low_res),lwc_dualFOV_mean_equivalent_to_lowest_cn_lwc,lwc_dualFOV_mean_equivalent_to_lowest_cn_lwc*0.35,'.','MarkerEdgeColor',[0,0.4470,0.7410],'MarkerSize',12,'LineWidth',1,'Color',[0,0.4470,0.7410]+0.25, 'DisplayName','dual-FOV');


%-----
set(gca,'fontweight','bold','fontsize',20,'YDir','normal');
legend;
xlim(xlimes);
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic
% set(gca,'xticklabel',[])                            % das macht, dass keine x-tick-labels gezeigt werden, soll ja nur ganz unten
ax=p1.Parent;
ax.LineWidth   =2;
ax.FontName='times';

ax.XMinorTick = 'on' %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;

ylim(ylimes)
ylabel({'c_w';' [g / m^3]'});
                                  % arielle 13.11. none
% set(gca,'ytick',[3 3.2 3.4 3.6]); % tadj 16.9.  


ax.YMinorTick = 'on' %more tick marks

    






%% plot n-th lwc above cloud base
figure
plot(lwc_1);
hold on
plot(lwc_2);
plot(lwc_3);
plot(lwc_7);
plot(lwc_top);



%% plot cb and cT in meter
figure
plot(cb_cloudNet_inM);
hold on
plot(cT_cloudNet_inM);

%% plot cb_CloudNet and cb_dualFOV
figure
plot(time_num_cn(closestIndex_cb_cN),cb_cloudNet_inM(closestIndex_cb_cN));
hold on
plot(measurement_time_num,cloudbase_inM);
plot(time_num_cn(closestIndex_cb_cN),cT_cloudNet_inM(closestIndex_cb_cN)+15);


%% plot cb deviation
figure
plot(smooth(cb_deviation,5))
hold on
yline(nanmean(cb_deviation));



%% plot n-th lwc above cb  and  lwc_ref
figure
subplot(2,1,1)
plot(time_num_cn,lwc_3*1000);
hold on
% plot(time_num_cn,(lwc_3+lwc_error_3)*1000);
% plot(time_num_cn,(lwc_3-lwc_error_3)*1000);


plot(measurement_time_num(time_rof_clouds_low_res),lwc_in_g_per_cubicmeter(12,:),'o');

subplot(2,1,2)
plot(time_num_cn, cb_cloudNet_inM-15+ 30*3);
hold on
plot(measurement_time_num,cloudbase_inM-3.75+ 7.5*12);
% yline(nanmean(cb_cloudNet_inM-15+ 30*3),'color','b');
% yline(nanmean(cloudbase_inM-3.75+ 7.5*12));

%%





%% plot lwc

figure;
imagesc(lwc_d,[0 0.5*10^-3]);
set(gca,'FontSize',12,'YDir','normal');
title('LWC','FontWeight','Normal')
ylabel('Height, [bins]');
xlabel('Time, [bins]');
h = colorbar;                                                      %666*7.5m = 5km
set(get(h,'title'),'string','Signal','Fontsize',12);
% caxis([0 0.3]);





%%