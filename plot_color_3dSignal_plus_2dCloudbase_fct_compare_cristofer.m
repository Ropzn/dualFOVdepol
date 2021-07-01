% colorplot
%
% 1 ColorPlot + an overlying line plot 
% eg: profile color plot (of one channel only) and cloudbase line plot
%
% call example:
%   plot_color_3dSignal_plus_2dCloudbase_fct(signal_dc_bc_rc(1,:,:),cloudbase_dc_bc_rc,'signal_dc_bc_rc ',save_all_plots,InputFiles_lidar{ff},result_path);
% raw_signal0_1

function plot_color_3dSignal_plus_2dCloudbase_fct_compare_cristofer(d3_signal_L,d2_signal_L,...
                                                    num_time_L,height_L,...
                                                    cb_lowres_in_m_L,bin_time_lowres_L,...
                                                    cb_cristofer,cb_cristofer_numtime,...
                                                    sig_name,save_all_plots_L,InputFile,result_path_L)

txt= [InputFile,'--Cloudbase and Profile'];

                                                
aa=figure('name',strcat(txt,sig_name),'units','normalized','outerposition',[0 0 1 1]);          %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen


% xlimes=[xstart xend];   % in numdate                                                 %666*7.5m = 5km
% ylimes=[2 5];      % in km   fuer detail
% ylimes=[0 10];    % fuer ueberblick

% To define color axis use: caxis([0 4]*10^8);


date_tick_range = num_time_L(1:20:end);   % 20-> 10min,    60->1/h std

date_minor_tick_range = num_time_L(37:2:end);


d3_signal_L = squeeze(d3_signal_L);

% shorten height to signal, and convert to km
height_L = height_L(1:size(d3_signal_L,1)) /1000 ;

% Cloudbase in km
CB_in_km_L = d2_signal_L * height_L(1);
CB_low_res_in_km = cb_lowres_in_m_L /1000;

% Num_time_low_res
num_time_lowres_L = num_time_L(bin_time_lowres_L);

%3D Plot
imagesc(num_time_L,height_L,d3_signal_L);
set(gca,'colorscale','log');
h = colorbar;
colormap(jet);
set(get(h,'title'),'string','Rangecorrected Signal','Fontsize',12);        % Beschriftung der Colorbar
% caxis([0 8]*10^8);

set(gca,'fontweight','bold','fontsize',12,'YDir','normal');

hold on;


% 2D Plot low res
plot(num_time_lowres_L,CB_low_res_in_km,'o',...
                'LineWidth',2,...
                'MarkerSize',8,...
                'MarkerEdgeColor','black',...
                'MarkerFaceColor','magenta');

% 2D Plot
p1=plot(num_time_L,CB_in_km_L,'LineWidth',2,'color','blue');

% Zur Darstellung in Bins folgendes nutzen und oben auskommentieren. ausserdem 'datetick' auskommentieren
% imagesc(d3_signal_L)
% hold on;
% plot(CB_in_km_L,'LineWidth',2,'color','r');




set(gca,'fontweight','bold','fontsize',12,'YDir','normal');

    %   title([InputFile,sig_name],'FontWeight','Normal','Interpreter', 'none');
                                                     %666*7.5m = 5km

set(gca,'TickDir','out');           % sodass alle ticks nach aussen schauen
                                                     
set(gca,'xtick',date_tick_range);
datetick('x',15,'keepticks','keeplimits');           % 15 ist der darstellungsmodus siehe help datetic
ax=p1.Parent;
ax.XMinorTick = 'on'; %more tick marks
ax.XAxis.MinorTickValues = date_minor_tick_range;
% xlim(xlimes);


% ylim(ylimes);  
ax.YMinorTick = 'on'; %more tick marks


ylabel('Height [km]');
xlabel('Time [UTC]');


plot(cb_cristofer_numtime,cb_cristofer/1000,'x',...
                'LineWidth',2,...
                'MarkerSize',8,...
                'MarkerEdgeColor','black',...
                'MarkerFaceColor','blue');








if (save_all_plots_L==1)
%     saveas(aa,strcat(result_path_L,'Cloudbase_',InputFile_lidar_L(1:end-3),'.jpg'))
    % Als PDF
    set(aa,'Units','Inches');
    pos = get(aa,'Position');
    set(aa,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(aa,strcat(result_path_L,txt,'.pdf'),'-dpdf','-r0')
    
end

end