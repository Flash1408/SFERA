classdef ExpOptions < BaseOptions
    % ExpOptions
    %
    % Configuration class defining the parameters required for
    % exponential effect analysis.
    %
    % This class extends BaseOptions with the initial parameter values
    % and optimization bounds specific to the exponential model.
    %
    % The parameter vector is defined as:
    %   p(1) -> A: vertical offset.
    %   p(2) -> B: exponential amplitude.
    %   p(3) -> C: exponential growth or decay rate.
    %
    % The initial values for A and B are estimated from the input signal
    % by ExpEffect, while the initial value for C is retrieved from
    % params0.

    properties
        % Lower bounds for the exponential model parameters [A, B, C].
        lb (1,3) double = [-Inf, -Inf, -Inf]

        % Upper bounds for the exponential model parameters [A, B, C].
        ub (1,3) double = [Inf, Inf, Inf]

        % Initial parameter values [A0, B0, C0].
        % Only C0 is directly used by ExpEffect.
        params0 (1,3) double = [1, 1, -0.00001]
    end
end
