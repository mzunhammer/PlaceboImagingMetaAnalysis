function [nps_values, image_names, data_objects] = apply_brainmask(input_images,mask, varargin)
%
% Applies the NPS signuature pattern to a set of brain images (nii or img)
% - requires NPS mask and related extensions on path with standard name(s)
% - takes input in multiple forms, including wildcard, filename list, and cell of fmri_data objects
% - this can also be done easily using apply_mask.m for any mask/signature,
%   but apply_nps makes it easier.
%
% Usage:
% -------------------------------------------------------------------------
% [outputs] = function_name(list inputs here, [optional inputs])
%
% [nps_values, image_names, data_objects] = apply_nps(input_images)
%
%
% Author and copyright information:
% -------------------------------------------------------------------------
%     Copyright (C) 2014 Tor Wager
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Inputs:
% -------------------------------------------------------------------------
% input_images           multiple formats:
%                        - fmri_data object (or other image_vector object)
%                        - fmri_data objects (or other image_vector objects) in cell { }
%                        - list of image names
%                        - cell { } with multiple lists of image names
%                        - image wildcard (NOTE: uses filenames.m, needs
%                        system compatibility)
%                        - cell { } with multiple image wildcards
% Optional inputs:
% 'noverbose'           suppress screen output
%                       not recommended for first run, as verbose output
%                       prints info about missing voxels in each image
% 'notables'            suppress text table output with images and values
%
% Outputs:
% -------------------------------------------------------------------------
% nps_values            cell { } with nps values for each image
% image_names
% data_objects
%
% Examples:
% -------------------------------------------------------------------------
% % Enter a pre-specified list of images:
% input_images = filenames('image_data/Pain_Sub*ANP_001.img', 'char', 'absolute');
% [nps_values, image_names, data_objects] = apply_nps(input_images, 'noverbose');
%
% % % Enter wildcard (requires system compatibility):
% [nps_values, image_names, data_objects] = apply_nps('image_data/Pain_Sub*ANP_001.img', 'noverbose');
%
% % Enter pre-defined objects:
% [nps_values, image_names] = apply_nps(data_objects, 'noverbose');
%
% % Enter series of wildcards:
% wcards = {'Pain_Sub*AP_001.img' ...
%           'Pain_Sub*ANP_001.img' ...
%           'Pain_Sub*EP_001.img' ...
%           'Pain_Sub*ENP_001.img' ...
%           'Pain_Sub*AP_002.img' ...
%           'Pain_Sub*ANP_002.img' ...
%           'Pain_Sub*EP_002.img' ...
%           'Pain_Sub*ENP_002.img' ...
%           'Pain_Sub*AP_003.img' ...
%           'Pain_Sub*ANP_003.img' ...
%           'Pain_Sub*EP_003.img' ...
%           'Pain_Sub*ENP_003.img'};
%       
% [nps_values, image_names, data_objects] = apply_nps(wcards);
%
% See also:
% apply_mask.m

% Programmers' notes:
% Created by Tor Wager, Aug 2014

% INITIALIZE VARIABLES AND DEFAULTS
% -------------------------------------------------------------------------

verbose = 1;
verbosestr = 'verbose';
dotables = 1;
mask = '/Users/matthiaszunhammer/Documents/MATLAB/zun_pain_pattern/b_Weights_for_PCA_469_y_temp_x.nii';

if isempty(mask)
    error('Image ''b_Weights_for_PCA_469_y_temp_x.nii'' not found on path.');
end

[data_objects, image_names, data_objects] = deal({});

% SET UP OPTIONAL INPUTS
% -----------------------------------

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            
            case 'noverbose', verbose = 0; verbosestr = 'noverbose';
            case 'notables', dotables = 0;
            otherwise, warning(['Unknown input string option:' varargin{i}]);
        end
    end
end

% PARSE INPUT TYPE
% Return data_objects{} and image_names{}
% -------------------------------------------------------------------------

if isa(input_images, 'image_vector')
    % - fmri_data object (or other image_vector object)
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    data_objects{1} = input_images;
    image_names{1} = data_objects{1}.image_names;
    clear input_images
    
elseif iscell(input_images) && isa(input_images{1}, 'image_vector')
    % - fmri_data objects (or other image_vector objects) in cell { }
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    data_objects = input_images;
    for i = 1:length(data_objects)
        image_names{i} = data_objects{i}.image_names;
    end
    clear input_images
    
elseif ischar(input_images) && ~any(input_images(:) == '*')
    % - list of image names
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    data_objects{1} = fmri_data(input_images, [], verbosestr);
    image_names{1} = input_images;
    clear input_images
    
elseif iscell(input_images) && ~any(input_images{1}(:) == '*')
    % - cell { } with multiple lists of image names
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    for i = 1:length(input_images)
        data_objects{i} = fmri_data(input_images{i}, [], verbosestr);
        image_names{i} = input_images{i};
    end
    
elseif ischar(input_images) && size(input_images, 1) == 1 && any(input_images(:) == '*')
    % - image wildcard
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    image_names{1} = get_image_names(input_images);
    data_objects{1} = fmri_data(image_names{1}, [], verbosestr);
    clear input_images
    
elseif iscell(input_images) && size(input_images{1}, 1) == 1 && any(input_images{1}(:) == '*')
    % - cell { } with multiple image wildcards
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    for i = 1:length(input_images)
        image_names{i} = get_image_names(input_images{i});
        data_objects{i} = fmri_data(image_names{i}, [], verbosestr);       
    end
    clear input_images
else
    error('Unknown operation mode or input type - check inputs and code.');
    
end % setup input type



% GET ALL NPS VALUES
% -------------------------------------------------------------------------
for i = 1:length(data_objects)
    
    if verbose
        nps_values{i} = apply_mask(data_objects{i}, mask, 'pattern_expression'); %, 'ignore_missing');
        
    else
        nps_values{i} = apply_mask(data_objects{i}, mask, 'pattern_expression', 'ignore_missing');
    end
end

% GET ALL NPS VALUES
% -------------------------------------------------------------------------
if verbose || dotables
    for i = 1:length(data_objects)
        
        if length(image_names) < i || isempty(image_names{i})
            image_names{i} = repmat('Unknown image names', size(nps_values{i}, 1), 1);
        elseif size(image_names{i}, 1) < size(nps_values{i}, 1)
            image_names{i} = repmat(image_names{i}(1, :), size(nps_values{i}, 1), 1);
        end
        
        print_matrix(nps_values{i}, {['NPS values for series ' num2str(i)]}, cellstr(image_names{i}));
    end
end

end  % main function


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%
% Sub-functions
%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

function image_names = get_image_names(input_images)

wcard = input_images;
image_names = filenames(wcard, 'char', 'absolute');
if isempty(image_names)
    error(['No images found for wildcard ' wcard])
end

end % function


