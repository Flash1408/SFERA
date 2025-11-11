% File: divOscillationOptions.m
classdef divOscillationOptions < options
    properties
        % --- Parameters bounds ---
        lb double = [0, -10, 0, -pi, -Inf];  
        ub double = [Inf, 0, 50, pi, +Inf];  

        % --- Initial guesses ---
        params0 double = [1, 1, 0.5, 0, 1];  

        % --- Optimization parameters ---
        maxIter double = 1000;
        tolFun double = 1e-6;

        % --- Plot options ---
        showPlot logical = false;
    end

    methods
        function obj = divOscillationOptions(varargin)
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
