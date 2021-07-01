

%% Function to scale down temporal resolution
%
%
%
%
%    Input:
%             signal(height,time)
%             resolution (in Minutes),
%
%     Output:
%             signal_low_res  (height,time)
%             time_low_res     
%
%
%
%
%
%   Example Call:
%           [sig_low_test,time_low_res_in_bins_test]  =  change_time_resolution_fct(  squeeze(raw_signal_Mcps(1,:,:)),  10 )
%

%%


function  [sig_low_res,time_low_res_in_bins]  =  change_time_resolution_fct(  sig_L, time, resolution_in_Min_L )


L_time = size(sig_L,2);
L_height =size(sig_L,1);

end_loop=floor(L_time/2/resolution_in_Min_L);                                                   % length(sig_L) ist die anzahl der in 30sec bins, Geteil durch 2 ist man bei anzahl der 1min bins.geteilt durch die neue Resolution (in min) ist man bei der anzahl der bins die man bei der resolution braucht. floor rounds a number to the next smaller integer

sig_low_res(1:L_height,1:L_time) = NaN;                                                         % uncomment if one wants a data set with all NaN but the new_resolution values

k = 1 ;


%%
for i=1:end_loop
    LB_L =  ( i - 1 ) * 2 * resolution_in_Min_L  +  1 ;                                         % Low Bound  of the intervall which will be averaged
    HB_L =   2 * resolution_in_Min_L * i  ;                                                     % Hight Bound of the intervall which will be averaged
    
    time_low_res_in_bins(k) = time(round(nanmean(LB_L:HB_L)));                                                   % The (mean)time to which the low Resolution value belongs.
    
    % in the following all only some of the NaN-Values in the variables 'depol_in_mean_above_CB_low_res_L',.. are replaced
    %       namely the ones for which a lower resolution value is available.
    sig_low_res(:,time_low_res_in_bins(k) )    =   nanmean(  sig_L(:,( LB_L : HB_L)),2  )  ;          % uncomment if one wants a data set with all NaN but the new_resolution values
    % sig_low_res(:,k)                            =   nanmean(  sig_L(:,( LB_L : HB_L)),2  )  ;       % uncomment if one wants a smaller data set with only new_resolution values  Line:"sig_low_res(1:L_height,1:L_time) = NaN;" should be commmeted then also.
        
    k = k+1;
end

   
   
   
end

















