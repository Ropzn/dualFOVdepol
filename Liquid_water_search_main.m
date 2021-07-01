

%% Set global Parameters

bin_height                      = 7.5;                                          % One height bin corresponds to 7.5m

rangocanales                    = [5] ; %= [5 6 9 13];                                   % channels needed: 5=532 6=532c, 9=532out, 13=532c_out,  (8=1064, 3=387, 4=407, 1=355)
pretrigger                      = 251;                                          % 251 defines the bin at 7.5m over ground.
maxheight                       = 3600;%933;                                          % Defines the max height for the profiles 933*7,5m= 10km
BG_rof_height                   = 3000:3300;                                    % Take from heights [5500..6000]*7.5m ~ [41km..45km]




%%
%% NetCDF einladen
fprintf('\n---------------------------------------------------------\n Loop %d ::: Processing %s \n---------------------------------------------------------\n',ff,InputFiles_lidar{ff});
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
disp('netcdf-file loaded');


% Get numeric measurement-time vector
fprintf('Get numeric measurement-time vector ... ');

measurement_time_num = convert_measurement_time_from_nc_to_numeric_time(measurement_time);
fprintf('done. \n ');



%% Correction for lost measurements
correct_raw_data_for_missing_bins;


%%  Reduction Dataset + Mcps

% Reduce Dataset and extract Range for Backgroundcorrection
%       - to the 4 channels,
%       - eleminating the pretrigger (251 bins) and setting maxheight
%       - This reduces cpu-time and RAM-use dramatically since all heights between bin 1000:5500 are not used
%       - Drawback: some operations on the variables raw_signal and
%                   BG_raw have to be coded twice
%


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

%%% The following lines give almost the same results as the above calculations  (for 50Hz Laser !!, not true for new 100Hz systems !!)
% raw_signal_Mcps =  raw_signal  / 30;            
% BG_raw_Mcps     =  BG_raw      / 30;  

disp('reduction + Mcps  - done');



%% Deadtime
% Prepare Deadtimepolynomial
deadtime_polynomial        = flip(deadtime_polynomial(rangocanales,:)')';                           % Reduce to needed channels and change the order of the elements, such that they can be evaluated by polyval later on
deadtime_polynomial_error  = flip(deadtime_polynomial_error(rangocanales,:)')';                           % Reduce to needed channels and change the order of the elements, such that they can be evaluated by polyval later on

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




%% Find cloudbase %%%%%%%%%%%%%%%%%%%

fprintf('Cloudbase search....');
[cloudbase,time_rof_clouds] = find_liquid_water_phase_1_0 (signal_smoothed(1,:,:),height_rof_cloudsearch,InputFiles_lidar{ff});

% disp('ACHTUNG CB manuell verändern')
% cloudbase = cloudbase -3;

cloudbase_inM      =   cloudbase * bin_height;                                        % Stores the Cloudbase in Meters

fprintf('... done.\n');
