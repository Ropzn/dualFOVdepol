
%% Program Description
%




%%  Vorbereitungen

% if "clear all" is used, then Breakpoints are cleared as well and will not work
clear all
%close all
clc



%% 'Global' Parameters
depol_cal_angle_threshold   = 22;                                           % muss je nach System eingestellt werden. Er gibt den Threshold an, fuer den davon ausgegangen wird, dass waehrend einer messung gerade kalibriert wurde.Dafuer einfach mal die Variable depol_cal_angle anschauen und gucken, wo der Wert wie springt.
bin_height                  = 7.5;                                          % One height bin corresponds to 7.5m

% Lacros o Arielle?
%   Changes deadtimepolynomial, result path, data path
%   1  = lacros 
%   else   = Arielle
lacros_or_arielle = 0;

%         Tadjikistan:
%         Rt = 1.05    , Rc= 1666  ,  Rt_out = 1 , Rc_out = 80
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



Rt_in                       = 1.09;                                          % For Calibration needed inner FOV (but through C also effects outer FOV calibration)
Rc_in                       = 500;                                           % For Calibration needed inner FOV (but through C also effects outer FOV calibration)
%epsilon                    = 1.002;                                        % cross-talk FOV out, 1.005 +/- 0.002
Rt_out                      = 1;
Rc_out                      = 500;                                         


fprintf(" ----------------------------------------------------\n Rt_in= %.3f   ,  Rc_in=%d    ,  Rt_out=%d    , Rc_out=%d    \n --------------------------------------\n",Rt_in  ,  Rc_in ,  Rt_out   , Rc_out );                                                               
  

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
depol_out_cal_rof_height        = 100:200;                                       %if simple depol_const_out_fct is used 80:180;  60:180??             % This is the range which will be averaged 60:300= 450m-2250m   ( also confines range if depol_const_out_fct is used )
depol_out_cal_range_below_cloud = 2:132;                                        % This gives the bins which are used by depol_const_out_fct.  CB-2:CB-133   ->1km(133bins) below CB
% time_rof_calibration_out        = 1:720;                    % currently  set dynamically inside the loop as full time size   

height_rof_cloudsearch          = 134:666;                                      % 1-5 km  heightrange (bins) for cloud search
depth_into_cloud_depol_mean     = 12;                                           % How many height bins to average for the depol_mean_above_CB
desface_height_depol_mean       = 3;                                            % shift from Cloudbase, "underestimated by smoothing" ..?
resolution_temporal_depol_mean_above_CB = 3;                                    % The new resolution in minutes to be worked with, for smoother values
CB_var_limit_inM                = 300;                                          % The maximum difference which is allowed between to adjacent cb_points within one new_resolution_intervall.

k_gamma                         = 0.8;                                          % 0.75 (for clouds formed around continental airmasses), 0.8 (marine environments). Miles et. al (2000)

% 3 Moeglichkeiten des smoothens.
%           smooth_depol_or_depolratio==0       :   no smoothing is applied
%           smooth_depol_or_depolratio==1       :   depol_in etc wird gesmoothed. Ratio dann aber nicht
%           smooth_depol_or_depolratio==2       :   depol_in etc wird Nicht gesmoothed. Ratio wird gesmoothed
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
colorplot_signal                = 0;                                                    % 1=on, else off
plot_signal_mean                = 0;                                                    % 1=on, else off
plot_signal_and_cb              = 0;
plot_depol_2d_and_ratio_mean    = 0;
plot_to_show_effect_of_smoothing= 0;
plot_inversion_results          = 0;
plot_inversion_success_analysis = 0;
save_all_plots                  = 0;                                                    % 1=on, else off, all plots which are set 1 above get saved as jpg
save_all_open_figures_each_loop = 0;
delete_all_open_figures_each_loop =0;

% Parameters for Plots 2D Profiles
% time_rof_profile_in_bins    = 1:720;      % currently  set dynamically inside the loop as full time size                  % Time-range of the profile (unit:bins) , One bin is 30sec
height_rof_profile_in_bins  = 1:933;                                        % Height-range of the profile (unit:bins), one bin is 7,5m  . 251 sind die bins die wegen des pretriggers rausgerechnet werden müssen. 933=6km
disp('Parameters set.');

%% Paths and Files
% Selects automatically different paths for linux and windows
if (isunix)
    if (lidardatenserver == 1)
        path(path,'/home/wiesen/Software/DFOV Auswertung Cristofer 4.4.19/data/');
        data_path='/home/wiesen/Daten/Arielle/Melpitz 2019-03 bis 2019-tbc/';
        %data_path='/home/wiesen/Software/DFOV Auswertung Cristofer 4.4.19/data/';
        result_path='/home/wiesen/Software/ND-Filter/results/';
        disp('Linux Path on lidardaten-server is used');
        disp('Please check if all paths are up to date, and then remove the "return" next to this comment in the code');
        return;
    else
        %path(path,'/media/Daten/RobertosDats/Uni/Master/Software/DFOV Auswertung Cristofer 4.4.19/data/');
        path(path,'/media/Daten/RobertosDats/Uni/Master/Daten/LookUpTables/ArielleLacros/');
        data_path='/media/Daten/RobertosDats/Uni/Master/Daten/Lacros/';
        result_path='/media/Daten/RobertosDats/Uni/Master/Software/ND-Filter/results/lacros/';
        disp('Linux Path on robz notebook is used');
    end
elseif (ispc)
    path(path,'C:\Robert\Master\Daten\LookUpTables\ArielleLacros\')
    
    if lacros_or_arielle==1
        result_path='C:\Robert\Master\Software\ND-Filter\results\lacros\';
        data_path='C:\Robert\Master\Daten\Lacros\Messungen_polly_lacros\';
    else
        result_path='C:\Robert\Master\Software\ND-Filter\results\arielle\';
        data_path='C:\Robert\Master\Daten\Arielle\mosaic\';
    end
    
    disp('Windows Path is used');
elseif (ismac)
    disp('Please Define Path which should be used on Mac. this message comes from the Roberts sourcecode. ');
else
    disp('Platform not supported, this message comes from the Roberts sourcecode');
end

disp(result_path);

%%% input data  %liste mit allen dateien die ausgewertet werden sollen
InputFiles_lidar=textread('NC_files_arielle_mosaic_cr_vorschl.txt','%s','delimiter','\n'); 

% InputFiles_lidar=textread('NC_files_lacros_2019-03-22.txt','%s','delimiter','\n');     
 
%  InputFiles_lidar=textread('InputFiles_inversion_march_to_may_2019.txt','%s','delimiter','\n');   

%  InputFiles_lidar=textread('NC_files_lacros_cloudfree.txt','%s','delimiter','\n');         
 
%   InputFiles_lidar=textread('NC_files_arielle_melpitz_nice_clouds_2019.txt','%s','delimiter','\n');  

%  InputFiles_lidar=textread('NC_files_arielle_melpitz_cloudfree_2019.txt','%s','delimiter','\n');                       


disp(InputFiles_lidar);

%% Logfile
logfile = fopen(fullfile(result_path, 'LogFile.txt'), 'w');                                     %Open Logfile in write-mode,s.t. content is deleted
fclose(logfile);
logfile = fopen(fullfile(result_path, 'LogFile.txt'), 'at');                                    %Open Logfile in append-mode and text-mode. the latter is relevant for \n to work


%% Find all initial Variables which should not be deleted
InitialVariableNames=1;   %this line HAS to stay !!                                             % If this line is deleted the variable which holds the list of all initial variable is not in the list itself ... hence it gets deleted at the end of the first loop iteration                          
InitialVariableNames=who;


disp('Initial Parameters loaded');







%% The Great Loop
for ff=7%:length(InputFiles_lidar)                                           % 1 loopdurchgang pro file
disp('paeusken');
%hitkey=input("hit return to continue");

% clear all variables which might be leftover from last loop or program run
%       this is not a complete list of all variables. some variables get
%       cleared elswhere to free memory, after they are not needed any more
clearvars('-except',InitialVariableNames{:}, 'ff' , 'last_file_with_calibration' , 'C_Mcps_bc_rc' , 'C_dc_bc_rc', 'file_number' );

if delete_all_open_figures_each_loop==1
    close all;
end
    
    
    
    
%% NetCDF einladen
fprintf('\n-------------\n Loop %d ::: Processing %s --------------\n',ff,InputFiles_lidar{ff});
fprintf(logfile,'\n%s ::: Loop %d ::: Processing %s ------------\n',datestr(now,'dd.mmmm yyyy HH:MM:SS'),ff,InputFiles_lidar{ff});


%%%%%%%%%%%%%% Daten einlesen und vorbereiten %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get data from NetCDF--
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
disp('netcdf done');

% For Lacros set deadtime Polynomial manuell
if lacros_or_arielle==1
    deadtime_polynomial(13,:)=deadtime_polynomial_lacros;               %for new channel of lacros since data is missing in netcdf, daher manuell
    disp('LACROS: Deadtime polynomial for Channel 13 set manually');
else
    disp('Deadtime is used from NC file --- for arielle');
end




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

time_rof_calibration_out = 1:size(raw_signal,3);                          %just to make sure it has full length, if shorter length is wanted, delete this line and see definition before loop
time_rof_profile_in_bins = 1:size(raw_signal,3);                    %just to make sure it has full length, if shorter length is wanted, delete this line and see definition before loop

time_rof_calibration_out        = 300:600;




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
%%% Umrechnung von raw_signal in Mcps pro Höhenbin pro Schuss ist also:
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
    % bsxfun(@rdivide,Matrix,Vector)  Divides Matrix Elementwise by a vector.    In MATLAB® R2016b and later one could use simply Matrix./Vector
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


%%%%% Deadtimecorrection %%%%  ( _dc = deadtime-corrected  )
for j=1:length(rangocanales)                                                                       % for all channels
    signal_dc(j,:,:)=polyval(deadtime_polynomial(j,:),raw_signal_Mcps(j,:,:));                      % deadtime correction for all signals
    BG_dc(j,:,:)=polyval(deadtime_polynomial(j,:),BG_raw_Mcps(j,:,:));                              % the same for Backgroundsignal  % probably not neccessary due to low count-rates...
%     BG_dc(j,:,:)=BG_raw_Mcps(j,:,:);
end

disp('Deadtimecorrection done');





%% Background and range correction
%%%%% Background + range correction %%%% (bc=background corrected) (rc=range corrected)

% extract mean of Background signal for each time bin
mean_BG_raw_Mcps(:,:)   =nanmean(BG_raw_Mcps,2);                                                    % BG(Channel,Time)  % mean along array dimension 2 (=height)
mean_BG_dc(:,:)         =nanmean(BG_dc,2);                                                          % background signals WITH deadtime correction

height = (bin_height:bin_height:bin_height*length(signal_dc(1,:,1)))';                                                   % Create a Column vector with bins in meter .
height_sqare = (height.*height)';


%  Background + range correction   (Takes 1minute CPU at Robs Laptop)                               % corrected_signal = ( signal - background ) * height²
for j=1:length(rangocanales)
    for i=1:size(raw_signal_Mcps,3)                                                                 % go through all time bins.  size(raw_signal_Mcps,3) gives the no of elements along 3rd dimension which is the time bins
        signal_Mcps_bc_rc(j,:,i) = (raw_signal_Mcps(j,:,i) - mean_BG_raw_Mcps(j,i)).*height_sqare;  % signal without deadtime correction (bc=background corrected) (rc=range corrected)
        signal_dc_bc_rc(j,:,i)   =    (signal_dc(j,:,i)    -   mean_BG_dc(j,i))    .*height_sqare;  % signal WITH deadtimecorrection and (bc=background corrected) (rc=range corrected)
        % If sig~0 then negative values are introduced by BC, delete these ones
%         signal_Mcps_bc_rc(signal_Mcps_bc_rc<=0)=NaN;  Das ist FALSCH,denn dadurch wird ein Gewicht in die Daten eingebaut !!!
%         signal_dc_bc_rc(signal_dc_bc_rc<=0)=NaN;      Das ist FALSCH,denn dadurch wird ein Gewicht in die Daten eingebaut !!!
    end
end

% NaN all negative Values - is this statistically ok????????? or does it introduce a bias.#statfrage
% signal_dc_bc_rc(signal_dc_bc_rc<0)=NaN;
% signal_Mcps_bc_rc(signal_Mcps_bc_rc<0)=NaN;



%clear raw_signal_Mcps;

disp('Background + range correction - done');



%%  Colorplots mit Hoehe vs Zeit (3Dim) unkalibriertes signal%%%%%%%%%%%%%%%
if (colorplot_signal==1)
    % Nur Mcps (ohne RC,BC,DC)
%     plot_color_4ch_fct(raw_signal_Mcps,'raw_signal_Mcps',save_all_plots,InputFiles_lidar{ff},result_path);
    
    % Without deadtime (mit RC,BC, ohne DC)
    plot_color_4ch_fct(signal_Mcps_bc_rc,'signal_Mcps_bc_rc',save_all_plots,InputFiles_lidar{ff},result_path);
    
%     % WITH deadtime (DC,BC,RC)
%     plot_color_4ch_fct(signal_dc_bc_rc,'signal_dc_bc_rc',save_all_plots,InputFiles_lidar{ff},result_path);
%     
    disp('Color Plots - done');
    
end



%% Profil-Plots fuer Zeitausschnitt (2Dim) %%%%%%%%%%%%%%%%%%%%%%%
if (plot_signal_mean==1)
    
    %%%% (Time)Mean of Backgr.- and Rangecorrected signal
    % Without deadtime
    meano_time_signal_bc_rc = nanmean(signal_Mcps_bc_rc(:,height_rof_profile_in_bins,time_rof_profile_in_bins),3);
    % WITH deadtime
    meano_time_signal_dc_bc_rc = nanmean(signal_dc_bc_rc(:,height_rof_profile_in_bins,time_rof_profile_in_bins),3);
    % Plot the 2 signals
    plot_profile_mean_fct(meano_time_signal_bc_rc,meano_time_signal_dc_bc_rc,' sig_bc_rc , sig_dc_bc_rc',time_rof_profile_in_bins,save_all_plots,InputFiles_lidar{ff},result_path);
    
    disp('Profile Plots done');
end



%% Extract data during calibration - and NaN data during calibration in signal
% Extract data during calibration
time_rof_calibration    =   find(depol_cal_angle>depol_cal_angle_threshold);                                   % rangotc gibt den (Zeit)Bereich an, in welchem Calibriert wurde. Hier muss je nach System ein threshold eingestellt werden, damit die Werte waehrend der Kalibrierung (alle paar stunden) rausgefiltert werden.Dafuer einfach mal die Variable depol_cal_angle anschauen und gucken, wo der Wert wie springt
signal_during_calibration_Mcps_bc_rc = signal_Mcps_bc_rc(:,:,time_rof_calibration);
signal_during_calibration_dc_bc_rc = signal_dc_bc_rc(:,:,time_rof_calibration);

disp('Extract data during calibration   ... done.');



%% Depol Calibration of inner FOV %%%%%%%%%%%%
%%%%%% Check if Calibration is available
if length(time_rof_calibration)>1
    last_file_with_calibration=InputFiles_lidar{ff};
    
    %%% NaN the TimeRange of Calibration(+-1) for all Channels
    %           --> so that it is not used for colorplots and further calculation
    % Without deadtime
    signal_Mcps_bc_rc(:,:,(time_rof_calibration(1)-1):(time_rof_calibration(end)+1)) = NaN;
    % WITH deadtime
    signal_dc_bc_rc(:,:,(time_rof_calibration(1)-1):(time_rof_calibration(end)+1)) = NaN;
    disp('NaN data during calibration in signal ... done.');

    
    %%% Calculate Calibration Constant Inner FOV
    % Without deadtime
    C_Mcps_bc_rc    = depol_const_inner_fct(signal_during_calibration_Mcps_bc_rc(1,:,:),signal_during_calibration_Mcps_bc_rc(2,:,:),depol_cal_rof_height,Rt_in,Rc_in);       % Calculate Calibration Constant
    % WITH deadtime
    C_dc_bc_rc      = depol_const_inner_fct(signal_during_calibration_dc_bc_rc(1,:,:),signal_during_calibration_dc_bc_rc(2,:,:),depol_cal_rof_height,Rt_in,Rc_in);       % Calculate Calibration Constant
    
    
    disp('Calibration constant inner FOV done');
    
elseif exist('last_file_with_calibration','var')==1                                                     % Wenn Calibrierung aus vorigem Loopdurchlauf vorhanden, dann nutze diese
    fprintf('\n........No calibration time found.Used calibration of %s\n',last_file_with_calibration);
    fprintf(logfile,' -->No calibration time found.Used calibration of %s\n',last_file_with_calibration);
    
    % next 2 lines are computationally non-sense. just to show,that values from last loop are used
    C_Mcps_bc_rc     = C_Mcps_bc_rc ;
    C_dc_bc_rc       = C_dc_bc_rc;
    
else                                                                                                % Wenn keine Calibrierung aus vorigem Loopdurchlauf vorhanden, dann springe zum Loop mit naechster Datei
    fprintf('\n........No calibration time found.No earlier calibration available\n');
    fprintf(logfile,' -->No calibration time found.No earlier calibration available\n');
    %continue;                                                                                       % continues to next loop iteration ff=..  . has to commented out if the codeblock is not used in the loop.
end



%% Find cloudbase %%%%%%%%%%%%%%%%%%%


%%% Without deadtime ---------------
[cloudbase_Mcps_bc_rc, time_rof_clouds_Mcps_bc_rc]    =   find_cloud_base_fct (signal_Mcps_bc_rc(1,:,:),height_rof_cloudsearch,InputFiles_lidar{ff},logfile);

%%% WITH deadtime -------------------
[cloudbase_dc_bc_rc, time_rof_clouds_dc_bc_rc]    =   find_cloud_base_fct (signal_dc_bc_rc(1,:,:),height_rof_cloudsearch,InputFiles_lidar{ff},logfile);

cloudbase_inM_Mcps_bc_rc    =   cloudbase_Mcps_bc_rc * bin_height;                                      % Stores the Cloudbase in Meters
cloudbase_inM_dc_bc_rc      =   cloudbase_dc_bc_rc * bin_height;                                        % Stores the Cloudbase in Meters

disp('Cloudbase search done.');
if isequal(time_rof_clouds_Mcps_bc_rc,time_rof_clouds_dc_bc_rc)
    disp('       .... time_rof_clouds_Mcps_bc_rc = time_rof_clouds_dc_bc_rc ')
else
    disp('       .... time_rof_clouds_Mcps_bc_rc  NotEqual  time_rof_clouds_dc_bc_rc ')
end


%% Plot 3d signal with cloudbase line
if plot_signal_and_cb == 1
    plot_color_3dSignal_plus_2dCloudbase_fct(signal_Mcps_bc_rc(1,:,:),cloudbase_Mcps_bc_rc,'signal McpsBcRc total_{in}',save_all_plots,InputFiles_lidar{ff},result_path);
    plot_color_3dSignal_plus_2dCloudbase_fct(signal_dc_bc_rc(1,:,:),  cloudbase_dc_bc_rc,  'signal DcBcRc total_{in}',  save_all_plots,InputFiles_lidar{ff},result_path);
end


%% Relative calibration of outer FOV  %%%%%%%%%%%%%%%%%%%
%       based on   d_in=d_out , below CB
%           Height range:   dynamic (1km below cb & inside ..cal_rof_height)
%           Meaning:        Average is taken when ratio and volume-depol are used in formula for B.
%                           MEDIAN is used (instead of mean)

% Without deadtime
C_out_Mcps_bc_rc =    depol_const_out_fct(signal_Mcps_bc_rc,  cloudbase_Mcps_bc_rc,  time_rof_calibration_out,  depol_out_cal_rof_height,  C_Mcps_bc_rc, Rt_in,Rc_in, Rt_out,Rc_out);
% WITH deadtime
C_out_dc_bc_rc =    depol_const_out_fct(signal_dc_bc_rc,  cloudbase_dc_bc_rc,  time_rof_calibration_out,  depol_out_cal_rof_height,  C_dc_bc_rc, Rt_in,Rc_in, Rt_out,Rc_out);

disp('Relative calibration of outer FOV done.');





%% Depol and ratio (range and time 5resolved)  (3Dim) %%%%%%%%%%%%%%%%%

%%% Without deadtime ---------------
% Calculate Calibrated Depol of inner FOV  (time resolved)
depol_in_Mcps_bc_rc = depol_fct(signal_Mcps_bc_rc(1,:,:),signal_Mcps_bc_rc(2,:,:),C_Mcps_bc_rc,Rt_in,Rc_in); % wird zurzeit nicht zum weiterrechnben benutzt, aber geplottet

% Calculate Calibrated Depol of outer FOV  (time resolved)
depol_out_Mcps_bc_rc = depol_fct(signal_Mcps_bc_rc(3,:,:),signal_Mcps_bc_rc(4,:,:),C_out_Mcps_bc_rc,Rt_out,Rc_out);% wird zurzeit nicht zum weiterrechnben benutzt, aber geplottet

% Ratio: Depol_in / Depol_out (time resolved)
% ratio_depol_inout_Mcps_bc_rc = depol_in_Mcps_bc_rc ./ depol_out_Mcps_bc_rc;


%%% WITH deadtime -------------------
% Calculate Calibrated Depol of inner FOV  (time resolved)
depol_in_dc_bc_rc = depol_fct(signal_dc_bc_rc(1,:,:),signal_dc_bc_rc(2,:,:),C_dc_bc_rc,Rt_in,Rc_in);

% Calculate Calibrated Depol of outer FOV  (time resolved)  
depol_out_dc_bc_rc = depol_fct(signal_dc_bc_rc(3,:,:),signal_dc_bc_rc(4,:,:),C_out_dc_bc_rc,Rt_out,Rc_out);

% Ratio: Depol_in / Depol_out (time resolved)
% ratio_depol_inout_dc_bc_rc = depol_in_dc_bc_rc ./ depol_out_dc_bc_rc;


disp('mom')
%%
depol_in_dc_bc_rc(depol_in_dc_bc_rc<0)=NaN;
depol_in_dc_bc_rc(depol_in_dc_bc_rc>1)=NaN;

disp('Depol (range and time resolved) done');



%% Mean(over time)Depol and Ratio( only range resolved) (2Dim) %%  and plot %%%%%%%%%%%%%%
    %%% Without deadtime ---------------
    % Calculate Calibrated Depol of Mean(over time) inner FOV
    depol_in_mean_Mcps_bc_rc = depol_fct( nanmean(signal_Mcps_bc_rc(1,height_rof_profile_in_bins,time_rof_profile_in_bins),3),...
                                                nanmean(signal_Mcps_bc_rc(2,height_rof_profile_in_bins,time_rof_profile_in_bins),3),...
                                                C_Mcps_bc_rc,Rt_in,Rc_in);
    
    
    
    % Calculate Calibrated Depol of Mean(over time) outer FOV
    depol_out_mean_Mcps_bc_rc = depol_fct(  nanmean(signal_Mcps_bc_rc(3,height_rof_profile_in_bins,time_rof_profile_in_bins),3),...
                                                nanmean(signal_Mcps_bc_rc(4,height_rof_profile_in_bins,time_rof_profile_in_bins),3),...
                                                C_out_Mcps_bc_rc,Rt_out,Rc_out);
    
    % Ratio of Mean(over time): Depol_in / Depol_out
    ratio_depol_mean_inout_Mcps_bc_rc = depol_in_mean_Mcps_bc_rc ./ depol_out_mean_Mcps_bc_rc;
    
    
    %%% WITH deadtime -------------------
    % Calculate Calibrated Depol of Mean(over time) inner FOV
    depol_in_mean_dc_bc_rc = depol_fct(   nanmean(signal_dc_bc_rc(1,height_rof_profile_in_bins,time_rof_profile_in_bins),3),...
                                                nanmean(signal_dc_bc_rc(2,height_rof_profile_in_bins,time_rof_profile_in_bins),3),...
                                                C_dc_bc_rc,Rt_in,Rc_in);
    
    % Calculate Calibrated Depol of Mean(over time) outer FOV
    depol_out_mean_dc_bc_rc = depol_fct(    nanmean(signal_dc_bc_rc(3,height_rof_profile_in_bins,time_rof_profile_in_bins),3),...
                                                nanmean(signal_dc_bc_rc(4,height_rof_profile_in_bins,time_rof_profile_in_bins),3),...
                                                C_out_dc_bc_rc,Rt_out,Rc_out);
    
    % Ratio of Mean(over time): Depol_in / Depol_out
    ratio_depol_mean_inout_dc_bc_rc = depol_in_mean_dc_bc_rc ./ depol_out_mean_dc_bc_rc;
    
if plot_depol_2d_and_ratio_mean==1 
    
    %%% Plot the two depols and ratio of (without DC) and (with DC) --------
    plot_depol_mean_fct(depol_in_mean_Mcps_bc_rc , depol_out_mean_Mcps_bc_rc , ratio_depol_mean_inout_Mcps_bc_rc ,...
                        depol_in_mean_dc_bc_rc , depol_out_mean_dc_bc_rc , ratio_depol_mean_inout_dc_bc_rc , ...
                        'Mcps_bc_rc and dc_bc_rc',time_rof_profile_in_bins,save_all_plots,InputFiles_lidar{ff},result_path)

    %%% Plot ratios of the Non-Deadtimecorrected and Deadtimecorrected signals and depols and depolratio
%     plot_ratios_for_deadtime_correction_effect_fct(signal_Mcps_bc_rc,...
%                                                         signal_dc_bc_rc,...
%                                                         depol_in_mean_Mcps_bc_rc,...
%                                                         depol_out_mean_Mcps_bc_rc,...
%                                                         depol_in_mean_dc_bc_rc,...
%                                                         depol_out_mean_dc_bc_rc,...
%                                                         depol_in_Mcps_bc_rc,...
%                                                         depol_out_Mcps_bc_rc,...
%                                                         depol_in_dc_bc_rc,...
%                                                         depol_out_dc_bc_rc,...
%                                                         time_rof_profile_in_bins,height_rof_profile_in_bins,...
%                                                         save_all_plots,InputFiles_lidar{ff},result_path)

end

disp('Mean(over time)Depol and (Depol_in/Depol_out) done');





%% If no clouds were found save figure (and mat file) and continue to next loop iteration here
if time_rof_clouds_dc_bc_rc==99999
    save(strcat(result_path,InputFiles_lidar{ff},'.mat'));
    % Save all open figures in one single .fig file
    if save_all_open_figures_each_loop ==1
        figHandles = findall(0, 'Type', 'figure');      % find all open figures
        savefig(figHandles,strcat(result_path,InputFiles_lidar{ff},'.fig'));       %saves a .fig file with the name of the nc file .
    end
    disp('main:Since no clouds were found, go to next nc-file. (next loop iteration)');
    continue;
end




%% Calculate depol mean above CB %%%%%%%%%%%%%%%%

[depol_in_mean_above_CB_dc_bc_rc, depol_out_mean_above_CB_dc_bc_rc, zrange_bounds_above_CB_dc_bc_rc] = ...
                                                   depol_mean_above_cb_fct( cloudbase_dc_bc_rc,...  
                                                                            desface_height_depol_mean,...  
                                                                            depth_into_cloud_depol_mean,...
                                                                            time_rof_clouds_dc_bc_rc,...
                                                                            depol_in_dc_bc_rc,...
                                                                            depol_out_dc_bc_rc);                                                                            

disp('Mean_Depol above CB done');



%% Change Resolution %%%%%%%%%%%%%%%%

% Depol above CB
[depol_in_mean_above_CB_res, depol_out_mean_above_CB_res, time_rof_clouds_res, cloudbase_res_inM ]= ...
                                new_resolution_for_depol_mean_above_CB_fct( depol_in_mean_above_CB_dc_bc_rc,...
                                                                            depol_out_mean_above_CB_dc_bc_rc, ...
                                                                            resolution_temporal_depol_mean_above_CB,  ...
                                                                            cloudbase_inM_dc_bc_rc, ...
                                                                            time_rof_clouds_dc_bc_rc, ...
                                                                            CB_var_limit_inM);
% Max signal
[max_Mcps_in_cloudrange_low_res(1,:),time_low_res_in_bins]  =  change_time_resolution_fct(  max_Mcps_in_cloudrange(1,:),  resolution_temporal_depol_mean_above_CB );
[max_Mcps_in_cloudrange_low_res(2,:),time_low_res_in_bins]  =  change_time_resolution_fct(  max_Mcps_in_cloudrange(2,:),  resolution_temporal_depol_mean_above_CB );
[max_Mcps_in_cloudrange_low_res(3,:),time_low_res_in_bins]  =  change_time_resolution_fct(  max_Mcps_in_cloudrange(3,:),  resolution_temporal_depol_mean_above_CB );
[max_Mcps_in_cloudrange_low_res(4,:),time_low_res_in_bins]  =  change_time_resolution_fct(  max_Mcps_in_cloudrange(4,:),  resolution_temporal_depol_mean_above_CB );

%   Since the two resolution changing functions do not result in same bin_centers
%   we have to cheat a little, an change the time of the cloud_max_low_res a little :
time_rof_max_Mcps_in_cloudrange_res_closest = time_low_res_in_bins(find_closest_index_fct(time_rof_clouds_res, time_low_res_in_bins));


fprintf('Resolution changed from 30sec to %d Minutes... done.\n',resolution_temporal_depol_mean_above_CB);




%% Smoothing and Depolratio %%%%%%%%%%%%%%%%%%%%%%%

% ToDo !!!!!!!!!
%  1. die 2 moeglichkeiten des smoothens scheinen die gleichen ergebnisse zu
%  bringen... ?

%  2. Ich bin nicht zufrieden mit der Art des Smoothens.
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



%3 Moeglichkeiten des smoothens.
%           smooth_depol_or_depolratio==0       :   no smoothing is applied
%           smooth_depol_or_depolratio==1       :   depol_in etc wird gesmoothed. Ratio dann aber nicht
%           smooth_depol_or_depolratio==2       :   depol_in etc wird Nicht gesmoothed. Ratio wird gesmoothed



if smooth_depol_or_depolratio==0
    % Just for renaming, such that for both smoothing-cases same variables can be used afterwards:
    depol_in_mean_above_CB_res_smooth_redutime       = depol_in_mean_above_CB_res  (time_rof_clouds_res) ;
    depol_out_mean_above_CB_res_smooth_redutime      = depol_out_mean_above_CB_res (time_rof_clouds_res) ;
    depolratio_mean_above_CB_res_smooth_redutime     =  depol_in_mean_above_CB_res_smooth_redutime   ./   depol_out_mean_above_CB_res_smooth_redutime;
    % ?depolratio_mean_above_CB_res_smooth_inCB_range (depolratio_mean_above_CB_res_smooth_inCB_range > 1.05)   =   NaN;                              %   delete non realistic values, or ice clouds
    % ?depolratio_mean_above_CB_res_smooth_inCB_range (depolratio_mean_above_CB_res_smooth_inCB_range < 0.3)    =   NaN;
    disp('No smoothing applied. New variables do nevertheless take the name [..]CB_res_smooth_inCB_range  .');
elseif smooth_depol_or_depolratio==1
    depol_in_mean_above_CB_res_smooth_redutime       = smooth (depol_in_mean_above_CB_res (time_rof_clouds_res) , smooth_depol_or_depolratio_parameter);
    depol_out_mean_above_CB_res_smooth_redutime      = smooth (depol_out_mean_above_CB_res (time_rof_clouds_res) , smooth_depol_or_depolratio_parameter);
    depolratio_mean_above_CB_res_smooth_redutime     =  depol_in_mean_above_CB_res_smooth_redutime   ./   depol_out_mean_above_CB_res_smooth_redutime;
    % ?depolratio_mean_above_CB_res_smooth_inCB_range (depolratio_mean_above_CB_res_smooth_inCB_range > 1.05)   =   NaN;                              %   delete non realistic values, or ice clouds
    % ?depolratio_mean_above_CB_res_smooth_inCB_range (depolratio_mean_above_CB_res_smooth_inCB_range < 0.3)    =   NaN;
    disp('depol_in_mean_above_CB_res (and _out_) smoothed. .... depolratio_mean_above_CB_res_smooth_inCB_range calculated ...done');
elseif smooth_depol_or_depolratio==2
    depolratio_mean_above_CB_res_inCB_range       =  depol_in_mean_above_CB_res(time_rof_clouds_res)   ./   depol_out_mean_above_CB_res(time_rof_clouds_res);
    % ?depolratio_mean_above_CB_res_inCB_range (depolratio_mean_above_CB_res>1.05) =   NaN;                              %   delete non realistic values, or ice clouds
    % ?depolratio_mean_above_CB_res_inCB_range (depolratio_mean_above_CB_res<0.3)  =   NaN;
    depolratio_mean_above_CB_res_smooth_redutime = smooth  (depolratio_mean_above_CB_res_inCB_range, smooth_depol_or_depolratio_parameter);
    clear depolratio_mean_above_CB_res;
    disp('depolratio_mean_above_CB_res smoothed....done');
    % Just for renaming, such that for both smoothing-cases same variables can be used afterwards:
    depol_in_mean_above_CB_res_smooth_redutime       = depol_in_mean_above_CB_res  (time_rof_clouds_res) ;
    depol_out_mean_above_CB_res_smooth_redutime      = depol_out_mean_above_CB_res (time_rof_clouds_res) ;
else
    disp(' Error: smooth_depol_or_depolratio MUST BE 0,1 or 2');
end

   


% Plot to show effect of smoothing    
if plot_to_show_effect_of_smoothing ==1                                                                     
    depolratio_mean_above_CB_res_inCB_range  =  depol_in_mean_above_CB_res(time_rof_clouds_res)   ./   depol_out_mean_above_CB_res(time_rof_clouds_res);
    plot_to_show_effect_of_smoothing_fct(depolratio_mean_above_CB_res_smooth_redutime,depolratio_mean_above_CB_res_inCB_range,time_rof_clouds_res,save_all_plots,InputFiles_lidar{ff},result_path);
    %clear depolratio_mean_above_CB_res_inCB_range;
end


%% Inversion 
clear r_eff alpha lwc cdnc
% all variable which come out here are in Reduced-Time (only points when CB is present)
[r_eff, alpha, lwc, cdnc, depolratio_allowed_range_res] = inversion_routine_fct(depol_in_mean_above_CB_res_smooth_redutime,  depolratio_mean_above_CB_res_smooth_redutime,  ...
                                                                                cloudbase_res_inM(time_rof_clouds_res),  simulated_cloudbase_heights,...
                                                                                depth_into_cloud_depol_mean, k_gamma );       

disp('Inversion routine ... done');
cdnc_in_cm = cdnc*1000000;
alpha_per_km= alpha*1000;
r_eff_in_microns= r_eff;
lwc_in_g_per_cubicmeter = lwc;

if plot_inversion_results == 1
    plot_inversion_results_fct(cdnc_in_cm,alpha_per_km,r_eff_in_microns,lwc_in_g_per_cubicmeter,...
                                cloudbase_res_inM,time_rof_clouds_res,save_all_plots,InputFiles_lidar{ff},result_path);
end


%% Analysis of Inversion Success
if plot_inversion_success_analysis == 1
plot_inversion_success_analysis_fct(cloudbase_res_inM, time_rof_clouds_res, ...
                                    depolratio_mean_above_CB_res_smooth_redutime, depolratio_allowed_range_res, ...
                                    max_Mcps_in_cloudrange, max_Mpcs_in_cloudrange_height_bin,...
                                    save_all_plots, InputFiles_lidar{ff}, result_path);

end
                                
                                
%% Create reduced time-range data 
%       (only data where a CB is present is stored)
cloudbase_inM_dc_bc_rc_res_redutime                      = cloudbase_res_inM(time_rof_clouds_res);
max_Mcps_in_cloudrange_closest_redutime                  = max_Mcps_in_cloudrange(:,time_rof_max_Mcps_in_cloudrange_res_closest);


%% Statistical Analysis of Inversion Success Rate
[success_depol_ratio_in_range, cloud_bin_matrix] = statistical_analysis_inversion_success_fct(cloudbase_inM_dc_bc_rc_res_redutime,...
                                                                   depolratio_mean_above_CB_res_smooth_redutime, depolratio_allowed_range_res,...
                                                                   time_rof_clouds_res,...
                                                                   height_bin_edges);
                
%% Store Data for more-then-one-file analysis
file_number(ff).name                                        = InputFiles_lidar{ff};
file_number(ff).time_rof_clouds_res                         = time_rof_clouds_res ;
file_number(ff).cloudbase_inM_dc_bc_rc_res_redutime         = cloudbase_inM_dc_bc_rc_res_redutime ;
file_number(ff).max_Mcps_in_cloudrange_closest_redutime     = max_Mcps_in_cloudrange_closest_redutime ;
file_number(ff).cloud_bin_matrix                            = cloud_bin_matrix ;
file_number(ff).success_depol_ratio_in_range                = success_depol_ratio_in_range ;

                                                                                

%% Save all open figures in one single .fig file
if save_all_open_figures_each_loop ==1
    figHandles = findall(0, 'Type', 'figure');      % find all open figures
    savefig(figHandles,strcat(result_path,InputFiles_lidar{ff},'.fig'));       %saves a .fig file with the name of the nc file . 
end





end    %ff-loop
disp('------------Great loop... finished.');






%% Save all
% clear all variables which might be leftover from last loop or program run
%       this is not a complete list of all variables. some variables get
%       cleared elswhere to free memory, after they are not needed any more
% clearvars('-except',InitialVariableNames{:}, 'ff' , 'last_file_with_calibration' , 'C_Mcps_bc_rc' , 'C_dc_bc_rc', 'file_number' );

datestring = datestr(now,'yyyy_mm_dd HH_MM_SS');

save(strcat(result_path,'results_',InputFiles_lidar{ff},'.mat'),'file_number');
%%
fprintf('Saved results to    ---> %s  results_%s.mat \n',result_path,InputFiles_lidar{ff});



%%  Use this to save global parameters to mat file                                  if uncommented, all variables besides global variables are delted

%  clearvars('-except',InitialVariableNames{:},'ff');
%  save(strcat(result_path,'global parameters_',InputFiles_lidar{ff}(1:end-3),'.mat'));

%%

disp('FINISH');
return;















