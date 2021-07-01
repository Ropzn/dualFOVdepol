% colorplot
%
% 2x2 ColorPlots in one figure
%
%
% call example:
% plot_color_4ch_fct(raw_signal_Mcps,'raw_signal_Mcps',save_all_plots,InputFiles_lidar{ff},result_path);
%
% raw_signal0_1

function plot_color_4ch_fct(signal_l,sig_name,save_all_plots_l,InputFile_lidar_l,result_path_l)


aa=figure('name',sig_name,'units','normalized','outerposition',[0 0 1 1]);          %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen

%xlimes=[0 400];                                                    %666*7.5m = 5km
ylimes=[0 666];
% To define color axis use: caxis([0 4]*10^8);


subplot(2,2,1)
imagesc(squeeze(signal_l(1,:,:)));
set(gca,'FontSize',12,'YDir','normal');
title('Total_{in}','FontWeight','Normal')
ylabel('Height, [bins]');
%xlabel('Time, [bins]');
h = colorbar;
ylim(ylimes);                                                       %666*7.5m = 5km
set(get(h,'title'),'string','Signal','Fontsize',12);
hold on;

%%%%
subplot(2,2,2);
imagesc(squeeze(signal_l(2,:,:)));
set(gca,'FontSize',12,'YDir','normal');
title('Perp_{in}','FontWeight','Normal')
%ylabel('Height, [bins]');
%xlabel('Time, [bins]');
h = colorbar;
ylim(ylimes);                                                       %666*7.5m = 5km
set(get(h,'title'),'string','Signal','Fontsize',12);

%%%%
subplot(2,2,3);
imagesc(squeeze(signal_l(3,:,:)));
set(gca,'FontSize',12,'YDir','normal');
title('Total_{out}','FontWeight','Normal')
ylabel('Height, [bins]');
xlabel('Time, [bins]');
h = colorbar;
ylim(ylimes);                                                       %666*7.5m = 5km
set(get(h,'title'),'string','Signal','Fontsize',12);

%%%%
subplot(2,2,4);
imagesc(squeeze(signal_l(4,:,:)));
set(gca,'FontSize',12,'YDir','normal');
title('Perp_{out}','FontWeight','Normal')
%ylabel('Height, [bins]');
xlabel('Time, [bins]');
h = colorbar;
ylim(ylimes);                                                       %666*7.5m = 5km
set(get(h,'title'),'string','Signal','Fontsize',12);

if (save_all_plots_l==1)
    saveas(aa,strcat(result_path_l,sig_name,'_',InputFile_lidar_l(1:end-3),'.jpg'));
end

end