classdef ArcTanOptions < BaseOptions
    % ArcTanOptions
    %
    % Configuration class defining the parameters required for
    % arc-tangent effect analysis.
    %
    % This class extends BaseOptions with the initial parameter values
    % and optimization bounds specific to the arc-tangent model.
    %
    % The parameter vector is defined as:
    %   p(1) -> A: amplitude.
    %   p(2) -> H: horizontal position of the central transition.
    %   p(3) -> C: parameter controlling the transition slope.
    %   p(4) -> D: vertical offset.
    %
    % All initial parameter values are retrieved directly from params0
    % by ArcTanEffect.

    properties
        % Lower bounds for the arc-tangent model parameters [A, H, C, D].
        lb (1,4) double = [-Inf, 0, eps, -Inf]

        % Upper bounds for the arc-tangent model parameters [A, H, C, D].
        ub (1,4) double = [Inf, 1, 1, Inf]

        % Initial parameter values [A0, H0, C0, D0].
        params0 (1,4) double = [1, 0.5, 0.2, 0]
    end
end
