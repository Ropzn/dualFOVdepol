%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function analyses the inversion routine success rate.
%
%   Input: 
%                              
%
%   Output:     
%             cloudbase_inM_redutime_L          ->  Contains the time indeces of all cloudbases found  (without NaNs in between)   
%             success_depol_ratio_in_range      ->  vector of lenght(cloudbase_inM_redutime_L) . 1=depolratio was in allowed range,  0=depolratio was not in allowede range
%             cloud_bin_matrix_L                ->  (row x col)Matrix , variing size 
%                                                       each row corresponds to one height bin , defined by 'height_bin_edges_L'
%                                                       cells are filled up with redutime indeces of CB's that belong to this bin
%                                                       ATTENTION: emty cells are filled with ZEROS
%                                                       Example:
%                                                               height_bin_edges_L = [1000:1000:5000]  = [1000, 2000, 3000 ,4000, 5000]
%                                                               cloudbase_inM_redutime_L = [ 2112 , 3500 ,2345 , 2005, 3700]
%                                                               cloud_bin_matrix_L =    0   0   0           <-- 1000-2000
%                                                                                       1   3   4           <-- 2000-3000
%                                                                                       2   5   0           <-- 3000-4000
%                                                                                       0   0   0           <-- 4000-500
% 
%                                                               You want to know the maximum(tot_in)(channel=1) values of all clouds in height bin(3) 3000m-4000m :
%                                                                   %   max_Mcps_in_cloudrange_redutime(  1,  ( nonzeros( redutime_indeces_of_clouds_within_cloud_bin(3 , :) )   )   )
%                               
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





function [success_depol_ratio_in_range, cloud_bin_matrix_L] = statistical_analysis_inversion_success_fct(...
                                                                                            cloudbase_inM_redutime_L,...
                                                                                            depol_ratio_mean_above_CB_redutime_L,  ...
                                                                                            depolratio_allowed_range_redutime_L,...
                                                                                            time_rof_clouds_L,...
                                                                                            height_bin_edges_L)









%% Find points where depolratio was in allowed range
%       find corresponding cloud_max value
for redu_t=1:length(time_rof_clouds_L)
    if ( (depolratio_allowed_range_redutime_L(1,redu_t) < depol_ratio_mean_above_CB_redutime_L(redu_t))   &   (depol_ratio_mean_above_CB_redutime_L(redu_t) < depolratio_allowed_range_redutime_L(2,redu_t) )  )
        % If inside allowed range
        success_depol_ratio_in_range(redu_t) = 1;
    else
        % If outside allowed range
        success_depol_ratio_in_range(redu_t) = 0;
        
        %  Usually depolratio is too large, but not too small.
        %  For the case that it is too small, give a hint on the display (but no error)
        %  if that happens often maybe it is interesting to analyse failed inversion seperately vor too small and too large depolratio
        % If smaller than allowed range
        if (depol_ratio_mean_above_CB_redutime_L(redu_t) < depolratio_allowed_range_redutime_L(1,redu_t)  )
            fprintf('  ..statistical_analysis_inversion_success_fct says: I observed the rare case that the value of depolratio_above_CB is smaller the allowed range.\n ');
        end    
    end
end



%% Set all max_Mcps zero if depol ratio was OUT of range
% max_Mcps_in_cloudrange_redutime_only_success_L   =  max_Mcps_in_cloudrange_redutime_L .* success_depol_ratio_in_range


%% Set all max_Mcps zero if depol ratio was INSIDE of range
% max_Mcps_in_cloudrange_redutime_only_NO_success_L   =  max_Mcps_in_cloudrange_redutime_L .* abs(success_depol_ratio_in_range-1);




%% Sort for cloud-base heights
for hbin=1:(length(height_bin_edges_L)-1)
    
    redutime_indeces = find(  ( height_bin_edges_L(hbin) <=cloudbase_inM_redutime_L ) &   ( cloudbase_inM_redutime_L < height_bin_edges_L(hbin+1) )    );     % Creates a vector wich contains all indeces of clouds which lie in this hight bin
    
    % Make sure that time_indeces is not empty                                                                  % ->neccessary, such that a line (of zeros) in the data is added
    redutime_indeces(isempty(redutime_indeces))=0 ;

    % Store all found indeces
    for i=1:length(redutime_indeces)                                                                            % Loop seems neccessary, since time_indeces is of different sizes 
        cloud_bin_matrix_L(hbin,i) = redutime_indeces(i);   % value might be ZERO !!                            % Each row corresponds to one height bin, The cells are filled up with the indeces og the clouds which are in this bin. When no further clouds belong to the bin cells are filled with ZEROS !!!
    end
    
end

% histogram1=histogram(cloudbase_inM_L,height_bins_L);                                                          % For testing : This one should display the above













%% hier gehts weiter
% max_Mcps_in_cloudrange_redutime_only_NO_success_L(  3, ( nonzeros( cloud_bin_matrix_L(9 , :) )  )   )



%%
% möchte wissen für 1km. max-tot-in von denen die nicht succesfull waren
% plot(


%% old version
% for hbin=1:(length(height_bin_edges_L)-1)                                                                       % Go through all rows - each row one CB heigth bin
%     
%     for i_cell=1:size(redutime_indeces_of_clouds_within_cloud_bin,2)                                                % Go through all cells - each cell contains one time-index (many might be zero !!!)
%         
%         redu_time_index = redutime_indeces_of_clouds_within_cloud_bin(hbin,i_cell);                                          % get the time index of the cloud base
%         
%         if (redu_time_index ~= 0)                                                                                        % important since tindex is often ZERO
%             
%             % check if inversion was successfull ( = depolratio in allowed range)
%             if ( (depolratio_allowed_range_redutime_L(1,redu_time_index) < depol_ratio_mean_above_CB_redutime_L(redu_time_index))   &   (depol_ratio_mean_above_CB_redutime_L(redu_time_index) < depolratio_allowed_range_redutime_L(2,redu_time_index) )  )
%                 % depolratio is in range
%                 counter_depol_in_allowed_range(hbin)        =   counter_depol_in_allowed_range(hbin)+1     ;
%             else
%                 % depolratio is in range
%                 counter_depol_NOT_in_allowed_range(hbin)    =   counter_depol_NOT_in_allowed_range(hbin)+1 ;
%             end
%             
%         end
%         
%     end
% end


% [N_depolratio_mean_above_CB,edges_drmaCB] = histcounts(depol_ratio_mean_above_CB_redutime_L,height_bin_edges_L);
% 
% 
% histogram1=histogram(cloudbase_inM_L,height_bin_edges_L);

%%% Preample:
%
% hier ist so ein bisschen doppelgemoppel drin. da es jeweils fulltime als auch reduced_time daten gibt.
% zb enthalten diese beiden ausdrücke identische daten:
%                                                                          tot_in                                                        höhenbin9
%   max_Mcps_in_cloudrange_redutime_L                                     (  1,  (   nonzeros(   redutime_indeces_of_clouds_within_cloud_bin(9 , :) )   )   )
%   max_Mcps_in_cloudrange_L( 1,   ( time_rof_max_Mcps_in_cloudrange_res_closest (   nonzeros(   redutime_indeces_of_clouds_within_cloud_bin(9 , :) )   )   )      )
% 


% %% Create full time-range data 
% depol_ratio_fulltime(1:length(cloudbase_inM_fulltime_L))=NaN;                                                            % To make sure that vector gets full length. if NaN is used instead of 
% depolratio_allowed_range_fulltime(1:2,1:length(cloudbase_inM_fulltime_L))=NaN;
% 
% depol_ratio_fulltime(time_rof_clouds_L) = depol_ratio_mean_above_CB_redutime_L;                                          % creates fulltime vector. all empty values are set to NaN -> cannot be plottet using line, but with option ,'o' for example its no problem
% depolratio_allowed_range_fulltime(:,time_rof_clouds_L) = depolratio_allowed_range_redutime_L;


%% Sort data due CB heights

% find(cloudbase_inM_L

end  %function




















