%% Tricks for nice plots etc



%% Export a pdf in the size of the figure
%Minimal Working Example
h = figure;
plot(1:10);
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'filename','-dpdf','-r0')



%%
'LineWidth',2
'.','MarkerSize',10