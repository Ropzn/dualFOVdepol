% Plot depol mean 2D
%
% 2 Graphs in one plot
%
%
% call examples:
% 
%  
%  


function plot_cb_search_threshold_fct(s,threshold,time_rof_profile_in_bins_L)
txt = ['cb search threshold'];
% txt= ['Depol in and out: Mean(Time [' ,num2str(min(time_rof_profile_in_bins_L)), '..' ,num2str(max(time_rof_profile_in_bins_L)), '] of ',sig_names,'--',InputFile ];


aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

% shorten height to signal, and convert to km

ylimes=[3.5999999 4.2]; %km
xlimes=[-0.1 1.1];

height=7.5:7.5:7.5*3350;
height=height' / 1000;

sig_time_mean= nanmean(s(:,time_rof_profile_in_bins_L),2);
sig_norm = sig_time_mean / max(sig_time_mean);

CB=find((sig_norm>threshold),1);


%% plot
plot(sig_norm,height,'LineWidth',2,'HandleVisibility','off');
hold on;
ax = gca;

yline(CB*7.5/1000,'--','LineWidth',2,'color','black','HandleVisibility','off');



title(txt,'Interpreter', 'none');


ylabel('Height [km]');
xlabel('Range-Corrected Signal');
ylim(ylimes);                       % if here comes an error-->                                     than probably depol_out could not be calculated, because C_out could not be calculated, because some CB was found below the range of "depol_out_cal_rof_height". adjust eg the latter     and it works again.                                                                                       
xlim(xlimes);
legend;

ax = gca;

ax.XDir    ='normal';          % normal / reverse
ax.XScale = 'linear';          %   linear / log          
ax.YDir    ='normal';          % normal / reverse
ax.YScale = 'linear';         %  	   linear / log


ax.LineWidth   =2;
ax.FontSize    =20;

ax.XGrid       ='on';
ax.YGrid       ='on';

ax.YAxis.TickValues = 0:0.2:5;

ax.XAxis.MinorTick         = 'off';
% ax.XAxis.MinorTickValues   = 0:0.005:1;
ax.XMinorGrid              = 'off';


     
     
     



end