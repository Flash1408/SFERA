classdef EffectContext < handle
    % EffectContext 
    % 
    % Shared data container for the effect execution pipeline.
    %
    % This class stores all data required during the execution of an effect.
    % It is passed to each Task, allowing them to:
    %   - read input data
    %   - write intermediate results
    %   - update final outputs
    %
    % Being a handle class ensures that all tasks operate on the same
    % instance (shared state).

    properties
        % Input data
        y (1,:) double          % Signal values
        t (1,:) double          % Time vector

        % Model definition
        model function_handle   % Model function to be fitted

        % Parameters
        params0 (1,:) double    % Initial parameter guess
        params_fit (1,:) double % Estimated parameters after fitting

        % Outputs
        y_fit (1,:) double      % Model output using fitted parameters
        R2 (1,1) double         % Goodness-of-fit metric

        % Execution result
        result (1,1) logical    % Final success/failure flag

        % Configuration
        options (1,1) BaseOptions % Execution options
    end

    methods
        function obj = EffectContext(y, t, options)
            % Constructor of EffectContext
            %
            % Initializes the context with input data and options.
            %
            % INPUT:
            %   y -> signal values
            %   t -> time vector
            %   options -> configuration parameters
            %

            % Store input signal
            obj.y = y;

            % Store time vector
            obj.t = t;

            % Store configuration options
            obj.options = options;

            % Initialize optional fields
            obj.model = [];
            obj.params0 = [];
            obj.params_fit = [];
            obj.y_fit = [];
            obj.R2 = NaN;
            obj.result = false;
        end
    end
end