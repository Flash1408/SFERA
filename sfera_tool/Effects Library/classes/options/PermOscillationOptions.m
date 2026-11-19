classdef PermOscillationOptions < BaseOptions
    % PermOscillationOptions
    %
    % Configuration class defining the parameters required for
    % permanent oscillation detection and curve fitting.
    %
    % This class inherits the common analysis and optimization
    % settings from BaseOptions and defines the model-specific
    % configuration parameters, including:
    %   - Lower and upper bounds for model parameters.
    %   - Initial parameter estimates for nonlinear fitting.
    %   - Tolerance for accepting negligible damping or divergence.
    %   - Configuration of the spectral analysis criterion.
    %
    % The parameters are used by PermOscillationEffect and
    % its associated analysis tasks.
    %
    % The fitted model is:
    %   y(t) = A * exp(beta*t) * cos(omega*t + phi) + D

    properties
        % Lower bounds for the permanent oscillation model parameters.
        lb (1,5) double = [0, -1e-6, 0, -pi, -Inf]

        % Upper bounds for the permanent oscillation model parameters.
        ub (1,5) double = [Inf, 1e-6, 50, pi, Inf]

        % Initial estimates for the permanent oscillation model parameters.
        params0 (1,5) double = [1, 0, 2*pi, 0, 0]

        % Maximum absolute damping or divergence coefficient accepted.
        betaTol (1,1) double = 1e-6

        % Enables or disables the spectral analysis criterion.
        useSpectralCheck (1,1) logical = true

        % Minimum normalized spectral peak required for acceptance.
        spectralThreshold (1,1) double = 0.5
    end
end
