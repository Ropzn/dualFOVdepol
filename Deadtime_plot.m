



%% Prepare Data Points
clear x x_err dc_poly dc_poly_error
x=[1:5:130];
y=[1:5:90];

for j=1:length(rangocanales)                                                                       % for all channels
    dc_poly(j,:)=polyval(deadtime_polynomial(j,:),x);                      
    dc_poly_error(j,:)=polyval(deadtime_polynomial_error(j,:),x);
end
% %%
% for j=21:size(dc_poly,2)
% dc_poly(1,j)=dc_poly(1,j)+(j-21)^6;
% end

%%

figure
errorbar(x,dc_poly(1,:),dc_poly_error(1,:),'-o','LineWidth',2);
hold on
plot(y,y,'--','color','black');
ylim([0, 250]);
% errorbar(x,dc_poly(2,:),dc_poly_error(2,:),'-s','LineWidth',2);
% errorbar(x,dc_poly(3,:),dc_poly_error(3,:),'-.','LineWidth',2);

% errorbar(x,dc_poly(4,:),dc_poly_error(4,:),'--');
% errorbar(x,dc_poly(5,:),dc_poly_error(5,:),'-o','LineWidth',2);

% %%
% jojo_fit          = fit( x',squeeze(dc_poly(1,:)'),'poly4');
% jojo_coefficients = coeffvalues(jojo_fit);                                      % extract the coefficients
% for i=1:length(x)
% y(i) = polyval( jojo_coefficients , x(i)  ); 
% end
%% 
            
set(gca,'linewidth',2)
set(gca,'fontweight','bold','fontsize',12,'YDir','normal');
set(gca,'ytick',[0:20:160]);

xlabel('Measured Counts [Mcps]');
ylabel('Corrected Counts [Mcps]');





















%