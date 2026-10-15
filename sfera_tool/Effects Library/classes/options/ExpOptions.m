classdef ExpOptions < BaseOptions
    % ExpOptions
    %
    % Configuration parameters specific to exponential fitting.
    % Inherits common analysis and optimization options from BaseOptions.

    properties
        % Lower bounds for the exponential model parameters.
        lb (1,3) double = [-Inf, -Inf, -Inf]

        % Upper bounds for the exponential model parameters.
        ub (1,3) double = [Inf, Inf, Inf]

        % Initial guesses for the exponential model parameters.
        params0 (1,3) double = [1, 1, -0.00001]
    end
end
