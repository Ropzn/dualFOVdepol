%% 'Global' Parameters for Arielle Case
fprintf('Initial Parameters loaded for Lacros Punta Arenas CASE !!     ----   by    ------   global_parameters_punta_case.m  \n\n');

depol_cal_angle_threshold   = 22;                                           % muss je nach System eingestellt werden. Er gibt den Threshold an, fuer den davon ausgegangen wird, dass waehrend einer messung gerade kalibriert wurde.Dafuer einfach mal die Variable depol_cal_angle anschauen und gucken, wo der Wert wie springt.
bin_height                  = 7.5;                                          % One height bin corresponds to 7.5m

% Lacros o Arielle?
%   Changes deadtimepolynomial
%   1  = lacros 
%   else   = other /
lacros_or_arielle = 0;



%         Tadjikistan:
%         Rt = 1.05    , Rc= 1666  ,  Rt_out = 1 , Rc_out = 250
% 
%         Lacros bis 10.August 2019.
%         Rt = 1.02    , Rc= 400  ,  Rt_out = 1 , Rc_out = 500
% 
%         Lacros ab 10.August 2019.
%         Rt = 1.02    , Rc= 200  ,  Rt_out = 1 , Rc_out = 500    
% 
%         Lacros Cristofers programm:
%         Rt = 1.09    , Rc= 800  ,  Rt_out = 1 , Rc_out = 501
% 
%         Arielle
%         Rt = 1.09    , Rc= 500  ,  Rt_out = 1 , Rc_out = 500 



Rt_in                       = 1.02;                                          % For Calibration needed inner FOV (but through C also effects outer FOV calibration)
Rc_in                       = 200; %for later than Aug 2019                  % For Calibration needed inner FOV (but through C also effects outer FOV calibration)
Rt_out                      = 1;
Rc_out                      = 500;                                         

fprintf(" ----------------------------------------------------------\n Rt_in= %.3f   ,  Rc_in=%d    ,  Rt_out=%d    , Rc_out=%d    \n ----------------------------------------------------------\n",Rt_in  ,  Rc_in ,  Rt_out   , Rc_out );                                                               
  

% Deadtime polynomials for new channel  -- only for lacros                   --- set in loop search for "LACROS: Deadtime polynomial for Channel 13 set manually" % no need for commenting here
%   First fit (Cristofer says he uses that one]  
deadtime_polynomial_lacros=[0 1.0028322 -4.348923e-5 5.6878312e-5 -7.0852014e-7 4.0058806e-9 ];             %f�r lacros %f�r den neuen kanal fehlen daten noch im netcdf, daher manuell
%   From combo formula (seem closer to other deadtime polynomial..)
%       deadtime_polynomial_lacros=[0 1.0000082 0.00084184853 1.1367669e-5 1.2462946e-8 5.1644135e-10 ];



rangocanales                    = [5 6 9 13];                                   % channels needed: 5=532 6=532c, 9=532out, 13=532c_out,  (8=1064, 3=387, 4=407, 1=355)
pretrigger                      = 251;                                          % 251 defines the bin at 7.5m over ground.
maxheight                       = 3600;%933;                                          % Defines the max height for the profiles 933*7,5m= 10km
BG_rof_height                   = 3000:3300;                                    % Take from heights [5500..6000]*7.5m ~ [41km..45km]

% inner FOV
depol_cal_rof_height            = 50:250;                                       % 300m-1500m  Defines the height within which depol calibration constant is calculated from, do not set below full overlap?

% outer FOV
depol_out_cal_rof_height        = 266:346;                                       %if simple depol_const_out_fct is used 80:180;  60:180??             % This is the range which will be averaged 60:300= 450m-2250m   ( also confines range if depol_const_out_fct is used )
% depol_out_cal_range_below_cloud = 2:132;                                        % This gives the bins which are used by depol_const_out_fct.  CB-2:CB-133   ->1km(133bins) below CB
time_rof_calibration_out        = 660:900;                    % currently  set dynamically inside the loop as full time size   

height_rof_cloudsearch          = 130:800;                                      % 1-5 km  heightrange (bins) for cloud search
depth_into_cloud_depol_mean     = 12;                                           % How many height bins to average for the depol_mean_above_CB
reduction_of_penetration_depth_for_alpha  = 1;

resolution_temporal_depol_mean_above_CB = 3;                                    % The new resolution in minutes to be worked with, for smoother values
CB_time_var_limit               =(2 * resolution_temporal_depol_mean_above_CB + 2);  % This is the maximum timedifference which should be between first and last point of the interval which is meaned for lower resolution
CB_var_limit_inM                = 300;                                          % The maximum difference which is allowed between to adjacent cb_points within one new_resolution_intervall.


k_gamma                         = 0.8;                                          % 0.75 (for clouds formed around continental airmasses), 0.8 (marine environments). Miles et. al (2000)


%Smoothing parameters:
% ' ' ' ' ' ' ' ' ' ' 

%   To smooth signal before just before range-correction
%       gives "signal_smoothed"
%           - which is used for the cloud search
%           - and used for calculation of C_out
smooth_parameter_sig = 7 ;         

%   To smooth signal before calculating depol_mean  (in and out) 
%       This is used for the 2-Plots of depol in, out and ratio
%       This is not used for the inversion
smooth_parameter_depol_mean = 10;

% 2 Moeglichkeiten des smoothens.
%           smooth_depol_or_depolratio==0       :   no smoothing is applied
%           smooth_depol_or_depolratio==1       :   depol_in etc wird gesmoothed. Ratio dann aber nicht
smooth_depol_or_depolratio              = 1;
smooth_depol_or_depolratio_parameter    = 3;                               % Smooth parameter, which is used for smoothing depol(or depolratio). defines the window-size of a running average procedure.



% Parameters defined by the simulation
simulated_cloudbase_heights=[1000 1500 2000 2500 3000 3500 4000 5000];

% Height bins for statistical analysis
height_bin_edges = [750:250:4500];        


% debug_time    = 10:700; %  --> important comment --v                      % The time bins which are used. Main purpose -> faster program for debbuging
%      comment out this line: "debug_time=1:size(raw_signal,3);"  if debug_time should be used as defined here

% Program-Switch for Data path                                              (only for linuxenviroment)
lidardatenserver    =0;                                                     % 1=directory for lidardaten-server is set, else=directory for robz notebook is set

% Program-Switches for different parts of the program
save_all_plots                  = 1;                                                    % 1=on, else off, all plots which are set 1 above get saved as jpg
save_all_open_figures_each_loop = 0;
delete_all_open_figures_each_loop =1;

% Parameters for Plots 2D Profiles
time_rof_profile_in_bins    = 720:732;      % currently  set dynamically inside the loop as full time size                  % Time-range of the profile (unit:bins) , One bin is 30sec
time_rof_profile_in_bins    = 725:730;
height_rof_profile_in_bins  = 1:933;                                        % Height-range of the profile (unit:bins), one bin is 7,5m  . 251 sind die bins die wegen des pretriggers rausgerechnet werden müssen. 933=6km
disp('Parameters set.');

%% Paths and Files
% Selects automatically different paths for linux and windows
path(path,'C:\Robert\Master\Daten\LookUpTables\ArielleLacros\')
lookup_table_path='C:\Robert\Master\Daten\LookUpTables\ArielleLacros\';

data_path='C:\Robert\Master\Daten\Lacros\2020_sept\';
result_path='C:\Robert\Master\Software\ND-Filter\results\lacros\2020_sept\';

disp('Windows Path is used');

disp(data_path);
disp(result_path);


%%% input data  %liste mit allen dateien die ausgewertet werden sollen
InputFiles_lidar=textread('NC_files_lacros_punta_sept_2020.txt','%s','delimiter','\n'); 

disp(InputFiles_lidar);

%% Logfile
logfile = fopen(fullfile(result_path, 'LogFile.txt'), 'w');                                     %Open Logfile in write-mode,s.t. content is deleted
fclose(logfile);
logfile = fopen(fullfile(result_path, 'LogFile.txt'), 'at');                                    %Open Logfile in append-mode and text-mode. the latter is relevant for \n to work


%% Find all initial Variables which should not be deleted
InitialVariableNames=1;   %this line HAS to stay !!                                             % If this line is deleted the variable which holds the list of all initial variable is not in the list itself ... hence it gets deleted at the end of the first loop iteration                          
InitialVariableNames=who;


fprintf('Initial Parameters loaded for Lacros Punta Arenas CASE !!  After August 2019 !!-Parameters    ----   by    ------   global_parameters_punta_case.m  \n\n');



