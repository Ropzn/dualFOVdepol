%% Extract stuff from inversion routine
result_path='C:\Robert\Master\Software\ND-Filter\results\arielle\'

% use t=32 in inversion routine

%% Plot CB search 
time_rof_profile_in_bins=761:762;
plot_cb_search_threshold_fct(squeeze(signal(1,:,:)),0.06,time_rof_profile_in_bins);

fprintf('Mean depol for:\n');
fprintf('%d - ',datevec(   measurement_time_num(  time_rof_profile_in_bins(1) ) )    );
fprintf('\n');
fprintf('%d - ',datevec(   measurement_time_num(  time_rof_profile_in_bins(end) ) )    );
fprintf('\n');


%% depolratio vs R_ref  2d


txt1= ['04_30UTC--SinglePointEvaluation-depolratio_vs_Rref_2d'];                                            
aa1=figure('name',txt1,'units','normalized','outerposition',[0 0 1 1]);          %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen


plot(depolratio_fitrange,R_ref_CB_curve,'LineWidth',2,'color','black','DisplayName','Interpolated Fit');
hold on
plot(depolratio_fitrange,R_ref_simulated_base,'--','LineWidth',2) %red above
plot(depolratio_fitrange,R_ref_simulated_top,'--','LineWidth',2); %yellow below

line([depol_ratio_mean_above_CB_L(t) depol_ratio_mean_above_CB_L(t)], [0 R_ref_CB_one_value(t)],'Color','[0.5 0.5 0.5]','LineStyle','--','LineWidth',2);
line([0 depol_ratio_mean_above_CB_L(t)], [R_ref_CB_one_value(t) R_ref_CB_one_value(t)],'Color','[0.5 0.5 0.5]','LineStyle','--','LineWidth',2);




plot(depol_ratio_mean_above_CB_L(t),R_ref_CB_one_value(t),'o',...
                'LineWidth',2,...
                'MarkerSize',8,...
                'MarkerEdgeColor','black',...
                'MarkerFaceColor','magenta');

xlim([0.5 1])     
ylim([0 16])
            
set(gca,'linewidth',2)
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');

xlabel('\delta_{rat} ');
ylabel('r_{ref} [\mu m]');
            
            
%Save            
set(aa1,'Units','Inches');
pos = get(aa1,'Position');
set(aa1,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(aa1,strcat(result_path,txt1,'.pdf'),'-dpdf','-r0')
            
            
            
            
%---------------------------------------------------------------------------------------          
            
            
            
            
            
            
            
%% r_ref alpha_ref,depol_in  3D

% depol_in_matrix_base (235 x 122)
% alpha_ref_input 235
% r_ref_input 122

txt2= ['04_30UTC--SinglePointEvaluation-r_ref_alpha_ref_depol_in_3D'];                                            
aa2=figure('name',txt2,'units','normalized','outerposition',[0 0 1 1]);          %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen


imagesc(r_ref_input,alpha_ref_input.*1000,depol_in_matrix_CB)

h = colorbar;
colormap(jet);

set(get(h,'title'),'string','\delta_{in}','Fontsize',12);        % Beschriftung der Colorbar
% caxis([0 8]*10^8);
% h.Label.String = '$\bar{\delta}_{in}$';
% h.Label.Interpreter = 'latex';

set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
set(gca,'TickDir','out');           % sodass alle ticks nach aussen schauen
     
set(gca,'linewidth',2)
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');


ylabel('\alpha_{ref} [km^{-1}]');
xlabel('R_{ref} [\mu m]');

hold on
plot([r_ref_input(colum_index_R_ref_CB (t)) r_ref_input(colum_index_R_ref_CB (t))],[0 30],'LineWidth',3,'color','black'), % this marks the r_ref value


%Save            
set(aa2,'Units','Inches');
pos = get(aa2,'Position');
set(aa2,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(aa2,strcat(result_path,txt2,'.pdf'),'-dpdf','-r0')



%%


txt3= ['04_30UTC--SinglePointEvaluation-depol_in_vs_alpha_ref'];                                            
aa3=figure('name',txt3,'units','normalized','outerposition',[0 0 1 1]);          %,'outerposition',[0 0 1 1] is responsible for opening the figure full-screen




plot(depol_in_vector_CB,alpha_ref_input.*1000,'o','MarkerSize',5);
hold on

% Fittet curve is exactly the input curve
alpha_ref_CB_fittet_curve   = polyval( alpha_ref_vs_depolin_CB_coefficients ,depol_in_vector_CB);
plot(depol_in_vector_CB,alpha_ref_CB_fittet_curve.*1000,'black','LineWidth',2)


line([depol_in_mean_above_CB_L(t) depol_in_mean_above_CB_L(t)], [min(alpha_ref_CB_one_value(t)*1000) alpha_ref_CB_one_value(t)*1000],'Color','[0.5 0.5 0.5]','LineStyle','--','LineWidth',2);
line([min(depol_in_vector_CB) depol_in_mean_above_CB_L(t)], [alpha_ref_CB_one_value(t)*1000 alpha_ref_CB_one_value(t)*1000],'Color','[0.5 0.5 0.5]','LineStyle','--','LineWidth',2);


plot(depol_in_mean_above_CB_L(t),alpha_ref_CB_one_value(t)*1000,'o',...
                'LineWidth',2,...
                'MarkerSize',8,...
                'MarkerEdgeColor','black',...
                'MarkerFaceColor','magenta');
            
            
            
            
            
set(gca,'linewidth',2)
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');

xlabel('\delta_{in} ');
ylabel('\alpha_{ref} [km^{-1}]');
            
   
            


