%% Get a matlab-numeric time vector from nc-file
%
%   input:       measurement_time               (2 x (no. of measurment bins) )   double
%
%   output:     measurement_time_num_L          matlab-numeric-time (1 x  (no. of measurment bins)) double
%
%
%  the variable measurement_time in the nc is a matrix of the form  (2 x measurement bins)
%       first row contains the date as a double value yyyymmdd
%       second row contains the seconds passed from 00:00 o'clock of the above day.
%       eg: first coloumn is [20190322]  and [21600]  which corresponds to 2019-03-22 06:00:00
%
%





function measurement_time_num_L = convert_measurement_time_from_nc_to_numeric_time(measurement_time_L)

%% Read in first row (date)  - all entries          % this is more general and also works for the case, that the date changes within one nc-file, but it takes almost 2 seconds...
for k=1:size(measurement_time_L,2)            
    measurement_date_str(k,:)=num2str(measurement_time_L(1,k));    % gives a coloumn with the dates as strings  eg:'20190321'
    measurement_date_str_format(k,:)=strcat(measurement_date_str(k,1:4),'-',measurement_date_str(k,5:6),'-',measurement_date_str(k,7:8));  % puts some '-' between year-month-day  '2019-03-21'
    measurement_date_num(k) = datenum(measurement_date_str_format(k,:));  % gives matlab datenum format (wich is the number of days since 2000-01-01) (hours minutes and seconds are given by decimals(of a day) )
end

%% Read in first row (date)  just the first entry                                                                                      (suspecting the date does not change within nc-file)
% measurement_date_str=num2str(measurement_time_L(1,:));                                                                        % gives a coloumn with the dates as strings  eg:'20190321'
% measurement_date_str_format=strcat(measurement_date_str(1:4),'-',measurement_date_str(5:6),'-',measurement_date_str(7:8));  % puts some '-' between year-month-day  '2019-03-21'
% measurement_date_num = datenum(measurement_date_str_format);                                                                % gives matlab datenum format (wich is the number of days since 2000-01-01) (hours minutes and seconds are given by decimals(of a day) )

%% add the seconds of second row and convert to numeric time
measurement_time_sec = measurement_time_L(2,:);                                                                               % get the seconds wich passed since 00:00 o'clock
measurement_time_num_L = datenum(measurement_date_num + seconds(measurement_time_sec));                                                % gives matlab datenum format (wich is the number of days since 2000-01-01) (hours minutes and seconds are given by decimals(of a day) )


%% check time
% datestr(measurement_time_num(1))




end