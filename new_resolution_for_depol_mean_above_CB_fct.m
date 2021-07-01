

%% Function to scale down temporal resolution
%
%   While the resolution is of depol_mean_above_CB (inner and outer FOV) is
%   scaled down, we get smoother data for the inversion routine later on.
%
%
%    Input:    
%             depol_in_mean_above_CB,  
%             depol_out_mean_above_CB,
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
%   [depol_in_mean_above_CB_low_res, depol_out_mean_above_CB_low_res, time_rof_clouds_low_res, cloudbase_low_res ]= new_resolution_for_depol_mean_above_CB_fct(depol_in_mean_above_CB_dc_bc_rc,depol_out_mean_above_CB_dc_bc_rc,resolution_temporal_depol_mean_above_CB,cloudbase_L,time_rof_clouds_L,CB_var_limit)

%%


function  [ depol_in_mean_above_CB_low_res_L,  depol_out_mean_above_CB_low_res_L,  time_rof_clouds_low_res_L,  cloudbase_inM_low_res_L ]  = ...
            new_resolution_for_depol_mean_above_CB_fct(  depol_in_mean_above_CB_L,  depol_out_mean_above_CB_L, ...
            resolution_L,  cloudbase_inM_L,  time_rof_clouds_L,  CB_var_limit_inM_L )

end_loop=floor(length(time_rof_clouds_L)/2/resolution_L);                                                   % length(time_rof_clouds_L) ist die anzahl der in 30sec bins, Geteil durch 2 ist man bei anzahl der 1min bins.geteilt durch die neue Resolution (in min) ist man bei der anzahl der bins die man bei der resolution braucht. floor rounds a number to the next smaller integer

length_data = length(depol_in_mean_above_CB_L);

depol_in_mean_above_CB_low_res_L (1:length_data) = NaN;
depol_out_mean_above_CB_low_res_L(1:length_data) = NaN;
cloudbase_inM_low_res_L          (1:length_data) = NaN;
k = 1 ;


%%
for i=1:end_loop
    LB_L = time_rof_clouds_L( ( i - 1 ) * 2 * resolution_L  +  1 );                                         % Low Bound  of the intervall which will be averaged
    HB_L = time_rof_clouds_L(  2 * resolution_L * i  );                                                     % Hight Bound of the intervall which will be averaged
    
    distance_in_time_between_first_and_last_element_in_resolution_interval_L_temp  = time_rof_clouds_L ( 2 * resolution_L * i )   -   time_rof_clouds_L ( ( i - 1 ) * 2 * resolution_L  +  1 );
    variation_in_height_between_two_adjacent_CB_points_L_temp                      = max ( diff ( cloudbase_inM_L(LB_L:HB_L) ) );             %could be nested inside the if-condition below, but here its nicer for reading
    
    
    
    % Do only consider data with continuous time.                                                           (if data within one resolution intervall origins from cloudperiods which are too far away from each other)
    if ( distance_in_time_between_first_and_last_element_in_resolution_interval_L_temp  <   (2 * resolution_L + 2)  )
%         fprintf('distance_in_time_between_first_and_last_element_in_resolution_interval is ok..');
        % Do only consider data where cloudbase height varies only little                                   (if cloudbase within a resoulution interval varies more than the set limit, no data is caluculated
        if (variation_in_height_between_two_adjacent_CB_points_L_temp   <=   CB_var_limit_inM_L  )
%             fprintf('..variation_in_height_between_two_adjacent_CB_points is ok.');                                     % 
            time_rof_clouds_low_res_L(k) = round(nanmean(LB_L:HB_L));                                                   % The (mean)time to which the low Resolution value belongs.
                        
            % in the following all only some of the NaN-Values in the variables 'depol_in_mean_above_CB_low_res_L',.. are replaced
            %       namely the ones for which a lower resolution value is available.
            depol_in_mean_above_CB_low_res_L( time_rof_clouds_low_res_L(k) )    =   nanmean(  depol_in_mean_above_CB_L ( LB_L : HB_L)  )  ;
            depol_out_mean_above_CB_low_res_L( time_rof_clouds_low_res_L(k) )   =   nanmean(  depol_out_mean_above_CB_L( LB_L : HB_L)  )  ;
            
            cloudbase_inM_low_res_L( time_rof_clouds_low_res_L(k) )= nanmean(cloudbase_inM_L(LB_L:HB_L));               % Calculates the mean cloudbase height within one resolution intervall in Meters.
            
            k = k+1;
        end
    end
%     fprintf('\n');
    
end



end














