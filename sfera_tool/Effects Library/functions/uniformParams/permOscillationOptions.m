% File: permOscillationOptions.m
classdef permOscillationOptions < options

    properties
        % --- Parameters bounds ---
        lb double = [0, -1e-6, 0, -pi];
        ub double = [Inf, 1e-6, 50, pi];

        % --- Optimization parameters ---
        tolFun double = 1e-6;
        maxIter double = 1000;
        
        % --- Max. limit to consider beta ~ 0 ---
        betaTol double = 1e-9;      

        % --- Spectral check ---
        useSpectralCheck logical = true;
        spectralThreshold double = 0.25;  % picco dominante (0–1 normalizzato)

        % --- Plot options ---
        showPlot logical = false;
    end

    methods
        function obj = permOscillationOptions(varargin)
            if nargin > 0
                for i = 1:2:numel(varargin)
                    if isprop(obj, varargin{i})
                        obj.(varargin{i}) = varargin{i+1};
                    else
                        warning('Unknown property: %s', varargin{i});
                    end
                end
            end
        end
    end

end

