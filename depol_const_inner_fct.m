%%%
% Function to calculate Calibration Constant by the +/- 45° method 
%
%
% Input:
%
%
% example call:
%   C      = depol_const_inner_fct(signal_during_calibration(1,:,:),signal_during_calibration(2,:,:),depol_cal_rof_height,Rt_in,Rc_in);
%
%
%
%
%  Description:
%       hier wird median genutzt
%       und statt time_rof_cal statisch zu benutzen werden alle höhen mit reingenommen in denen
%       CC_mean_of_time nicht mehr als um 2 vom  median(CC_mean_of_time(time_rof_cal) abweicht.
%




function C_L = depol_const_inner_fct(sig_tot,sig_cross,depol_cal_rof_height_L,Rt_L,Rc_L)



% delete first dimension of arrays and reduce height and time to range of interest
cal_sig_tot    = squeeze(sig_tot(1,:,:));
cal_sig_cross  = squeeze(sig_cross(1,:,:));

if (nanmean(isnan(cal_sig_tot(:,1:end))))
    fprintf('.....C_L() says: "I think you gave me data where all the calibration values of the inner FOV are allready set to NaN....\n ');
end

%depol calibration
delta_plus_minus_matrx= cal_sig_cross(:,2:end-1) ./ cal_sig_tot(:,2:end-1);        % Calibration constant (in pdf named delta'_(+-45))

%replace all inf and -inf by NaN
% delta_plus_minus_matrx(isinf(delta_plus_minus_matrx))=NaN;                          % replace all inf and -inf by NaN

delta_plus_minus_matrx_median_over_time = nanmedian(delta_plus_minus_matrx,2);
DD=delta_plus_minus_matrx_median_over_time;                                             %only for better reading in next formula



DD( DD < nanmedian( DD(depol_cal_rof_height_L))-2 ) =NaN;               % ausreisser rauswerfen
DD( DD > nanmedian( DD(depol_cal_rof_height_L))+2 ) =NaN;

delta_timemedian_heightmedian=nanmedian(DD(depol_cal_rof_height_L));                 % Take the mean over  height 


C_L = delta_timemedian_heightmedian * (1+Rt_L) / (1+Rc_L);

end













