classdef BaseOptions < handle
    % BaseOptions
    %
    % Abstractly shared configuration container for effect analysis.
    %
    % This class defines the common configuration parameters used by
    % effects and their execution tasks.
    %
    % It provides default values for general analysis settings and
    % serves as the base class for specialized option classes
    % (e.g., ExpOptions, ArcTanOptions).
    %
    % BaseOptions inherits from handle so that configuration parameters
    % are shared by reference across effects, tasks, and the EffectContext.

    properties
        % Minimum goodness-of-fit threshold required to accept an effect.
        threshold (1,1) double

        % Enables or disables plot generation during analysis.
        showPlot (1,1) logical

        % Tolerance on the objective function used by optimization algorithms.
        tolFun (1,1) double

        % Maximum number of iterations allowed in optimization procedures.
        maxIter (1,1) double

        % Maximum number of objective function evaluations allowed
        % during optimization procedures.
        maxFunEvals (1,1) double
    end

    methods
        function obj = BaseOptions()
            % BASEOPTIONS Initializes the default configuration parameters.
            %
            % The default values provide a common configuration that
            % can be inherited or customized by specialized option classes.

            obj.threshold = 0.95;
            obj.showPlot = false;
            obj.tolFun = 1e-6;
            obj.maxIter = 1000;
            obj.maxFunEvals = 5000;
        end
    end
end
