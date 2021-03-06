
%% Program Description
%

%bitte c_out manuelle corrigieren auf 0.00184


%%  Vorbereitungen

% if "clear all" is used, then Breakpoints are cleared as well and will not work
clear all
%close all
clc



%% Load global parameters
  global_parameters_Arielle_case;

%  global_parameters_Dushanbe_case;

%   global_parameters_Punta_case;



tic

% arielle 24.11. ff=11

%% The Great Loop
for ff=2%:length(InputFiles_lidar) %9%11%24%11%8%:4%                                          % 1 loopdurchgang pro file

% clear all variables which might be leftover from last loop or program run
%       this is not a complete list of all variables. some variables get
%       cleared elswhere to free memory, after they are not needed any more
clearvars('-except',InitialVariableNames{:}, 'ff' , 'last_file_with_calibration' , 'C_Mcps_bc_rc' , 'C', 'file_number' );



if delete_all_open_figures_each_loop==1
    close all;
end
    
    
    
    
%% NetCDF einladen
fprintf('\n---------------------------------------------------------\n Loop %d ::: Processing %s \n---------------------------------------------------------\n',ff,InputFiles_lidar{ff});
fprintf(logfile,'\n%s ::: Loop %d ::: Processing %s ------------\n',datestr(now,'dd.mmmm yyyy HH:MM:SS'),ff,InputFiles_lidar{ff});


%%%%%%%%%%%%%% Daten einlesen und vorbereiten %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get data from NetCDF--
fprintf('Loading NetCDF file ... ');
tic;
ncid = netcdf.open(fullfile(data_path, InputFiles_lidar{ff}), 'NC_WRITE');
[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);                     %net cdf wird eingelesen
for i=0:nvars-1
    [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,i);               % herausfinden welche daten drin sind
    data = double(netcdf.getVar(ncid,i));                               % daten in localen workspace laden
    eval([varname,'=data;']);
end

% not used anymore . to free memory
netcdf.close(ncid);
clear data;
fprintf(' ... done. (If that took too long, check your Ram. If its allready full this wont work....) ');

if toc>20
    fprintf(' That took quite long, check your Ram. Your machine might not be good enough for what is still coming.... ');
end


%
% For Lacros set deadtime Polynomial manuell
if lacros_or_arielle==1
    deadtime_polynomial(13,:)=deadtime_polynomial_lacros;               %for new channel of lacros since data is missing in netcdf, daher manuell
    disp('LACROS: Deadtime polynomial for Channel 13 set manually');
else
    disp('Deadtime is used from NC file --- for arielle');
end





% Get numeric measurement-time vector
fprintf('Get numeric measurement-time vector ... ');

measurement_time_num = convert_measurement_time_from_nc_to_numeric_time(measurement_time);
fprintf('done. \n ');



%% Correction for lost measurements
correct_raw_data_for_missing_bins;

disp('break here to correct for lost data');

%%  Reduction Dataset + Mcps

% Reduce Dataset and extract Range for Backgroundcorrection
%       - to the 4 channels,
%       - eleminating the pretrigger (251 bins) and setting maxheight
%       - This reduces cpu-time and RAM-use dramatically since all heights between bin 1000:5500 are not used
%       - Drawback: some operations on the variables raw_signal and
%                   BG_raw have to be coded twice
%

%%% Debug Time:
%%%     if the following line is evaluated, than the whole dataset(timewise) is evalutated
debug_time=1:size(raw_signal,3);                                       % comment out this line if max_time should be used as defined up above

 time_rof_calibration_out = 1:size(raw_signal,3);                           % dynamically set. just to make sure it has full length, if shorter length is wanted, delete this line and see definition before loop
 time_rof_profile_in_bins = 1:size(raw_signal,3);                           % dynamically set. just to make sure it has full length, if shorter length is wanted, delete this line and see definition before loop





% BG_raw              =raw_signal(rangocanales,1:pretrigger-5,debug_time);                            % Get Background from pretrigger
raw_signal          =raw_signal(rangocanales,pretrigger:maxheight,debug_time);         % (251 bin=0m) ... (251+933 bins= 10km)
BG_raw              =raw_signal(:,BG_rof_height,debug_time);                           % get Background form 40km

measurement_shots   =measurement_shots(:,debug_time);
depol_cal_angle     =depol_cal_angle(debug_time);









%%%%%%%%%%%%%% Berechnung Mcps     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% In jedem raw_signal bin sind die Counts die innerhalb von 30sec(A)
%%% mit ~600 Schuss(B) pro 50nsec = 15m => 7.5m Hoehenbin (C) aufgenommen wird.
%%%     (A) kann aus 'measurement_time' abgeleitet werden (ist aber
%%%         immer 30 sec
%%%     (B) wird jedesmal aus 'measurement_shots' gelesen und ist fuer
%%%         die Channels etwas unterschiedlich
%%%     (C) Ist in 'measurement_height_resolution' beschrieben und fuer
%%%         alle Channels gleich. In 50nsec legt Licht einen weg von
%%%         15m zurueck. Das es kann einen Hoehenbereich von 7.5m hin und
%%%         zurueck durchqueren.
%%%     (D) Dh. Es wird mit einer Laserfrequenz von ca 20Hz gemessen.
%%%
%%% Umrechnung von raw_signal in Mcps pro H??henbin pro Schuss ist also:
%%%     raw_signal_Mcps =
%%%     raw_signal / measurement_shots / measurement_height_resolution / 1000000
%%%                                                                         ^--> umrechnung in 'Mega'
%%%     Erklaerung:
%%%     raw_signal / 600 Shots   => raw_signal pro schuss
%%%          [Counts/600 Shots]  =>  [Counts/shot]
%%%
%%%     raw_signal / 600 [Shots] / (50*10^-9) [Sec/Shot] => raw_signal
%%%         [(Counts/shot)    /      (Sec/Shot) ]        = [Counts/Sec]
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(rangocanales)
    raw_signal_Mcps(i,:,:)=bsxfun(@rdivide, squeeze(raw_signal(i,:,:)), squeeze(measurement_shots(i,:)));
    % bsxfun(@rdivide,Matrix,Vector)  Divides Matrix Elementwise by a vector.    In MATLAB?? R2016b and later one could use simply Matrix./Vector
    % squeez(M) Loescht dimensionen mit 1,eg: M =>1x6400x720  , squeeze(M) => 6400x720
    % measurement_shots(channel,timebin)
    BG_raw_Mcps(i,:,:)=bsxfun(@rdivide, squeeze(BG_raw(i,:,:)), squeeze(measurement_shots(i,:)));           % the same for Backgroundsignal
end
%     clear raw_signal and BG_raw;
raw_signal_Mcps =  raw_signal_Mcps  / (measurement_height_resolution*10^(-9)) / 1000000;            %1 =5=532  2 =6=532c, 3 =9=532out, 4 =13=532c_out
BG_raw_Mcps     =  BG_raw_Mcps      / (measurement_height_resolution*10^(-9)) / 1000000;            % the same for Backgroundsignal
% end calculation Mcps

%% The following lines give almost the same results :-)
% raw_signal_Mcps =  raw_signal  / 30;            
% BG_raw_Mcps     =  BG_raw      / 30;  

disp('reduction + Mcps  - done');





%% Simulation of deadtime error by plateauing ------------------------
%  raw_signal_Mcps = simulate_deadtime_error_fct (raw_signal_Mcps,+0.1,1);
%  raw_signal_Mcps = simulate_deadtime_error_fct (raw_signal_Mcps,+0.1,2);
%  raw_signal_Mcps = simulate_deadtime_error_fct (raw_signal_Mcps,+0.1,3);
%  raw_signal_Mcps = simulate_deadtime_error_fct (raw_signal_Mcps,+0.1,4);




%% Find Signal-Peaks within Cloud-search-range
% For every channel and for every time find the maximum signal
%       Atension:   if one only looks at "cloud_max_Mpcs_height_bin" this
%                   might be missleading, since also for "noCloud"conditions the
%                   maximum is evaluated, however the value might be very low.
%                   one should further look at cloud_max_Mpcs
%                   to see the max values themselves !
%      cloud_max_Mpcs(channel,time)=Mcps
%      cloud_max_Mpcs_height_bin(channel,time)=heightbin 

for ch=1:4                                                                                                           % Loop over all 4 Channels
    for t=1:size(raw_signal_Mcps,3)                                                                                 % Loop over time
        [max_Mcps_in_cloudrange(ch,t),max_Mpcs_in_cloudrange_height_bin(ch,t)] = max(raw_signal_Mcps(ch,height_rof_cloudsearch,t));
    end
    max_Mpcs_in_cloudrange_height_bin(ch,:)=max_Mpcs_in_cloudrange_height_bin(ch,:) + height_rof_cloudsearch(1);                      % Cloud-height index must be shifted by lower end of height_rof_cloudsearch since only in this range was searched.
end
disp('Signal peaks - done');




%% Deadtime
% Prepare Deadtimepolynomial
deadtime_polynomial        = flip(deadtime_polynomial(rangocanales,:)')';                           % Reduce to needed channels and change the order of the elements, such that they can be evaluated by polyval later on
deadtime_polynomial_error  = flip(deadtime_polynomial_error(rangocanales,:)')';                           % Reduce to needed channels and change the order of the elements, such that they can be evaluated by polyval later on

%%
%%%%% Deadtimecorrection %%%%  ( _dc = deadtime-corrected  )
for j=1:length(rangocanales)                                                                       % for all channels
    signal_dc(j,:,:)=polyval(deadtime_polynomial(j,:),raw_signal_Mcps(j,:,:));                      % deadtime correction for all signals
    BG_dc(j,:,:)=polyval(deadtime_polynomial(j,:),BG_raw_Mcps(j,:,:));                              % the same for Backgroundsignal  % probably not neccessary due to low count-rates...
    signal_dc_error(j,:,:)=polyval(deadtime_polynomial_error(j,:),raw_signal_Mcps(j,:,:));
%     signal_dc(j,:,:)=raw_signal_Mcps(j,:,:);
%     BG_dc(j,:,:)=BG_raw_Mcps(j,:,:);
end

disp('Deadtimecorrection - done');





%% Background and range correction
%%%%% Background + range correction %%%% (bc=background corrected) (rc=range corrected)

% extract mean of Background signal for each time bin
mean_BG_raw_Mcps(:,:)   =nanmean(BG_raw_Mcps,2);                                                    % BG(Channel,Time)  % mean along array dimension 2 (=height)
mean_BG_dc(:,:)         =nanmean(BG_dc,2);                                                          % background signals WITH deadtime correction


height = (bin_height:bin_height:bin_height*length(signal_dc(1,:,1)))';                                                   % Create a Column vector with bins in meter .
height_sqare = (height.*height)';


%  Background + range correction   (Takes 1 minute CPU at Robs Laptop)                               % corrected_signal = ( signal - background ) * height??
for j=1:length(rangocanales)
    for i=1:size(raw_signal_Mcps,3)                                                                 % go through all time bins.  size(raw_signal_Mcps,3) gives the no of elements along 3rd dimension which is the time bins
        signal_Mcps_bc_rc(j,:,i)        = (raw_signal_Mcps(j,:,i) - mean_BG_raw_Mcps(j,i))      .*height_sqare;  % signal without deadtime correction (bc=background corrected) (rc=range corrected)
        signal(j,:,i)          =    (signal_dc(j,:,i)    - mean_BG_dc(j,i))            .*height_sqare;  % signal WITH deadtimecorrection and (bc=background corrected) (rc=range corrected)
        signal_smoothed(j,:,i) = smooth((signal_dc(j,:,i)- mean_BG_dc(j,i)),smooth_parameter_sig)'  .*height_sqare;    % To be correct: here it is smoothed before rangecorection
        
        % If sig~0 then negative values are introduced by BC, delete these ones
%         signal_Mcps_bc_rc(signal_Mcps_bc_rc<=0)=NaN;  Das ist FALSCH,denn dadurch wird ein Gewicht in die Daten eingebaut !!!
%         signal(signal<=0)=NaN;      Das ist FALSCH,denn dadurch wird ein Gewicht in die Daten eingebaut !!!
    end
end


%clear raw_signal_Mcps;

disp('Background + range correction - done');







 


%% Extract data during calibration - and NaN data during calibration in signal
% Extract data during calibration
time_rof_calibration    =   find(depol_cal_angle>depol_cal_angle_threshold);                                   % rangotc gibt den (Zeit)Bereich an, in welchem Calibriert wurde. Hier muss je nach System ein threshold eingestellt werden, damit die Werte waehrend der Kalibrierung (alle paar stunden) rausgefiltert werden.Dafuer einfach mal die Variable depol_cal_angle anschauen und gucken, wo der Wert wie springt

%
% disp('ACHTUNG nur 2. kalibrierung wird genutzt!!!!');
% time_rof_calibration = time_rof_calibration(22:42);


signal_during_calibration = signal(:,:,time_rof_calibration);

disp('Arielle 13.11. manuell unvollst??ndige filter drehungen rausgeworfen  ')
s1=signal_during_calibration(:,:,1:20);
clear signal_during_calibration
signal_during_calibration(:,:,1:20)=s1;
clear s1

% disp('Arielle 13.11. manuell unvollst??ndige filter drehungen rausgeworfen  Arielle fuer 13.-14.11. ')
% s1=signal_during_calibration(:,:,1:20);
% s2=signal_during_calibration(:,:,23:42);
% clear signal_during_calibration
% signal_during_calibration(:,:,1:20)=s1;
% signal_during_calibration(:,:,21:40)=s2;
% clear s1 s2


% disp('Dushanbe 16.9. manuell unvollst??ndige filter drehungen rausgeworfen  ')
% s1=signal_during_calibration(:,:,1:19);
% s2=signal_during_calibration(:,:,22:40);
% clear signal_during_calibration
% signal_during_calibration(:,:,1:19)=s1;
% signal_during_calibration(:,:,20:38)=s2;
% clear s1 s2

disp('Extract data during calibration   ... done.');





disp('Extract data during calibration   ... done.');



%% Depol Calibration of inner FOV %%%%%%%%%%%%
%%%%%% Check if Calibration is available

fprintf('Calibration constant inner FOV ... ');
if length(time_rof_calibration)>1
    last_file_with_calibration=InputFiles_lidar{ff};
    
    %%% NaN the TimeRange of Calibration(+-1) for all Channels
    %           --> so that it is not used for colorplots and further calculation
    
    % This version does NOT for if more than one calibration range is present
%     signal(:,:,(time_rof_calibration(1)-1):(time_rof_calibration(end)+1)) = NaN;
%     signal_smoothed(:,:,(time_rof_calibration(1)-1):(time_rof_calibration(end)+1)) = NaN;

    % This version works for if more than one calibration range is present
    signal(:,:,(time_rof_calibration) )= NaN;
    signal_smoothed(:,:,(time_rof_calibration)) = NaN;
    
    fprintf('Write NaNs for the time of the calibration into the variable signal ...');

    
    %%% Calculate Calibration Constant Inner FOV
    C      = depol_const_inner_fct(signal_during_calibration(1,:,:),signal_during_calibration(2,:,:),depol_cal_rof_height,Rt_in,Rc_in);       % Calculate Calibration Constant
    
    
    
elseif exist('last_file_with_calibration','var')==1                                                     % Wenn Calibrierung aus vorigem Loopdurchlauf vorhanden, dann nutze diese
    fprintf('........No calibration time found.Used calibration of %s\n',last_file_with_calibration);
    fprintf(logfile,' -->No calibration time found.Used calibration of %s\n',last_file_with_calibration);
    
    % next 2 lines are computationally non-sense. just to show,that values from last loop are used
    C       = C;
    
else                                                                                                % Wenn keine Calibrierung aus vorigem Loopdurchlauf vorhanden, dann springe zum Loop mit naechster Datei
    fprintf('\n........No calibration time found.No earlier calibration available. Skip file.\n');
    fprintf(logfile,' -->No calibration time found.No earlier calibration available. Skip file\n');
    %continue;                                                                                       % continues to next loop iteration ff=..  . has to commented out if the codeblock is not used in the loop.
end
    fprintf('           ...done.\n');

%  disp('C fixed; Arielle fuer 13.-14.11. einmal ausgerechnet ohne unvollst??ndige filter drehungen');
%  C=0.15137556190054700;
%  C=0.1513
    
    
    
%% Find cloudbase %%%%%%%%%%%%%%%%%%%

fprintf('Cloudbase search....');
[cloudbase,time_rof_clouds] = find_cloud_base_fct_2_2 (signal_smoothed(1,:,:),height_rof_cloudsearch,depol_out_cal_rof_height,InputFiles_lidar{ff},logfile);

% disp('ACHTUNG CB veraendert')
% cloudbase = cloudbase -3;

cloudbase_inM      =   cloudbase * bin_height;                                        % Stores the Cloudbase in Meters

fprintf('... done.\n');






%% Relative calibration of outer FOV  %%%%%%%%%%%%%%%%%%%
%       based on   d_in=d_out , below CB
%           Height range:   dynamic (1km below cb & inside ..cal_rof_height)
%           Meaning:        Average is taken when ratio and volume-depol are used in formula for B.
%                           MEDIAN is used (instead of mean)

fprintf('Relative calibration of outer FOV....');

C_out =    depol_const_out_fct_2_0(signal_smoothed,  cloudbase,  time_rof_calibration_out,  depol_out_cal_rof_height,  C, Rt_in,Rc_in, Rt_out,Rc_out);

% DEBUG: to cross check with cristofers Program
% disp('debug:calc B_out');
%B_out =    depol_const_out_B_fct_2_0(signal_smoothed,  cloudbase,  time_rof_calibration_out,  depol_out_cal_rof_height,  C, Rt_in,Rc_in, Rc_out);


% reduced to time_rof_clouds
% fprintf('For B_out only time_rof_clouds is used\n');
% B_out =    depol_const_out_fct_hmm_1_2epsilon(signal_smoothed,  cloudbase,  time_rof_clouds,  depol_out_cal_rof_height,  C, Rt_in,Rc_in, epsilon_out);

fprintf('... done.\n');

% Dushanbe
% fprintf(' !!!!!!!!!! C_out manually set to ');
%  C_out = 0.00184

% Arielle
% fprintf(' !!!!!!!!!! C_out manually set to ');
% C_out = 0.2216

% Arielle
%   fprintf(' !!!!!!!!!! C_out or B_out manually set to ');
%  C_out = 0.3465 %0.35 %0.34 %0.35  %0.319; For 15th may
% C_out=0.070;  %For 14.11.
% B_out=0.0064

% Start loop on line 31

% disp('C_out fixed; Arielle fuer 13.-14.11. einmal ausgerechnet ohne unvollst??ndige filter drehungen');
% % C_out=0.063971802240324;
% C_out = 0.0365



%% Depol and ratio (range and time 5resolved)  (3Dim) %%%%%%%%%%%%%%%%%
% not used for anything at the moment

fprintf('Depol (range and time resolved) done....');

% Calculate Calibrated Depol of inner FOV  (time resolved)
depol_in_smoothed = depol_fct(signal_smoothed(1,:,:),signal_smoothed(2,:,:),C,Rt_in,Rc_in);

% Calculate Calibrated Depol of outer FOV  (time resolved)  
depol_out_smoothed = depol_fct(signal_smoothed(3,:,:),signal_smoothed(4,:,:),C_out,Rt_out,Rc_out);

% Ratio: Depol_in / Depol_out (time resolved)
% ratio_depol_inout = depol_in ./ depol_out;

% Delete non-nice values (good??)
depol_in_smoothed(depol_in_smoothed<0)=NaN;
depol_in_smoothed(depol_in_smoothed>1)=NaN;

fprintf('... done.\n');


%% DEBUG:  Depol out with B
% disp('debug:calc depol_out with B');
% depol_out_smoothed_by_B = depol_out_with_B_fct (signal_smoothed(3,:,:),signal_smoothed(4,:,:),B_out,Rc_out);
% depol_out_smoothed=depol_out_smoothed_by_B;




%% Calculate low resolution
    % Not used for anything at the moment

% 
% for ch=1:4
%     [signal_low_res(ch,:,:),time_low_res_in_bins]  =  change_time_resolution_fct(  squeeze(signal(ch,:,:)),  resolution_temporal_depol_mean_above_CB );     
% end








%% Mean(over time)Depol and Ratio( only range resolved) (2Dim) using smoothed mean %%%%%%%%%%%%%%%
% not used for inversion but for 2D plots

fprintf('Mean(over time)Depol and (Depol_in/Depol_out...')

% Calculate Calibrated Depol of Mean(over time) inner FOV
depol_in_mean_smooth = depol_fct(   smooth(nanmean(signal(1,height_rof_profile_in_bins,time_rof_profile_in_bins),3),smooth_parameter_depol_mean),...
                                            smooth(nanmean(signal(2,height_rof_profile_in_bins,time_rof_profile_in_bins),3),smooth_parameter_depol_mean),...
                                            C,Rt_in,Rc_in);

% Calculate Calibrated Depol of Mean(over time) outer FOV
depol_out_mean_smooth = depol_fct(    smooth(nanmean(signal(3,height_rof_profile_in_bins,time_rof_profile_in_bins),3),smooth_parameter_depol_mean),...
                                                smooth(nanmean(signal(4,height_rof_profile_in_bins,time_rof_profile_in_bins),3),smooth_parameter_depol_mean),...
                                                C_out,Rt_out,Rc_out);

% Ratio of Mean(over time): Depol_in / Depol_out
ratio_depol_mean_inout_smooth = depol_in_mean_smooth ./ depol_out_mean_smooth;
    
fprintf('...done\n')





%% If no clouds were found save figure (and mat file) and continue to next loop iteration here
if time_rof_clouds==99999
    save(strcat(result_path,InputFiles_lidar{ff},'.mat'));
    % Save all open figures in one single .fig file
    fprintf('main:Since no clouds were found, go to next nc-file. (next loop iteration)\n');
    continue;
end


%% Calculate low resolution above CB   -  this is not done vertically but along the CB
%
%          signal_low_res_above_CB   is of dimension  (4channels ,   penetration depth   ,  time_range_of_clouds_low_res)
%                                                                     ^- starts at CB

fprintf('Calculate low resolution above CB....');

[ signal_low_res_above_CB_smoothed,  time_rof_clouds_low_res,  cloudbase_inM_low_res ]  = ...
                                                        new_resolution_for_signal_above_CB_fct( signal_smoothed, ...
                                                                                                cloudbase, cloudbase_inM, time_rof_clouds,...
                                                                                                resolution_temporal_depol_mean_above_CB,    CB_var_limit_inM,...
                                                                                                CB_time_var_limit,depth_into_cloud_depol_mean,...
                                                                                                logfile);

% End loop if caculation of low resolution was not successful               % this is probably, due to too few or scattered Cloudbase-Points
if isnan(signal_low_res_above_CB_smoothed)
    fprintf('main: Since Low Resolution could not be calculated, go to next nc-file. (next loop iteration)\n');
    continue;
else
    fprintf('...done\n');
end





%% Calculate depol mean above CB %%%%%%%%%%%%%%%%


fprintf('Calculate integrated depol above CB..by using B..');

[depol_in_mean_above_CB, depol_out_mean_above_CB] = ...
                                                   depol_mean_above_cb_fct_2_0(  signal_low_res_above_CB_smoothed,...
                                                                                    C,Rt_in,Rc_in,...
                                                                                    C_out,Rt_out,Rc_out );         

% Calculate by B_out                                                                                
% [depol_in_mean_above_CB, depol_out_mean_above_CB] = ...
%                                                    depol_mean_above_cb_fct_using_B(  signal_low_res_above_CB_smoothed,...
%                                                                                     C,Rt_in,Rc_in,...
%                                                                                     B_out,Rc_out );         
                                                                                

% Not finished yet ! Implementation of a "CB-Shift for calculation of alpha"
% [depol_in_mean_above_CB_for_alpha] = ...
%                                                    depol_mean_above_cb_August_2_1fct(  signal_low_res_above_CB_smoothed(1,:,:),...
%                                                                                        signal_low_res_above_CB_smoothed(2,:,:),... 
%                                                                                        reduction_of_penetration_depth_for_alpha,...
%                                                                                         C,Rt,Rc);                                                                                  


fprintf('...done\n');


%% Change Resolution of Max Signal%%%%%%%%%%%%%%%%

% fprintf('Resolution changed from 30sec to %d Minutes....',resolution_temporal_depol_mean_above_CB);
% 
% % Max signal
% [max_Mcps_in_cloudrange_low_res(1,:),time_low_res_max_sig_in_bins]  =  change_time_resolution_fct(  max_Mcps_in_cloudrange(1,:),  resolution_temporal_depol_mean_above_CB );
% [max_Mcps_in_cloudrange_low_res(2,:),time_low_res_max_sig_in_bins]  =  change_time_resolution_fct(  max_Mcps_in_cloudrange(2,:),  resolution_temporal_depol_mean_above_CB );
% [max_Mcps_in_cloudrange_low_res(3,:),time_low_res_max_sig_in_bins]  =  change_time_resolution_fct(  max_Mcps_in_cloudrange(3,:),  resolution_temporal_depol_mean_above_CB );
% [max_Mcps_in_cloudrange_low_res(4,:),time_low_res_max_sig_in_bins]  =  change_time_resolution_fct(  max_Mcps_in_cloudrange(4,:),  resolution_temporal_depol_mean_above_CB );
% 
% %   Since the two resolution changing functions do not result in same bin_centers
% %   we have to cheat a little, an change the time of the cloud_max_low_res a little :
% time_rof_max_Mcps_in_cloudrange_res_closest = time_low_res_in_bins(find_closest_index_fct(time_rof_clouds_low_res, time_low_res_max_sig_in_bins));
% 
% fprintf('...done\n');





%% Smoothing and Depolratio %%%%%%%%%%%%%%%%%%%%%%%

% ToDo !!!!!!!!!
%  Ich bin nicht zufrieden mit der Art des Smoothens.
%  Smoothing funktioniert nur halbwegs gut, wenn keine NaNs dazwischen
%  sind. sowohl 'smooth()' als auch 'smoothdata()' kommen jeweils auf ihre
%  Weise nicht zufriedenstellend mit NaNs klar.
% Cristofer umgeht das problem indem er einen Datensatz erstellt in dem
% alle CB-perioden einfach zusammengezogen werden. Das ist aber bei
% entsprechend grossen eigentlich vorhandenen Lueken zwischen den
% CB-perioden recht verfaelschend. 
% To check effect of smoothing siehe Abschnitt   "Plot to show effect of smoothing"

% Ich mache es jetzt trotzdem auch mal so,.. weil ich mich nicht lange
% damit aufhalten will.
% Funktioniert ja gut fuer zusammenhaengende wolkenperioden.


%2 Moeglichkeiten des smoothens.
%           smooth_depol_or_depolratio==0       :   no smoothing is applied
%           smooth_depol_or_depolratio==1       :   depol_in etc wird gesmoothed. Ratio dann aber nicht

if smooth_depol_or_depolratio==0
    fprintf('Smoothing Option 1:No smoothing applied. New variables do nevertheless take the name "depol_in_mean_above_CB_res_smooth_redutime_smooth" etc  ...');
    % Just for renaming, such that for both smoothing-cases same variables can be used afterwards:
    depol_in_mean_above_CB_res_smooth_redutime_smooth       = depol_in_mean_above_CB ;
    depol_out_mean_above_CB_res_smooth_redutime_smooth      = depol_out_mean_above_CB ;
    depolratio_mean_above_CB_res_smooth_redutime_smooth     =  depol_in_mean_above_CB_res_smooth_redutime_smooth   ./   depol_out_mean_above_CB_res_smooth_redutime_smooth;

elseif smooth_depol_or_depolratio==1
    fprintf('Smoothing Option 2:depol_in_mean_above_CB_res_smooth_redutime_smooth (and _out_) smoothed within each %d points ...',smooth_depol_or_depolratio_parameter);
    depol_in_mean_above_CB_res_smooth_redutime_smooth       = smooth (depol_in_mean_above_CB , smooth_depol_or_depolratio_parameter);
    depol_out_mean_above_CB_res_smooth_redutime_smooth      = smooth (depol_out_mean_above_CB, smooth_depol_or_depolratio_parameter);
    depolratio_mean_above_CB_res_smooth_redutime_smooth     =  depol_in_mean_above_CB_res_smooth_redutime_smooth   ./   depol_out_mean_above_CB_res_smooth_redutime_smooth;
        
else
    fprintf(' Error: smooth_depol_or_depolratio    MUST BE 0 or 1  !\n \n');
end

% ?depolratio_mean_above_CB_res_smooth_inCB_range (depolratio_mean_above_CB_res_smooth_inCB_range > 1.05)   =   NaN;                              %   delete non realistic values, or ice clouds
% ?depolratio_mean_above_CB_res_smooth_inCB_range (depolratio_mean_above_CB_res_smooth_inCB_range < 0.3)    =   NaN;


fprintf('...done\n');

   


%%


%% Inversion 
fprintf('Inversion Routine  ...\n');

clear r_eff alpha lwc cdnc
% all variable which come out here are in Reduced-Time (only points when CB is present)
[r_eff, alpha, lwc, cdnc, depolratio_allowed_range_res] = inversion_routine_fct_2_1(depol_in_mean_above_CB_res_smooth_redutime_smooth,  depolratio_mean_above_CB_res_smooth_redutime_smooth,  ...
                                                                                cloudbase_inM_low_res,  ...
                                                                                depth_into_cloud_depol_mean,...
                                                                                simulated_cloudbase_heights,...
                                                                                k_gamma);       

cdnc_in_cm = cdnc.*1000000;     % constant with height
alpha_per_km= alpha.*1000;      % increases z^(2/3) with height 
r_eff_in_microns= r_eff;        % increases z^(1/3) with height
lwc_in_g_per_cubicmeter = lwc;  % increases linearly with height
lwc_dualFOV=lwc;
%
% alpha_per_km_mean = mean(alpha_per_km,2,'omitnan');   % nanmean(matrix,dim,inludeNaN)
% alpha_per_km_std_err  = std(alpha_per_km,0,2,'omitnan') / sqrt(sum(~isnan(alpha_per_km(end,:)))) ;   % nanmean(matrix,normalization,dim,inludeNaN)
% fprintf('mean ( alpha_ref ) = %.2f  +- %.2f   per km\n',alpha_per_km_mean(end), alpha_per_km_std_err(end));
% 
% r_eff_in_microns_mean = mean(r_eff_in_microns,2,'omitnan');   % nanmean(matrix,dim,inludeNaN)
% r_eff_in_microns_std_err  = std(r_eff_in_microns,0,2,'omitnan') / sqrt(sum(~isnan(r_eff_in_microns(end,:)))) ;   % nanmean(matrix,normalization,dim,inludeNaN)
% fprintf('mean ( r_ref ) = %.2f  +- %.2f    microns \n',r_eff_in_microns_mean(end), r_eff_in_microns_std_err(end));
% 
% lwc_in_g_per_cubicmeter_mean = mean(lwc_in_g_per_cubicmeter,2,'omitnan');   % nanmean(matrix,dim,inludeNaN)
% lwc_in_g_per_cubicmeter_std_err  = std(alpha_per_km,0,2,'omitnan') / sqrt(151) ;   % nanmean(matrix,normalization,dim,inludeNaN)
% fprintf('mean ( LWC_ref ) = %.2f  +- %.2f  gramm per cubiccentimeter\n',lwc_in_g_per_cubicmeter_mean(end), lwc_in_g_per_cubicmeter_std_err(end));
% 
% cdnc_in_cm_mean = mean(cdnc_in_cm,2,'omitnan');   % nanmean(matrix,dim,inludeNaN)
% cdnc_in_cm_std_err  = std(cdnc_in_cm,0,2,'omitnan') / sqrt(sum(~isnan(cdnc_in_cm(end,:)))) ;   % nanmean(matrix,normalization,dim,inludeNaN)
% fprintf('mean ( CDNC ) = %.2f  +- %.2f  per cubic centimeters\n',cdnc_in_cm_mean(end), cdnc_in_cm_std_err(end));

fprintf('cloudbase_inM_low_res          = <%.2f> from %.2f to %.2f , standarddev=%.2f\n',nanmean(cloudbase_inM),min(cloudbase_inM),max(cloudbase_inM),nanstd(cloudbase_inM));
fprintf('alpha_per_km (z_ref)            = <%.2f> from %.2f to %.2f , standarddev=%.2f\n',nanmean(alpha_per_km(end,:)),min(alpha_per_km(end,:)),max(alpha_per_km(end,:)),nanstd(alpha_per_km(end,:)));
fprintf('r_eff_in_microns (z_ref)        = <%.2f> from %.2f to %.2f , standarddev=%.2f\n',nanmean(r_eff_in_microns(end,:)),min(r_eff_in_microns (end,:)),max(r_eff_in_microns (end,:)),nanstd(r_eff_in_microns(end,:)));
fprintf('lwc_in_g_per_cubicmeter (z_ref) = <%.2f> from %.2f to %.2f , standarddev=%.2f\n',nanmean(lwc_in_g_per_cubicmeter(end,:)),min(lwc_in_g_per_cubicmeter (end,:)),max(lwc_in_g_per_cubicmeter (end,:)),nanstd(lwc_in_g_per_cubicmeter(end,:)));
fprintf('cdnc_in_cm                      = <%.2f> from %.2f to %.2f , standarddev=%.2f\n',nanmean(cdnc_in_cm(end,:)),min(cdnc_in_cm (end,:)),max(cdnc_in_cm (end,:)),nanstd(cdnc_in_cm(end,:)));

fprintf('                       ...done\n');
%%

%% Find Max Mcps above CB
fprintf('Find Max Mcps above CB  ...');
[Mcps_above_CB_in_cloudrange, max_Mcps_above_CB_in_cloudrange]  = find_max_above_CB_fct_2(raw_signal_Mcps, cloudbase, time_rof_clouds, depth_into_cloud_depol_mean);
fprintf('                       ...done\n');                         
                                




%% Statistical Analysis of Inversion Success Rate
% [success_depol_ratio_in_range, cloud_bin_matrix] = statistical_analysis_inversion_success_fct(cloudbase_inM_low_res,...
%                                                                    depolratio_mean_above_CB_res_smooth_redutime_smooth, depolratio_allowed_range_res,...
%                                                                    time_rof_clouds_low_res,...
%                                                                    height_bin_edges);
%                 

%% Store Data for more-then-one-file analysis
file_number(ff).name                                        = InputFiles_lidar{ff};

file.number(ff).measurement_time_num                        = measurement_time_num;
file.number(ff).time_rof_clouds                             = time_rof_clouds;
file_number(ff).max_Mcps_above_CB_in_cloudrange             = max_Mcps_above_CB_in_cloudrange ;

file_number(ff).time_rof_clouds_low_res                     = time_rof_clouds_low_res ;
file_number(ff).cloudbase_inM_low_res                       = cloudbase_inM_low_res ;

file_number(ff).depol_in_mean_above_CB_res_smooth_redutime_smooth   = depol_in_mean_above_CB_res_smooth_redutime_smooth ;
file_number(ff).depol_out_mean_above_CB_res_smooth_redutime_smooth  = depol_out_mean_above_CB_res_smooth_redutime_smooth ;
file_number(ff).depolratio_mean_above_CB_res_smooth_redutime_smooth = depolratio_mean_above_CB_res_smooth_redutime_smooth ;
file_number(ff).depolratio_allowed_range_res                = depolratio_allowed_range_res;

file_number(ff).C                                           = C;
file_number(ff).C_out                                       = C_out;
                                                                                

% makeplots_depol_inversion_analysis;
% makeplots_depol_inversion_analysis_arielle_case;


%% Save all open figures in one single .fig file
% if save_all_open_figures_each_loop ==1
%     figHandles = findall(0, 'Type', 'figure');      % find all open figures
%     savefig(figHandles,strcat(result_path,InputFiles_lidar{ff},'.fig'));       %saves a .fig file with the name of the nc file .  % if error here, maybe no figure was open :-)
%     end




end    %ff-loop
fprintf('\n---------------------------------------------------------\n Great loop finished.\n---------------------------------------------------------\n');






%% Save all
% clear all variables which might be leftover from last loop or program run
%       this is not a complete list of all variables. some variables get
%       cleared elswhere to free memory, after they are not needed any more
% clearvars('-except',InitialVariableNames{:}, 'ff' , 'last_file_with_calibration' , 'C_Mcps_bc_rc' , 'C', 'file_number' );

datestring = datestr(now,'yyyy_mm_dd HH_MM_SS');

%% Uncomment for saving results.
save(strcat(result_path,'results_',InputFiles_lidar{ff},'.mat'),'file_number');


%%
fprintf('Saved results to    ---> %s  results_%s.mat \n',result_path,InputFiles_lidar{ff});



% %%  Use this to save global parameters to mat file                                  if uncommented, all variables besides global variables are delted
% 
%  clearvars('-except',InitialVariableNames{:},'ff');
%  save(strcat(result_path,'global parameters_',InputFiles_lidar{ff}(1:end-3),'.mat'));

%%

disp('FINISH');
toc
return;















