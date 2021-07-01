%%    Find closest values
% 
%       Input:  inputVector,                  vector of length cc
%               findclosest_inthis_vector     vector of lentht dd
%       Output:
%               closestIndex                  vector of length cc
% 




%%
function [Mcps_above_CB, max_Mcps_above_CB]  = find_max_above_CB_fct(sig_Mcps_L, cloudbase_L, time_rof_clouds_L, integration_depth_L)
   
    for ch=1:4                                                                                                           % Loop over all 4 Channels
        for i=1:length(time_rof_clouds_L)                                                                                 % Loop over time
            height_range_above_CB = cloudbase_L(time_rof_clouds_L(i)):cloudbase_L(time_rof_clouds_L(i))+integration_depth_L ;                                 % this is the CB bin + some bins above  (some bins = integration depth)
            Mcps_above_CB(ch,:,i) = sig_Mcps_L(ch,height_range_above_CB,time_rof_clouds_L(i));
            [max_Mcps_above_CB(ch,i),max_Mcps_above_CB_height_index_above_CB(ch,i)] = max(Mcps_above_CB(ch,:,i) ) ;
        end
    end
  disp(',');  
    
end