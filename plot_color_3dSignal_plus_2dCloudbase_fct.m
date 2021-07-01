% colorplot
%
% 1 ColorPlot + an overlying line plot 
% eg: profile color plot (of one channel only) and cloudbase line plot
%
% call example:
%   plot_color_3dSignal_plus_2dCloudbase_fct(signal_dc_bc_rc(1,:,:),cloudbase_dc_bc_rc,'signal_dc_bc_rc ',save_all_plots,InputFiles_lidar{ff},result_path);
% raw_signal0_1

function plot_color_3dSignal_plus_2dCloudbase_fct(d3_signal_L,d2_signal_L,...
                                                    data_time_L,height_L,...
                                                    sig_name,save_all_plots_L,InputFile,result_path_L)

txt= [InputFile,'--Cloudbase and Profile'];

                                                
aa=figure('name',strcat(txt,sig_name),'units','normalized','outerposition',[0 0 1 1]);          %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen


%xlimes=[0 400];   % in numdate                                                 %666*7.5m = 5km
ylimes=[0 6];      % in km
% To define color axis use: caxis([0 4]*10^8);  (just apply it like that in the code or in command window)



d3_signal_L = squeeze(d3_signal_L);

% shorten height to signal, and convert to km
height_L = height_L(1:size(d3_signal_L,1)) /1000 ;

% Cloudbase in km
CB_in_km_L = d2_signal_L * height_L(1);

%Plot
imagesc(data_time_L,height_L,d3_signal_L)
hold on;
plot(data_time_L,CB_in_km_L,'LineWidth',2,'color','r');
hold off;
set(gca,'FontSize',12,'YDir','normal');
title([InputFile,sig_name],'FontWeight','Normal','Interpreter', 'none');
h = colorbar;
                                                     %666*7.5m = 5km
set(get(h,'title'),'string','Signal','Fontsize',12);
datetick('x',15);

ylim(ylimes);  

ylabel('Height, [km]');
xlabel('Time');



if (save_all_plots_L==1)
%     saveas(aa,strcat(result_path_L,txt(1:end-3),'.jpg'));
    % Als PDF
    set(aa,'Units','Inches');
    pos = get(aa,'Position');
    set(aa,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(aa,strcat(result_path_L,txt,'.pdf'),'-dpdf','-r0')

end





end