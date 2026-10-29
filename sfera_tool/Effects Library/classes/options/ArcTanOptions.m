classdef ArcTanOptions < BaseOptions
    % ArcTanOptions
    %
    % Configuration parameters specific to arc-tangent fitting.
    % Inherits common analysis and optimization options from BaseOptions.

    properties 
        % Lower bounds for the arc-tangent model parameters.
        lb (1,4) double = [-Inf, 0, eps, -Inf]

        % Upper bounds for the arc-tangent model parameters.
        ub (1,4) double = [Inf, 1, 1, Inf]

        % Initial guesses for the arc-tangent model parameters.
        params0 (1,4) double = [1, 0.5, 0.2, 0]
    end
end    