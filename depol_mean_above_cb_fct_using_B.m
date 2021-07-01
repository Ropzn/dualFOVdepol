%%%
% Function to calculate the mean depol above CB  

% example call:
% 
%
%   
% 




function [depol_in_from_mean_above_CB, depol_out_from_mean_above_CB] = ...
                                                   depol_mean_above_cb_fct_2_0(  signal_above_CB_L,...
                                                                                    C_L, Rt_in_L, Rc_in_L,...
                                                                                    B_out_L, Rc_out_L );         

                                                                                
                                                                                
if signal_above_CB_L == NaN
    disp('depol_mean_above_cb_fct says:    signal_above_CB_L is NaN...');
    disp('                               ..therefore depol_mean_above_cb_fct is not executed');
    return;
end

%% take mean over the hight bins (second dimension), then change coloums and rows for consitency
sig_in_tot_mean_above_CB_L      = squeeze(  nanmean(signal_above_CB_L(1,1:end,:),2)  )'  ;   
sig_in_cross_mean_above_CB_L    = squeeze(  nanmean(signal_above_CB_L(2,1:end,:),2)  )'  ; 
sig_out_tot_mean_above_CB_L     = squeeze(  nanmean(signal_above_CB_L(3,1:end,:),2)  )'  ; 
sig_out_cross_mean_above_CB_L   = squeeze(  nanmean(signal_above_CB_L(4,1:end,:),2)  )'  ; 


%% Calculate depol_in and depol_out

depol_in_from_mean_above_CB  = depol_fct(sig_in_tot_mean_above_CB_L,  sig_in_cross_mean_above_CB_L,   C_L, Rt_in_L, Rc_in_L);
depol_out_from_mean_above_CB = depol_out_with_B_fct(sig_out_tot_mean_above_CB_L, sig_out_cross_mean_above_CB_L,   B_out_L,Rc_out_L);


end