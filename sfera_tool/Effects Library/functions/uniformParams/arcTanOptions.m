% File: ArcTanOptions.m
classdef arcTanOptions < options
    %ARCTANOPTIONS Options for the arctangent divergence fitting

    properties
        % --- Initial guesses ---
        params0 double = [1, 0.5, 0.2, 0];  

        % --- Parameters bounds ---
        lb double = [-Inf, 0, eps, -Inf];
        ub double = [Inf, 1, 1, Inf];

        % --- Optimization parameters ---
        tolFun double = 1e-6;
        maxIter double = 1000;

        % --- Plot options ---
        showPlot logical = false;
    end

    methods
        function obj = arcTanOptions(varargin)
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


