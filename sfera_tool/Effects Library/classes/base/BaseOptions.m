classdef BaseOptions < handle
    % BaseOptions
    % 
    % Container for configuration parameters used by effects and tasks.
    %
    % This class encapsulates generic options.
    %
    % It is designed to be extended by specialized option classes
    % (e.g., ExpOptions, PermOptions, etc.).
    %
    % Being a handle class ensures that options are shared by reference
    % across all components (Effect, Tasks, Context).
    %

    properties
        % Numeric threshold used to evaluate the success of the analysis.
        threshold (1,1) double

        % Flag indicating whether to generate plots during analysis.
        showPlot (1,1) logical

        % Tolerance on the objective function for optimization algorithms.
        tolFun (1,1) double

        % Maximum number of iterations allowed in optimization procedures.
        maxIter (1,1) double
    end

    methods
        function obj = BaseOptions()
            % Constructor of BaseOptions
            % 
            % Initialize the default values of options with standard value.

            obj.threshold = 0.95;
            obj.showPlot = false;
            obj.tolFun = 1e-6;
            obj.maxIter = 1000;
        end
    end 
end
