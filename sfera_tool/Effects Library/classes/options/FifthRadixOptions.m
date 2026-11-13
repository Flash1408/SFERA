classdef FifthRadixOptions < BaseOptions
    % FifthRadixOptions
    %
    % Configuration class defining the parameters required for
    % fifth radix effect analysis.
    %
    % This class extends BaseOptions with the initial parameter values
    % and optimization bounds specific to the fifth radix model.
    %
    % The mathematical model is:
    %
    %   y(t) = A * nthroot(B * (t - C), 5) + D
    %
    % The parameter vector is defined as:
    %   p(1) -> A: amplitude of the fifth-root component.
    %   p(2) -> B: horizontal scaling factor.
    %   p(3) -> C: horizontal translation.
    %   p(4) -> D: vertical offset.
    %
    % The default bounds and initial values preserve the configuration
    % adopted by the legacy fifthRadixOptions class.

    properties

        % Lower bounds for the fifth radix model parameters [A, B, C, D].
        lb (1,4) double = [0, -10, 0, -Inf]

        % Upper bounds for the fifth radix model parameters [A, B, C, D].
        ub (1,4) double = [Inf, 10, 1, Inf]

        % Initial parameter values [A0, B0, C0, D0].
        params0 (1,4) double = [1, 1, 0.5, 0]

    end
end
