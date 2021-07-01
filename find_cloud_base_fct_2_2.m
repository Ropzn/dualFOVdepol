%
% Finds the cloud base
%       Input: signal, height range in which cloud search is performed
%
%       Output: cloudbase_L(time)=height         (contains all times,also the ones where there is no cloud ,
%               time_rof_found_cloudbases_L     (contains all time indeces where clouds where found )
%
%           if no cloud was found (within height_rof_cloudsearch) then:
%               time_rof_found_cloudbases_L=99999
%
%
%        Example Call:
%       [cloudbase,time_rof_found_cloudbases] = find_cloudbase_L_august_fct (signal,height_rof_cloudsearch,depol_out_cal_rof_height,inputfile,logfile)
%
%
%       difference to version 2.1 :     different threshold



function [cloudbase_L,time_rof_found_cloudbases_L] = find_liquid_water_phase_1_0 (signal_L,height_rof_cloudsearch_L,...
                                                                                    inputfile_L,logfile_L)

ss_L = 0;                                                                   % counter for cloud bases found. If it stays 0 no cloud base was found.
signal_L=squeeze(signal_L);                                                 % eliminate first (useless) channel-dimension

threshold_1 = 0.07; %0.06
threshold_2 = 0.09; %0.09
threshold_3 = 0.1; %0.1
threshold_4 = 0.25;

fprintf('.."find_cloudbase_fct_2_2.m" says : threshold_1 = 0.07..');


for t_L=1:size(signal_L,2)                                                  % go through all time bins.  size(signal,2) gives the no of elements along 2nd dimension which is the time bins
    clear zmin_L signal_normalized_to_max_L ;
    
    % Find maximum signal
    [max_signal_L max_signal_index_L(t_L)]=max(signal_L(1:height_rof_cloudsearch_L(end),t_L));
    % normalize signal
    signal_normalized_to_max_L(:,t_L) = signal_L(:,t_L) / max_signal_L;
    
    
    %Threshold 1
    if max_signal_index_L(t_L)>100                                 % if altitude of max was large enough
        % first test for cloud base
        zmin_L=find( signal_normalized_to_max_L(height_rof_cloudsearch_L,t_L)<threshold_1,1,'last' )  +  height_rof_cloudsearch_L(1);            %find the last element within one time all heights which is smaller than 0.06 . Add the lower boundary of cloudsearch to have the real height-bin. units are all in bins.
        zmin2_L=find( signal_normalized_to_max_L(height_rof_cloudsearch_L,t_L)>threshold_2,1,'first' )  +  height_rof_cloudsearch_L(1) - 1;       %find the first element within one time all heights which is larger than 0.09 . Add the lower boundary of cloudsearch to have the real height-bin. substract one bin. units are all in bins.
        %Threshold 2
        if isfinite(zmin_L)                                                     % continue only if first test found some zmin
            if zmin_L > zmin2_L                                                 % zmin>zmin2 -> signal drops after cloud again significantly  -->  Check for multilayer cloud
                [max_in_cloud max_in_cloud_index(t_L)]=max(signal_L(zmin2_L:zmin2_L+30,t_L));             % search the max in (zmin:zim2+30)
                max_in_cloud_index(t_L)=max_in_cloud_index(t_L)+zmin2_L-1;                                                % shift to "real" hight-bins
                signal_normalized_to_max_in_CLOUD_L(:,t_L)=signal_L(:,t_L)/max_in_cloud;
                
                zmin_L = find(signal_normalized_to_max_in_CLOUD_L(100:max_in_cloud_index(t_L),t_L)<threshold_1,1,'last')+100;  % find max in cloud
                
                % Threshold 3
                if isempty(zmin_L)                                              % If threshold was not reached continue
                    zmin_L = find(signal_normalized_to_max_in_CLOUD_L(100:max_in_cloud_index(t_L),t_L)<threshold_3,1,'last')+100;%-4;                 % Set threshold a bit "easier" to reach
                    % Threshold 4
                    if isempty(zmin_L)                                         % If "easier" threshold was NOT reached
                        cloudbase_L(t_L)=NaN;                                                                                            	% No cb found
                        zmin_L = find(signal_normalized_to_max_in_CLOUD_L(100:max_in_cloud_index(t_L),t_L)<threshold_4,1,'last')+100;%-15;           % Set zmin a even more  "easier" to reach
                        
                    else
                        cloudbase_L(t_L)=zmin_L;                                                                                             % CB=zmin
                        ss_L = ss_L +1;
                        time_rof_found_cloudbases_L(ss_L) = t_L;
%                         disp('threshold 4: isNOTempty(zmin_L) ')
                    end
                else
                    cloudbase_L(t_L)=zmin_L;
                    ss_L = ss_L +1;
                    time_rof_found_cloudbases_L(ss_L) = t_L;
%                     disp('threshold 3: isNOTempty(zmin_L) ')

                end
            else
                cloudbase_L(t_L) = zmin_L;                                          % cb is found
                ss_L = ss_L +1;
                time_rof_found_cloudbases_L(ss_L) = t_L;
%                 disp('threshold 2: zmin_L < zmin2_L ')
            end
            %%
        else
            cloudbase_L(t_L) = NaN;                                                 %save value to vector which contains cloud base values of all times
        end
    else                                                                        % if max_signal to low in altitude
        %zmin_L=depol_out_cal_rof_height_L(end);                                             % set artificial higher bound at
        cloudbase_L(t_L)=NaN;                                                                  % then say no cb was found (koennte probleme machen..?!)
    end
    
    % version 2.1 kill all values outside range
    if cloudbase_L(t_L)<height_rof_cloudsearch_L(1) || cloudbase_L(t_L)>height_rof_cloudsearch_L(end)
        cloudbase_L(t_L)=NaN;  
        time_rof_found_cloudbases_L(ss_L) = NaN;
    end

    
    
end

% version 2.1: reduce time-vector which probably have nans
time_rof_found_cloudbases_L_dummy = time_rof_found_cloudbases_L(~isnan(time_rof_found_cloudbases_L));
clear time_rof_found_cloudbase_L;
time_rof_found_cloudbases_L = time_rof_found_cloudbases_L_dummy;





if ss_L==0
    fprintf('\n ........No clouds found (within height_rof_cloudsearch) in %s \n',inputfile_L);
    fprintf(logfile_L,' -->No clouds found (within height_rof_cloudsearch)\n');
    time_rof_found_cloudbases_L=99999;
end;

% cloudbase_L = cloudbase_L - 2;  %% Test ACHTUNG 15.7. robert
end
