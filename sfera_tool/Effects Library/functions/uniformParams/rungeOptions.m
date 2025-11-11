% File: RungeOptions.m
classdef rungeOptions < options
    %RUNGEOPTIONS Options for fitting a Runge-like function

    properties
        % --- Initial guesses [A, B, C, D] ---
        params0 double = [1, 10, 0.5, 0]; 

        % --- Bounds ---
        lb double = [0, 0, 0, -Inf];
        ub double = [Inf, 1e3, 1, Inf];

        % --- Optimization settings ---
        tolFun double = 1e-6;
        maxIter double = 1000;

        % --- Plot options ---
        showPlot logical = false;
    end

    methods
        function obj = RungeOptions(varargin)
            % Flexible constructor: allows name-value pairs
            % Example: RungeOptions('threshold', 0.9, 'showPlot', true)
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


