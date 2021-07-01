%
% Calculates the calibrated depol for the inner FOV
%       Input: Signal_tot  , Signal_cross    ,   Calibration Constant
%       Output: depol Array(depol,height,time)
%
%

function depol_L = depol_fct (sig_tot_L,sig_cross_L,C_L,Rt_L,Rc_L)

ratio_L = ( squeeze(sig_cross_L) ./ squeeze(sig_tot_L) ) ;                         % uncalibrated depol ratio, called delta' in pdf
ratio_L(ratio_L<0)=NaN;
depol_L = ( 1  - ratio_L / C_L ) ./  ( ratio_L * Rt_L / C_L  -  Rc_L);       % calibrated depol ratio, called delta^V in pdf

end