%% Function to calculate the calibration constant of the outer FOV in Robs style
%
%  This is the Version updated in July 2020
%
%  orientiert an Cristofers neuster Version.



%
% C_out = [ ( d_in^V  R_t^out  +  1 )   /   ( 1 + d_in^V  R_c^out )    ] * d'_out
%
%
%   example call
%       C_out_dc_bc_rc = depol_const_outer_rob_below_cb_median_fct(signal_dc_bc_rc, cloudbase_dc_bc_rc,  time_rof_calibration_out, ...
%                                                                   depol_out_cal_rof_height,  depol_out_cal_range_below_cloud,...
%                                                                   C_dc_bc_rc, Rt,Rc,Rt_out,Rc_out);


% Find and prepare  Data for Calibration
function C_out_L = depol_const_out_fct_2_0(sig_L,  cloudbase_L,  time_rof_calibration_out_L,  depol_out_cal_rof_height_L,  C_in_L, Rt_L, Rc_L,   Rt_out_L, Rc_out_L )


if isnan(C_in_L)
    fprintf('.....depol_const_out_fct_2_0() says: "Error: You gave me a calibration constant of the inner FOV:   C=NaN  ....that wont work.\n ');
    return;
end


fprintf('\n     depol_const_out_fct_2_0 says:    Depol Constant of Outer FOV is calculated only below CB but also constrained by\n');
fprintf('                                                height_range=[%d..%d]   ,   time_range= [%d..%d]\n',depol_out_cal_rof_height_L(1),depol_out_cal_rof_height_L(end),time_rof_calibration_out_L(1),time_rof_calibration_out_L(end));
fprintf('                                              - Only values -2< C_vec <4 are used .\n');
% Reduce Signal to Values which should be included in Calculation
for t=1:size(sig_L,3)                                                           % loop over all times
    if (~isnan(cloudbase_L(t)))                                                 % only execute if Value is not NaN  (this line can not be left out, else one gets index=NaN in next line)
        sig_L(:,(cloudbase_L(t)-5):end,t) = NaN;                                %   NaN all Values which are above CB-5bins if present
    else
      %  sig_L(:,depol_out_cal_rof_height_L(end):end,t) = NaN;                   % All data which are higher than max (depol_out_cal_rof_height_L)
    end
end

% reduction to     depol_out_cal_rof_height_L      is done at the very end.
              

% sig_L = sig_L(:,10:depol_out_cal_rof_height_L(end)-5,time_rof_calibration_out_L);                                  % Crop Signal to heightrange of calibration     and    timerange of calibration 
sig_L = sig_L(:,:,time_rof_calibration_out_L); 


%% Take the mean over time

% sig_in_tot_L     = squeeze(sig_L(1,:,:)) ;                           % just for debugging
% sig_in_cross_L   = squeeze(sig_L(2,:,:)) ;  
% sig_out_tot_L    = squeeze(sig_L(3,:,:)) ;  
% sig_out_cross_L  = squeeze(sig_L(4,:,:)) ; 

mean_sig_in_tot_L     = nanmean(squeeze(sig_L(1,:,:)),2)' ;                           % Take the mean over time ->results in height vector
mean_sig_in_cross_L   = nanmean(squeeze(sig_L(2,:,:)),2)' ;  
mean_sig_out_tot_L    = nanmean(squeeze(sig_L(3,:,:)),2)' ;  
mean_sig_out_cross_L  = nanmean(squeeze(sig_L(4,:,:)),2)' ;  


% Weight
weight = nansum (   squeeze(sig_L(1,:,:))'    ./   squeeze(sig_L(1,:,:))' , 1 );         % Gives the number of non-NaN bins for each heigth (ie. number of available values per heigth)

%clear sig_L;


%% %%%%%%%%%%% Depol  %%%%%%%%%%%%%


%% Large telescope (Inner FOV)
% uncalibrated depol ratio, mean over all times
mean_ratio_in_L       = mean_sig_in_cross_L ./ mean_sig_in_tot_L  ;                                                % uncalibrated depol , called delta' in pdf ,

% calibrated depol ratio
mean_depol_in_L = ( 1  - mean_ratio_in_L / C_in_L ) ./  ( mean_ratio_in_L * Rt_L / C_in_L  -  Rc_L);                     % calibrated depol ratio, called delta^V in pdf


%% Nahfeld 
% uncalibrated depol ratio, mean over all times
mean_ratio_out_L      = mean_sig_out_cross_L  ./ mean_sig_out_tot_L;                                                  % uncalibrated depol ratio, calibration still missing

mean_ratio_out_L(mean_ratio_out_L<0)=NaN;

% Calibration constant
C_out_vec_L    =   ( mean_depol_in_L * Rt_out_L  +  1 ) ./ ( 1 + mean_depol_in_L * Rc_out_L  )  .*  mean_ratio_out_L  ;


C_out_vec_L(C_out_vec_L<-2)=NaN;
C_out_vec_L(C_out_vec_L>4) =NaN;

weightCC = weight.*C_out_vec_L./C_out_vec_L;                                             %To removes weights of removed data


% Weigthed mean
C_out_L = nansum ( C_out_vec_L(depol_out_cal_rof_height_L) .* weightCC(depol_out_cal_rof_height_L) ) /  nansum (weightCC(depol_out_cal_rof_height_L) );
 

 
% just to see the effect. Values do not leave this function 
% mean_depol_in_L   = nanmean(depol_in_L,'all');                                                  % the 'all' option works for Matlab2018 and higher. For lower Matlab versions use: nanmedian(reshape(depol_in_L,1,[]))
% mean_ratio_out_L  = nanmean(ratio_out_L,'all');                                                 % the 'all' option works for Matlab2018 and higher. For lower Matlab versions use: nanmedian(reshape(ratio_out_L,1,[]))
% C_out_L_mean    =   ( mean_depol_in_L * Rt_out_L  +  1 ) / ( 1 + mean_depol_in_L * Rc_out_L  )  *  mean_ratio_out_L  ;



end