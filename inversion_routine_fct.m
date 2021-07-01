%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function contains the inversion routine.
%
%   Input: 
%                               depol_ratio (mean above CB), 
%                               depol_in (mean above CB), 
%                               cloudbase (in meters) ,
%                               simulated cloud base heights , 
%                               max penetration depth into cloud, 
%                               density of water
%
%   Reads in Simulationdata: 
%                               simulation_input_R_ref, 
%                               simulation_input_alpha_ref,   
%                               fit_R_ref, 
%                               alpha_matrix_(simulated heights)
%
%   Output: 
%                               r_eff, alpha, lwc, cdnc                             % structure of the variables see comments in code
%   
%   example call:
%
%                               [r_eff, alpha, lwc, cdnc] = inversion_routine_fct(depol_in_mean_above_CB_low_res,  depolratio_mean_above_CB_low_res,  ...
%                                                                                   cloudbase_low_res_inM(time_rof_clouds_low_res),  simulated_cloudbase_heights);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





function [r_eff_L, alpha_L, lwc_L, cdnc_L, depolratio_allowed_range_L ] = inversion_routine_fct(depol_in_mean_above_CB_L,depol_ratio_mean_above_CB_L,...
                                                                    cloudbase_inM_L,simulated_cloudbase_heights_L,...
                                                                    depth_into_cloud_max, k_L, density_water_L)

R_ref_min = 0.5;
R_ref_max = 15;
                                                                
                                                                
%% Read in Simulated Values
r_ref_input                             = load('polly_input_R.txt');                                                                % 1-D Array of all R_ref values which where used in simulation      eg: [2.2551    2.3551    2.4551 ... 13.9550   14.0550]
alpha_ref_input                         = load('polly_input_alpha.txt');                                                            % 1-D Array of all alpha_ref values which where used in simulation  eg: [0.0050    0.0051    0.0052   ... 0.0272    0.0273]
R_ref_vs_depolratio_coefficient_matrix  = load('polly_fit_values_R.txt');                                                           % Matrix of coefficents of the fit r 70 = r_0 + r_2 · (δ r ± ∆δ r )^2 + r_3 · (δ r ± ∆δ r )^3.  For every simulated_CB_height one coloum of coefficients.
for i=1:length(simulated_cloudbase_heights_L)                                                                                       % we load it here all to ommit repetive loading during the cloudbase loop
    depol_simulated_matrix_alpha_r(i,:,:)= load(strcat('polly_alpha_matrix_',num2str(simulated_cloudbase_heights_L(i)),'.txt'));    % dim1: index of simulation_height % polly_alpha_matrix is a matrix rownumber:alpha_ref_index, coloumnumber:r_ref_index, values:depol_in
end

counter_depolratio_out_of_inversion_range_L = 0; % nur für testzwecke. ob depolratio_allowed_range_L vernueftig arbeitet








%% Loop for every found Cloudbase
%                                           --------- Es waere noch eine Idee Wolkenperioden zusammenzufassen, um das Programm schneller zu machen


for t=1:length(cloudbase_inM_L)                                                                                         % Loop through all measured Cloudbases
    CB_mean = cloudbase_inM_L(t);                                                                                       % save the current CB for this loop iteration
    
    % Find the Simulated Cloudbases above and below the measured CB
    if CB_mean < simulated_cloudbase_heights_L(1)                                                                       % CB is below all simulated_cloudbase_heights_L
        fprintf('inversion_routine_fct says: %d-th cloudbase was only at %f meters, which is lower than the lowest simulated CB (%f) But we continue calculation with the assumption it lies between %f and %f \n', ...
                    t,CB_mean,simulated_cloudbase_heights_L(1),simulated_cloudbase_heights_L(1),simulated_cloudbase_heights_L(2));
        top_index = 2;                                                                                                  % simulated_cloudbase_heights_L(top) is the simulated_cloudbase above the measured CB_mean
    elseif CB_mean > simulated_cloudbase_heights_L(end)                                                                 % CB is above all simulated_cloudbase_heights_L
        fprintf('inversion_routine_fct says: %d-th cloudbase was at %f meters, which is above than the largest simulated CB (%f) But we continue calculation with the assumption it lies between %f and %f \n',...
                    t,CB_mean,simulated_cloudbase_heights_L(end),simulated_cloudbase_heights_L(end-1),simulated_cloudbase_heights_L(end));
        top_index = lenght(simulated_cloudbase_heights_L);                                                              % simulated_cloudbase_heights_L(top) is the simulated_cloudbase above the measured CB_mean
    else
        top_index = find( (CB_mean - simulated_cloudbase_heights_L) < 0  , 1);                                          % find the simulated_cloudbase_height which is above CB. k = find(X,n) returns the first n indices corresponding to the nonzero elements in X
    end
    base_index = top_index-1;
    
    % CB lies between these to simulated CBs
    zbase   = simulated_cloudbase_heights_L(base_index);                                                                %(in meters)
    ztop    = simulated_cloudbase_heights_L(top_index );                                                                %(in meters)
    
    % R_ref_fits for the heights below and above CB_mean
    R_ref_vs_depolratio_coefficients_base  = R_ref_vs_depolratio_coefficient_matrix (:,base_index);
    R_ref_vs_depolratio_coefficients_top   = R_ref_vs_depolratio_coefficient_matrix (:,top_index );
    
    % alpha-R-depol_inner - matrices for the heights below and above CB_mean
    depol_in_matrix_base   = squeeze(depol_simulated_matrix_alpha_r(base_index,:,:));                                   % Use squeeze here to get rid of the first dimension.
    depol_in_matrix_top    = squeeze(depol_simulated_matrix_alpha_r(top_index ,:,:));                                  	% Use squeeze here to get rid of the first dimension.
    
    
    
    %% Find R_ref
    % We have functions (coefficients) of r_ref vs depolratio
    
    % Define the range of the fit
    depolratio_fitrange = 0.3:0.01:1.1;
    
    % Calculate Values for R_ref(simulated) whith the help of the coefficients (which were found during simulation)     % r_ref_fit = polyval(fitvalues,ratio_fit);
    R_ref_simulated_base=polyval( R_ref_vs_depolratio_coefficients_base , depolratio_fitrange );                        % array with R_ref values found by simulation
    R_ref_simulated_top =polyval( R_ref_vs_depolratio_coefficients_top  , depolratio_fitrange );                        % array with R_ref values found by simulation
    
    % Find the 'true' curve between R_ref_simulated_base and R_ref_simulated_top
    %   by standardizing the mean between the two
    %   rmax_CB = rmax_top - differenz(rmax_base,rmax-top) * (ztop standardized)                                        % standardisation: z = (X-mean) / variance
    R_ref_CB_curve = R_ref_simulated_top  +  ( R_ref_simulated_base - R_ref_simulated_top )  *  ( ztop - CB_mean ) / ( ztop - zbase);      % Is a curve (an array)                % v = v + (v-v) * (s-s)/(s-s)   , wobei v=vector,s=skalar
    
    % Find a function (and its coefficients) describing these values
    R_ref_CB_vs_depolratio_fit          = fit( depolratio_fitrange' , R_ref_CB_curve','poly3');                         % calculate a fitting polynomial fct
    R_ref_CB_vs_depolratio_coefficients = coeffvalues(R_ref_CB_vs_depolratio_fit);                                      % extract the coefficients
    
    
    % Preperation of 'depol_ratio_mean_above_CB'  values
    %   Get rid of depol_ratio values which correspond to too R_ref values outside of ]0...15]                
    %   Find the boundaries
    R_ref_CB_min_index  = find(R_ref_CB_curve>R_ref_min, 1);                                                                    % Find R_ref boundary
    R_ref_CB_max_index  = find(R_ref_CB_curve>R_ref_max,1);
    depolratio_min      = depolratio_fitrange(R_ref_CB_min_index);                                                      % Find corresponding depol_ratio boundary
    depolratio_max      = depolratio_fitrange(R_ref_CB_max_index);
    depolratio_allowed_range_L(:,t) = [depolratio_min,depolratio_max];                                                      % For later analysis, if depol_ratio was within range, and calculation of successrate

    %   If depol_ratio_mean_above_CB does not lie within boundaries it gets NaN
    if ( (depol_ratio_mean_above_CB_L(t) <= depolratio_min)  |  (depol_ratio_mean_above_CB_L(t) >= depolratio_max )  )
        depol_ratio_mean_above_CB_L(t)  = NaN;
        depol_in_mean_above_CB_L(t)     = NaN;
        counter_depolratio_out_of_inversion_range_L = counter_depolratio_out_of_inversion_range_L+1;
    end
    
    % Evaluate the function we just found for R(depolratio) with  (depolratiomeasured)
    R_ref_CB_one_value(t) = polyval( R_ref_CB_vs_depolratio_coefficients , depol_ratio_mean_above_CB_L(t)  );           % This is just one value:  y = polyval(coeff, x);
    
    
    %% Find depol_in_CB
    
    % Find the 'true' matrix between simulated depol_in_matrix_base and depol_in_matrix_top
    %       by standardizing the mean between the two
    %       depol_CB = depol_base + differenz(depol_base,depol_top) * (ztop standardized)                               % standardisation: z = (X-mean) / variance    
    depol_in_matrix_CB   =  depol_in_matrix_base   +   (depol_in_matrix_top  -   depol_in_matrix_base)  * ( CB_mean-zbase)/(ztop-zbase);

    if ( (r_ref_input(end) <  R_ref_CB_one_value(t))  |  isnan(R_ref_CB_one_value(t))  )                                % In case no nice values are available
        colum_index_R_ref_CB (t)    = NaN;
        depol_in_vector_CB          = depol_in_matrix_CB(:,1) * NaN;
        alpha_ref_CB_one_value(t)   = NaN;
    else
        % Find the colum in depolCB which corresponds to R      (1st r_ref_input that is larger than R_ref_CB_one_value)
        colum_index_R_ref_CB (t) = find ( r_ref_input - R_ref_CB_one_value(t) >= 0 , 1);                                % find the first element in r_ref_input that is larger than the calculated R_ref_CB
        depol_in_vector_CB       = depol_in_matrix_CB(:,colum_index_R_ref_CB (t));                                      % extract the depol_in vector which corrsponds to R_ref_CB
        
        %% Find alpha_ref
        % Find a function (and its coefficients) describing these values
        alpha_ref_vs_depolin_CB_fit          = fit( depol_in_vector_CB , alpha_ref_input','poly2');                     % calculate a fitting polynomial fct
        alpha_ref_vs_depolin_CB_coefficients = coeffvalues(alpha_ref_vs_depolin_CB_fit);                                % extract the coefficients
        % Evaluate the function we just found for alpha(depolin) with (depol_in_mean)
        alpha_ref_CB_one_value(t)           = polyval( alpha_ref_vs_depolin_CB_coefficients , depol_in_mean_above_CB_L(t)  );     % This is just one value:  y = polyval(coeff, x);
    end
    
    %% Calculate R and alpha
    % Info: Brauchen wir wirklich alle werte fuer alle eindringtiefen, oder
    % wuerde einfach eindringtiefe r_ref genuegen ??
    % R_e = R_ref * (  ( z  -   z_b   )  /  ( z_ref - z_b )  ) ^ (1/3) 
    %
    %     = R_ref * (  ( z(vector) - z_b(scalar) ) /   ( z_ref  -  z_b )    ) ^ (1/3)
    %     = R_ref * (         pd(vector)           /  ( pd_max(scalar) )    ) ^ (1/3)
    %
    % alpha = alpha_ref * (  ( z  -   z_b   )  /  ( z_ref - z_b )  ) ^ (2/3) 
    
    pd_vector = 1:depth_into_cloud_max;                                                                                 % Creates an array [1, 2 , ... penetrationdepth(in bins)]
    r_eff_L(:,t) = R_ref_CB_one_value(t) * ( pd_vector / depth_into_cloud_max ) .^(1/3);                                % Gives a Matrix: Cols=Cloudbases, Rows=Different penetration depths[0...max]
    alpha_L(:,t) = alpha_ref_CB_one_value(t) * ( pd_vector / depth_into_cloud_max ) .^(2/3);                            % Gives a Matrix: Cols=Cloudbases, Rows=Different penetration depths[0...max]
    
end % End loop for every cloudbase
    




%% Calculate LWC and CDNC
lwc_L   =  2/3 * alpha_L .* r_eff_L  ;                                 % element-wise multiplication ;-)                % unit: [g/m^3]  Liquid Water content, in general: lwc= 2/3 * rho_water * alpha * r_eff. Here: lwc = 2/3 * alpha * r_eff, because.  [alpha] = 1/m, rho_water = 1 g/cm^3 = 1.000.000 g/m^3,  [r_eff] = micrometer = 10^-6m               % Gives a Matrix: Cols=Cloudbases, Rows=Different penetration depths[0...max]
cdnc_L  = 1 / (2 * pi * k_L)  * alpha_L ./ (r_eff_L .^(2)) ;                                                            % unit: [   cloud droplet number concentration   % Gives a Matrix: Cols=Cloudbases, Rows=Different penetration depths[0...max]



%% Der Rest ist Experimentier stuff, der eig nicht gebraucht wird
% cdnc_in_cm = cdnc_L*1000000;
% alpha_per_km= alpha_L./1000;
% r_eff_in_microns= r_eff_L .* 1000000;
% 
% % Frage: Wie schauts aus mit den Einheiten?
% % So besser? Ne das is quatsch
% cdnc_r_m= 1 / (2 * pi * k_L)  * alpha_L ./ ((r_eff_L*10^(-6)) .^(2)); %Ne das is quatsch
% 
% cdnc_mum= 1 / (2 * pi * k_L)  * alpha_L*10^(6) ./ ((r_eff_L*10^(-6)) .^(2)); %kann man machen ist aber quatsch.
% 
% cdnc_r_m_to_cm   = cdnc_r_m * 10^(-6); 
% 
% cdnc_al_mum_to_cm = cdnc_mum * 10^(-12); %%kann man machen ist aber quatsch.



    
end  %function



