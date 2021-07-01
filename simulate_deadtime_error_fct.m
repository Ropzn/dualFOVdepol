%
%
%

function signal_out = simulate_deadtime_error_fct (signal_in,error,channel)


signal_out = signal_in;



elements_greater_than_80 = squeeze(signal_in(channel,:,:))>=80 & squeeze(signal_in(channel,:,:))<90;
signal_out(channel,elements_greater_than_80) = signal_in(channel,elements_greater_than_80).* (1+0.05);

elements_greater_than_90 = squeeze(signal_in(channel,:,:))>=90 & squeeze(signal_in(channel,:,:))<100;
signal_out(channel,elements_greater_than_90) = signal_in(channel,elements_greater_than_90).* (1+0.1);

elements_greater_than_100 = squeeze(signal_in(channel,:,:))>=100 & squeeze(signal_in(channel,:,:))<110;
signal_out(channel,elements_greater_than_100) = signal_in(channel,elements_greater_than_100).* (1+0.20);

elements_greater_than_110 = squeeze(signal_in(channel,:,:))>=110 & squeeze(signal_in(channel,:,:))<120;
signal_out(channel,elements_greater_than_110) = signal_in(channel,elements_greater_than_110).* (1+0.30);

elements_greater_than_120 = squeeze(signal_in(channel,:,:))>=120 & squeeze(signal_in(channel,:,:))<150;
signal_out(channel,elements_greater_than_120) = signal_in(channel,elements_greater_than_120).* (1+0.4);

fprintf('  ---Attention Channel %d  simulated offset of %f\n',channel,error);
fprintf('     Total Elements       : %d\n',numel(signal_in(channel,:,:)));
fprintf('     Elements 80-90Mcps   : %d\n',sum(elements_greater_than_80,'all'));
fprintf('     Elements 90-100Mcps  : %d\n',sum(elements_greater_than_90,'all'));
fprintf('     Elements 100-110Mcps : %d\n',sum(elements_greater_than_100,'all'));
fprintf('     Elements 110-120Mcps : %d\n',sum(elements_greater_than_110,'all'));
fprintf('     Elements 120-150Mcps : %d\n---\n',sum(elements_greater_than_120,'all'));



end