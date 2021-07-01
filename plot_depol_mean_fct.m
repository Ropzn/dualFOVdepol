% Plot depol mean and ratio 2D
%
% 2x2 2D-Plots in one figure
%
%
% call examples:
% 
%  
%  


function plot_depol_mean_in_out_fct(s_in1,s_out1,sig_names,time_rof_profile_in_bins_l,save_all_plots_l,InputFile_lidar_l,result_path_l)

txt= ['Depol in and out: Mean(Time [' ,num2str(min(time_rof_profile_in_bins_l)), '..' ,num2str(max(time_rof_profile_in_bins_l)), '] of ',sig_names ];
aa=figure('name',txt,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

% Plot range in time domain                 
%       xlimes should be set, else xlim might be different for each plot
xlimes=[0 max(size(s_in1,2),size(s_in1,1))];  
% xlimes=[0 720];

% Plotrange for depol_in/depol_out
% ylimesdepol=[0 0.04];
% ylimesratio=[0.5 2];
% ylimesratio=[0.5 2];
% ymin=min([s_in1;s_out1;s_in2;s_out2]);       % problems? try with komma instead of semicolon
% ymax=max([s_in1;s_out1;s_in2;s_out2]);
%
% ymin=min([s_in1,s_out1,s_in2,s_out2]);
% ymax=max([s_in1,s_out1,s_in2,s_out2]);
%
ymin=min([min(s_in1),min(s_out1),min(s_in2),min(s_out2)]);
ymax=max([max(s_in1),max(s_out1),max(s_in2),max(s_out2)]);
ylimesdepol=[ymin ymax];
ymin_ratio=min([min(ratio1),min(ratio2)]);
ymax_ratio=max([max(ratio1),max(ratio2)]);
ylimesratio=[ymin_ratio ymax_ratio];







%% Prepare for the cases that 1 or 2 signals are available
if s_in2==0
    colum=1;
else
    colum=2;
end

%% Plot First signal
%%% Depol_in and Depol_out of the first signal
subplot(2,colum,1)
plot(s_in1,'DisplayName','Depol_{in}');
hold on;
plot(s_out1,'DisplayName','Depol_{out}');
set(gca,'FontSize',12,'YDir','normal');
title('Depol_{in} and Depol_{out}');
ylabel('Depol (of time mean)');
ylim(ylimesdepol);  % if here comes an error-->                                     than probably depol_out could not be calculated, because C_out could not be calculated, because some CB was found below the range of "depol_out_cal_rof_height". adjust eg the latter     and it works again.                                                                                       
xlim(xlimes);
legend;

%%% Ratio of the first signal
subplot(2,colum,2)
plot(ratio1)
set(gca,'FontSize',12,'YDir','normal');
title('Depol_{in} / Depol_{out}');
ylabel('Ratio');

% if simple depol_const_out_fct is used 80:180;  60:180??             % ylim is the range which will be averaged 60:300= 450m-2250m   ( also confines range if depol_const_out_fct is used )   
ylim(ylimesratio);   % if here comes an error-->                                     than probably depol_out could not be calculated, because C_out could not be calculated, because some CB was found below the range of "depol_out_cal_rof_height". adjust eg the latter     and it works again.                                                                                       
% depol_out_cal_range_below_cloud = 2:132;                                        % This gives the bins which are used by depol_const_out_fct.  CB-2:CB-133 
xlim(xlimes);

%% Plot second signal if available
if s_in2~=1                                                                 % s_in2 is NOT equal
    %%% Depol_in and Depol_out of the SECOND signal
    subplot(2,colum,3)
    plot(s_in2,'DisplayName','Depol_{in}');
    hold on;
    plot(s_out2,'DisplayName','Depol_{out}');
    set(gca,'FontSize',12,'YDir','normal');
    title('Depol_{in} and Depol_{out} of SECOND signal');
    ylabel('Depol (of time mean)');
    ylim(ylimesdepol);
    xlim(xlimes);
    legend;
    
    %%% Ratio of the SECOND signal
    subplot(2,colum,4)
    plot(ratio2)
    set(gca,'FontSize',12,'YDir','normal');
    title('Depol_{in} / Depol_{out} of SECOND signal');
    ylabel('Ratio');
    ylim(ylimesratio);
    xlim(xlimes);
    
    %%% Additional Figure with the two ratios in one
    aa2=figure('name','(depol_in/depol_out) of the two signals' ,'units','normalized','outerposition',[0 0 1 1]);           %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen
    plot(ratio1,'DisplayName','ratio_{1st}')
    hold on
    plot(ratio2,'DisplayName','ratio_{2nd}')
    set(gca,'FontSize',12,'YDir','normal');
    title('Depol_{in} / Depol_{out} of FIRST and SECOND signal');
    ylabel('Ratio');
    ylim(ylimesratio);
    xlim(xlimes);
    legend;
    
    
end

if (save_all_plots_l==1)
    saveas(aa,strcat(result_path_l,'Depol_Means_and_ratios','_',sig_names,'_',InputFile_lidar_l(1:end-3),'.jpg'));
    if s_in2~=1
        saveas(aa2,strcat(result_path_l,'Depol_Mean_ratios_comparison','_',sig_names,'_',InputFile_lidar_l(1:end-3),'.jpg'));
    end

end

end