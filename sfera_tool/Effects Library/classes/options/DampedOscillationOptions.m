classdef DampedOscillationOptions < BaseOptions
    % DampedOscillationOptions
    %
    % Configuration class defining the parameters required for
    % damped oscillation detection and curve fitting.
    %
    % This class inherits the common analysis and optimization
    % settings from BaseOptions and defines the model-specific
    % configuration parameters, including:
    %   - Lower and upper bounds for model parameters.
    %   - Initial parameter estimates for nonlinear fitting.
    %
    % The parameters are used by DampedOscillationEffect and
    % its associated analysis tasks.

    properties
        % Lower bounds for the damped oscillation model parameters.
        lb (1,5) double = [0, -5, 0.05, -pi, -Inf]

        % Upper bounds for the damped oscillation model parameters.
        ub (1,5) double = [Inf, -1e-3, 50, pi, Inf]

        % Initial estimates for the damped oscillation model parameters.
        params0 (1,5) double = [1, -0.01, 0.5, 0, 1]
    end
end