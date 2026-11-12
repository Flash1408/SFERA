function setupSFERA()
% SETUPSFERA Configures the MATLAB path required to develop and run SFERA.
%
%   setupSFERA() adds the directories containing the refactored Effects
%   Library classes and utilities to the MATLAB search path.
%
%   The project root is determined automatically from the location of
%   this script, making the configuration independent of the current
%   MATLAB working directory.
%
%   NOTES:
%       - Only explicitly selected directories are added.
%       - Legacy functions are intentionally excluded.
%       - Existing MATLAB paths are preserved.

% Determine the root directory of the SFERA project.
projectRoot = fileparts(mfilename('fullpath'));

% Define the directories required by the refactored Effects Library.
effectsLibraryRoot = fullfile(projectRoot, 'Effects Library');

requiredPaths = {
    fullfile(effectsLibraryRoot, 'utilities')
    fullfile(effectsLibraryRoot, 'classes')
    fullfile(effectsLibraryRoot, 'classes', 'base')
    fullfile(effectsLibraryRoot, 'classes', 'custom')
    fullfile(effectsLibraryRoot, 'classes', 'effects')
    fullfile(effectsLibraryRoot, 'classes', 'factory')
    fullfile(effectsLibraryRoot, 'classes', 'options')
    fullfile(effectsLibraryRoot, 'classes', 'tasks')
    };

% Add only existing directories to the MATLAB path.
for k = 1:numel(requiredPaths)
    if isfolder(requiredPaths{k})
        addpath(requiredPaths{k});
    else
        warning('setupSFERA:MissingDirectory', ...
            'Required directory not found: %s', requiredPaths{k});
    end
end

fprintf('SFERA MATLAB paths configured successfully.\n');
end
