%
% Calculates the calibrated depol for the inner FOV
%       Input: Signal_tot  , Signal_cross    ,   Calibration Constant
%       Output: depol Array(depol,height,time)
%
%

% R_t supposed to be == 1

function depol_out_L = depol_out_with_B_fct (sig_tot_L,sig_cross_L,B_L,Rc_out_L)

epsilon_L=(1+1/Rc_out_L)/(1-1/Rc_out_L);


ratio_L = ( squeeze(sig_cross_L) ./ squeeze(sig_tot_L) ) ;                         % uncalibrated depol ratio, called delta' in pdf
ratio_L(ratio_L<0)=NaN;
depol_out_L=(1-epsilon_L*(1-2*B_L*ratio_L))./(1+epsilon_L*(1-2*B_L*ratio_L));       % calibrated depol ratio, called delta^V in pdf

end