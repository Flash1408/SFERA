classdef CubicRadixOptions < BaseOptions
    % CubicRadixOptions
    %
    % Configuration class defining the parameters required for
    % cubic radix effect analysis.
    %
    % This class extends BaseOptions with the initial parameter values
    % and optimization bounds specific to the cubic radix model.
    %
    % The mathematical model is:
    %
    %   y(t) = A * sign(B * (t - C)) ...
    %              * abs(B * (t - C))^(1/3) + D
    %
    % The parameter vector is defined as:
    %   p(1) -> A: amplitude of the cubic-root component.
    %   p(2) -> B: horizontal scaling factor.
    %   p(3) -> C: horizontal translation.
    %   p(4) -> D: vertical offset.
    %
    % The default bounds and initial values preserve the configuration
    % adopted by the legacy cubicRadixOptions class.

    properties

        % Lower bounds for the cubic radix model parameters [A, B, C, D].
        lb (1,4) double = [0, 0, 0, -Inf]

        % Upper bounds for the cubic radix model parameters [A, B, C, D].
        ub (1,4) double = [Inf, Inf, 1, Inf]

        % Initial parameter values [A0, B0, C0, D0].
        params0 (1,4) double = [1, 1, 0.5, 0]

    end
end
