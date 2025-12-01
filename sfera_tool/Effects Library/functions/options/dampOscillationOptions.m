% File: dampOscillationOptions.m
classdef dampOscillationOptions < options
    properties
        %  --- Parameters bound ---
        lb double = [0, -5, 0.05, -pi, -Inf]; 
        ub double = [Inf, -1e-3, 50, pi, +Inf];

        % --- Initial guesses ---
        params0 double = [1, 1, 0.5, 0, 1];  

        % --- Optimization parameters ---
        maxIter double = 1000;
        tolFun double = 1e-6;
    end

    methods
        function obj = dampOscillationOptions(varargin)
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
