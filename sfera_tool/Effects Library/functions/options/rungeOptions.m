% File: RungeOptions.m
classdef rungeOptions < options
    %RUNGEOPTIONS Options for fitting a Runge-like function

    properties
        % --- Initial guesses [A, B, C, D] ---
        params0 double = [1, 10, 0.5, 0]; 

        % --- Bounds ---
        lb = [0.01, 1, 0.05, -Inf];   % A, B, C, D
        ub = [Inf, 1e3, 0.95, Inf];

        % --- Optimization settings ---
        tolFun double = 1e-6;
        maxIter double = 1000;

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


