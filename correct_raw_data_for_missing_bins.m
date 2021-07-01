%% Correct raw data if time bins are missing

%     measurement_time_num    gets additional time bins    
%
% 
%     raw_signal              get additional NaN bins
%     depol_cal_angle         get additional NaN bins
%     measurement_shots       get additional NaN bins
%
%
%   The implementation is NOT yet CORRECT for
%           measurement_time
%       it should be done analogously to measurement_time_num
%           
%   No correction is implemented for
%           location coordinates




%% find missing time bins
a=0;
for i=1:length(measurement_time_num)-1
    if measurement_time_num(i+1)-measurement_time_num(i)> 3.4723e-04
        i;
        a=a+1;
        if measurement_time_num(i+1)-measurement_time_num(i)> 2*3.4723e-04
            disp('correct_raw_data_for_missing_bins.m says: Here more than 30 seconds are missing in a row. I do not correctly correct here. Please check !!\n\n');
            return;
            i;
        end
    end
end


%% If time bins are missing correct all raw data by inserting NaN
tic
if a>0
    fprintf('correct_raw_data_for_missing_bins.m says:  I found %d missing bins and correct the data set...',a);
    t2=2;
    
    for t1=2:length(measurement_time_num)
        if measurement_time_num(t1)-measurement_time_num(t1-1)> 3.4723e-04
            %all relevant data
            raw_signal_COPY(:,:,t2)                =NaN;
            depol_cal_angle_COPY(t2)        =NaN;
            % location coordinates(...) not used here
            measurement_shots_COPY(:,t2)    =NaN;
            measurement_time_COPY(:,t2)     =NaN;
            measurement_time_num_COPY(t2)   =measurement_time_num_COPY(t2-1)+3.4722e-04;
            
            t2=t2+1;
        end
        %all relevant data
        raw_signal_COPY(:,:,t2)                = raw_signal(:,:,t1);
        depol_cal_angle_COPY(t2)        = depol_cal_angle(t1);
        % location coordinates(...) not used here
        measurement_shots_COPY(:,t2)    = measurement_shots(:,t1);
        measurement_time_COPY(:,t2)     = measurement_time(:,t1);
        measurement_time_num_COPY(t2)   = measurement_time_num(t1);
        
        t2=t2+1;
    end
    % The first elements are still empty and need to be copied
    raw_signal_COPY(:,:,1)                = raw_signal(:,:,1);
    depol_cal_angle_COPY(1)        = depol_cal_angle(1);
    % location coordinates(...) not used here
    measurement_shots_COPY(:,1)    = measurement_shots(:,1);
    measurement_time_COPY(:,1)     = measurement_time(:,1);  %there are still nans include here. 
    measurement_time_num_COPY(1)   = measurement_time_num(1);
    
    
    raw_signal              = raw_signal_COPY;
    depol_cal_angle         = depol_cal_angle_COPY;
    % location coordinates(...) not used here
    measurement_shots       = measurement_shots_COPY;
    measurement_time        = measurement_time_COPY;
    measurement_time_num    = measurement_time_num_COPY;
    
    
    
    clear raw_signal_COPY depol_cal_angle_COPY measurement_shots_COPY measurement_time_COPY measurement_time_num_COPY t2 t1
    fprintf('...done. \n');
end
