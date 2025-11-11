% File: multiSinusoidsOptions.m
classdef multiSinusoidsOptions < options
    %MULTISINUSOIDSOPTIONS Options for multi-sinusoid fitting

    properties
        % --- Number of sinusoids ---
        N double = 2;          % default: sum of 2 cosines

        % --- Optimization parameters ---
        tolFun double = 1e-6;
        maxIter double = 1000;

        % --- Plot options ---
        showPlot logical = false;
    end

    methods
        function obj = MultiSinusoidsOptions(varargin)
            % Flexible constructor
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

