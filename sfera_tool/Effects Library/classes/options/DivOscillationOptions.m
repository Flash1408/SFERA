classdef DivOscillationOptions < BaseOptions
    % DivOscillationOptions
    %
    % Configuration class defining the parameters required for
    % divergent oscillation detection and curve fitting.
    %
    % This class inherits the common analysis and optimization
    % settings from BaseOptions and defines the model-specific
    % configuration parameters, including:
    %   - Lower and upper bounds for model parameters.
    %   - Initial parameter estimates for nonlinear fitting.
    %
    % The parameters are used by DivOscillationEffect and
    % its associated analysis tasks.
    %
    % The fitted model is:
    %   y(t) = A * exp(beta*t) * cos(omega*t + phi)

    properties
        % Lower bounds for the divergent oscillation model parameters.
        lb (1,4) double = [0, 0, 0, -pi]

        % Upper bounds for the divergent oscillation model parameters.
        ub (1,4) double = [Inf, Inf, 50, pi]

        % Initial estimates for the divergent oscillation model parameters.
        params0 (1,4) double = [1, 0.01, 1, 0]
    end
end
