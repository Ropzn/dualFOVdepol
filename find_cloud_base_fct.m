%
% Finds the cloud base
%       Input: signal, height range in which cloud search is performed
%
%       Output: cloud_base(time)=height         (contains all times,also the ones where there is no cloud ,
%               time_rof_found_cloudbases_L     (contains all time indeces where clouds where found )
%           
%           if no cloud was found (within height_rof_cloudsearch) then: 
%               time_rof_found_cloudbases_L=99999
%
%
%        Example Call:
%       [cloudbase,time_rof_found_cloudbases] = find_cloud_base_fct (signal,height_rof_cloudsearch,inputfile,logfile)

function [cloudbase_L,time_rof_found_cloudbases_L] = find_cloud_base_fct (signal_L,height_rof_cloudsearch_L,inputfile_L,logfile_L)

ss_L = 0;                                                                   % counter for cloud bases found. If it stays 0 no cloud base was found.
signal_L=squeeze(signal_L);                                                 % eliminate first (useless) channel-dimension


for t_L=1:size(signal_L,2)                                                  % go through all time bins.  size(signal,2) gives the no of elements along 2nd dimension which is the time bins
    clear zmin_L signal_normalized_to_max_L ;
    
    signal_normalized_to_max_L(:,t_L) = signal_L(:,t_L) / max(signal_L(height_rof_cloudsearch_L,t_L));
    
    % first test for cloud base
    zmin_L=find( signal_normalized_to_max_L(height_rof_cloudsearch_L,t_L)>0.09,1 )  +  height_rof_cloudsearch_L(1) - 1;       %find the first element within one time all heights which is larger than 0.07 . Add the lower boundary of cloudsearch to have the real height-bin. substract one bin. units are all in bins.
    
    % continue only if first test found some zmin
    if isempty(zmin_L)
        cloudbase_L(t_L) = NaN;                                             %save value to vector which contains cloud base values of all times
    else
        % second test for cloud base                                        %because first test liefert auch result f�r keine wolken-case
        if mean( signal_normalized_to_max_L( zmin_L+2 : zmin_L+10 , t_L )) > 3* mean( signal_normalized_to_max_L( zmin_L-3 : zmin_L , t_L ))        %If there is suddenly a strong increase in signal, ie. 3times larger then below, then it should be cloud
            cloudbase_L(t_L) = zmin_L;                                      %save value to vector which contains cloud base values of all times
            ss_L = ss_L +1;
            time_rof_found_cloudbases_L(ss_L) = t_L;
        else
            cloudbase_L(t_L) = NaN;
        end
    end
    
end;


if ss_L==0
    fprintf('\n ........No clouds found (within height_rof_cloudsearch) in %s \n',inputfile_L);
    fprintf(logfile_L,' -->No clouds found (within height_rof_cloudsearch)\n');
    time_rof_found_cloudbases_L=99999;
end;

% cloudbase_L = cloudbase_L - 2;  %% Test ACHTUNG 15.7. robert
end
