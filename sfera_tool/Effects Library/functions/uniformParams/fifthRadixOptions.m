% File: fifthRadixOptions.m
classdef fifthRadixOptions < options

    properties
        % --- Parameters bounds ---
        lb double = [0, -10, 0, -Inf];
        ub double = [Inf, 10, 1, Inf];

        % --- Initial guesses ---
        params0 double = [1, 1, 0.5, 0];  

        % --- Optimization parameters ---
        tolFun double = 1e-6;
        maxIter double = 1000;

        % --- Plot options ---
        showPlot logical = false;
    end

    methods
        function obj = fifthRadixOptions(varargin)
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


