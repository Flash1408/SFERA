classdef MultiSinusoidsOptions < BaseOptions
    % MultiSinusoidsOptions
    %
    % Configuration class defining the parameters required for
    % multi-sinusoid signal detection and curve fitting.
    %
    % This class inherits the common analysis and optimization
    % settings from BaseOptions and defines the model-specific
    % configuration parameter:
    %   - Number of sinusoidal components used by the model.
    %
    % The lower and upper fitting bounds are computed dynamically
    % according to the number of sinusoidal components.
    %
    % The fitted model is:
    %   y(t) = sum_k A_k * cos(omega_k * t + phi_k) + C

    properties
        % Number of sinusoidal components in the model.
        N (1,1) double {mustBeInteger, mustBePositive} = 2
    end

    properties (Dependent)
        % Lower bounds for the fitting parameters.
        lb

        % Upper bounds for the fitting parameters.
        ub
    end

    methods
        function value = get.lb(obj)
            % GET.LB Compute lower fitting bounds.
            %
            % Each sinusoidal component has:
            %   - Nonnegative amplitude.
            %   - Nonnegative angular frequency.
            %   - Phase in the interval [-pi, pi].
            %
            % The constant offset is unbounded.

            componentBounds = [0, 0, -pi];

            value = [repmat(componentBounds, 1, obj.N), -Inf];
        end

        function value = get.ub(obj)
            % GET.UB Compute upper fitting bounds.
            %
            % Each sinusoidal component has:
            %   - Unbounded amplitude.
            %   - Unbounded angular frequency.
            %   - Phase in the interval [-pi, pi].
            %
            % The constant offset is unbounded.

            componentBounds = [Inf, Inf, pi];

            value = [repmat(componentBounds, 1, obj.N), Inf];
        end
    end
end

