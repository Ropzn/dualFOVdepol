

%% Function to scale down temporal resolution
%
%   This is not done simply in a vertical way. 
%   However the bins which are meaned vary with cloudbase height.
%
%   There are safetythresholds such that 
%           - there are no long time-gaps between the first and the last element wich are meaned
%           - the variations within the Cloudbase are not too large
%           - if due to thresholds, no lower resolution point was set, a
%   
%
%
%    Input:    
%             
%             new_resolution (in Minutes),  
%             cloudbase (in Meters),  
%             time_rof_clouds (in bins),  
%             CB_var_limit (in Meters)
%             
%     Output:
%             depol_in_mean_above_CB_low_res,  
%             depol_out_mean_above_CB_low_res,  
%             time_rof_clouds_low_res (in bins),  
%             cloudbase_low_res (in meters)
%
%   To print wether an interval had only moderate variations in time and
%   hight, uncomment all three 'printf(...' lines
%
%
%   Example Call:
%
%   [ signal_low_res_above_CB,  time_rof_clouds_low_res_L,  cloudbase_inM_low_res_L ]  = ...
%             new_resolution_for_signal_above_CB_fct(  signal_dc_bc_rc, ...
%                                                         cloudbase_dc_bc_rc, time_rof_clouds,...
%                                                         resolution_temporal_depol_mean_above_CB,  CB_var_limit_inM, depth_into_cloud_depol_mean )

%%


function  [ signal_low_res_above_CB_L,  time_rof_clouds_low_res_L,  cloudbase_inM_low_res_L ]  = ...
            new_resolution_for_signal_above_CB_fct(     signal_high_res_L, ...
                                                        cloudbase_L, cloudbase_inM_L, time_rof_clouds_L,...
                                                        resolution_L, CB_var_limit_inM_L, CB_time_var_limit_L, depth_into_cloud_depol_mean_L,...
                                                        logfile_L)

% We will operate only the values where, there exist a CB, and only some height bins above CB
                                                    
new_number_of_cloudbase_bins=floor(length(time_rof_clouds_L)/2/resolution_L);                                                   % length(time_rof_clouds_L) ist die anzahl der in 30sec bins, Geteil durch 2 ist man bei anzahl der 1min bins.geteilt durch die neue Resolution (in min) ist man bei der anzahl der bins die man bei der resolution braucht. floor rounds a number to the next smaller integer


t_new = 1 ;

%% Create new signal matrix of dim (height x time) 
%       Let y=depth_into_cloud_depol_mean_L
%       at each time, the first y height bins above Cloudbase are stored in signal_above_CB
for t_L = 1:length(time_rof_clouds_L)
        zmin = cloudbase_L(time_rof_clouds_L(t_L)) ;              
        zi = zmin : zmin + depth_into_cloud_depol_mean_L;                     % range from CB to penetration depth  (optional shift of cloudbase)
        signal_above_CB(:,:,t_L) = signal_high_res_L(:,zi , time_rof_clouds_L(t_L));                 % has dimensions: (4 channels , penetration_depth, number of found CB)
        if isnan(signal_above_CB(:,:,t_L))
            fprintf('new_resolution_for_signal_above_CB_fct says:  whoops, there is a NaN value at t_L= %f... please check!\n',t_L); % maybe you gave me datapoints from +-45 calibration ?
        end
end



%%
for i=1:new_number_of_cloudbase_bins
    LB_index = ( i - 1 ) * 2 * resolution_L  +  1;                          % Low Bound  of the intervall which will be averaged    % These 2 indeces are used for all variables which only contain CB-range
    HB_index = 2 * resolution_L * i;                                        % Hight Bound of the intervall which will be averaged
    LB_L = time_rof_clouds_L( LB_index );                                   % Low Bound  of the intervall which will be averaged    % These 2 indeces are in "real"-time for all variables which contain fulltime data
    HB_L = time_rof_clouds_L( HB_index  );                                  % Hight Bound of the intervall which will be averaged
    
    distance_in_time_between_first_and_last_element_in_resolution_interval_L_temp  = time_rof_clouds_L ( 2 * resolution_L * i )   -   time_rof_clouds_L ( ( i - 1 ) * 2 * resolution_L  +  1 );
    variation_in_height_between_two_adjacent_CB_points_L_temp                      = max ( diff ( cloudbase_inM_L(LB_L:HB_L) ) );             %could be nested inside the if-condition below, but here its nicer for reading
    
    
    
    % Do only consider data with continuous time.                                                           (if data within one resolution intervall origins from cloudperiods which are too far away from each other)
    if ( distance_in_time_between_first_and_last_element_in_resolution_interval_L_temp  <   CB_time_var_limit_L  )
        % Do only consider data where cloudbase height varies only little                                   (if cloudbase within a resoulution interval varies more than the set limit, no data is caluculated
        if (variation_in_height_between_two_adjacent_CB_points_L_temp   <=   CB_var_limit_inM_L  )
            time_rof_clouds_low_res_L(t_new) = round(nanmean(LB_L:HB_L));                       % The (mean)time to which the low Resolution value belongs.  ok, theoretical it could be weighted mean, but it really does not effect the result drastically
                        
            signal_low_res_above_CB_L(:,:,t_new)    =   nanmean(  signal_above_CB (:,:, LB_index : HB_index), 3  );    % Take the mean over the time dimension
            
            cloudbase_inM_low_res_L( t_new ) =  nanmean( cloudbase_inM_L  (LB_L:HB_L)  );               % Calculates the mean cloudbase height within one resolution intervall in Meters.
            
            t_new = t_new+1;
        end
    end


    
end

% No lower resolution points coud be calculated
if t_new==1
    fprintf('\n    new_resolution_for_signal_above_CB.m  says :    No lower resolution points coud be calculated.\n');
    fprintf(logfile_L,' new_resolution_for_signal_above_CB.m  says :    No lower resolution points coud be calculated.\n');
    signal_low_res_above_CB_L = NaN;
    time_rof_clouds_low_res_L = NaN;
    cloudbase_inM_low_res_L   = NaN;
end

end

















