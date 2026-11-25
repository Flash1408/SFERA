classdef CustomOptions < BaseOptions
    % CustomOptions
    %
    % Configuration class defining the parameters required for
    % custom effect analysis.
    %
    % This class extends BaseOptions with the initial parameter values
    % and optimization bounds supplied by a UserModel.
    %
    % The parameter vectors are model-dependent and therefore do not
    % have a predefined number of elements.

    properties
        % Initial parameter values used by the optimization algorithm.
        params0 double = []

        % Lower bounds for the custom model parameters.
        lb double = []

        % Upper bounds for the custom model parameters.
        ub double = []
    end
end
