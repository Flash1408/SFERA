classdef RungeOptions < BaseOptions
    % RungeOptions
    %
    % Configuration class defining the parameters required for
    % Runge-like effect analysis.
    %
    % This class extends BaseOptions with the initial parameter values
    % and optimization bounds specific to the Runge model.
    %
    % The mathematical model is:
    %
    %   y(t) = A / (1 + B * (t - C)^2) + D
    %
    % The parameter vector is defined as:
    %   p(1) -> A: amplitude of the Runge peak.
    %   p(2) -> B: parameter controlling the peak width.
    %   p(3) -> C: horizontal position of the peak.
    %   p(4) -> D: vertical offset.
    %
    % The default bounds and initial values preserve the configuration
    % adopted by the legacy rungeOptions class.

    properties
        
        % Lower bounds for the Runge model parameters [A, B, C, D].
        lb (1,4) double = [0.01, 1, 0.05, -Inf]

        % Upper bounds for the Runge model parameters [A, B, C, D].
        ub (1,4) double = [Inf, 1e3, 0.95, Inf]

        % Initial parameter values [A0, B0, C0, D0].
        params0 (1,4) double = [1, 10, 0.5, 0]
        
    end
end
