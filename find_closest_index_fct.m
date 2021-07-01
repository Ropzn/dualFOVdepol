%%    Find closest values
% 
%       Input:  inputVector,                  vector of length cc
%               findclosest_inthis_vector     vector of lentht dd
%       Output:
%               closestIndex                  vector of length cc
% 
%   - Given a vector V and a vector A   (does not have to be the same size)
%   - This funtion finds for every element in A the closest element in V
%   - And returns the indeces of these in a vector 'closestIndex'
%
%   Example:
%       we have to large datasets wich were changed in resolution, but the new time stamps are shiftet slightly
%       data_A_full , data_B_full
%         -> data_lowres_A , data_lowres_B

%       data_lowres_A(1) corresponds to time 20,  but in data_lowres_B there are no values for time 20 but for time 19 and time 24
%       
%       ahhh difficult to explain...
%



%%
function closestIndex = find_closest_index_fct(inputVector, findclosest_inthis_vector)

    [minValue, closestIndex] = min(abs(inputVector - findclosest_inthis_vector .'));
    
end