classdef EffectContext < handle
    % EffectContext
    %
    % Shared data container for the effect execution pipeline.
    %
    % This class stores the input data, configuration parameters, and
    % intermediate results required during effect analysis.
    %
    % The same context instance is passed to every Task, allowing them
    % to:
    %   - access the input signal and time vector
    %   - retrieve the effect configuration
    %   - store intermediate fitting results
    %   - update the final analysis result
    %
    % EffectContext inherits from handle so that all tasks operate on
    % the same shared data instance.

    properties
        % Input signal and corresponding time samples (column vectors).
        y (:,1) double
        t (:,1) double

        % Model function used for parameter estimation.
        model

        % Initial and fitted model parameters.
        params0 double
        params_fit double

        % Signal estimated using the fitted model.
        y_fit double

        % Coefficient of determination of the fitted model.
        R2 (1,1) double

        % Indicates whether the analyzed effect has been recognized.
        result (1,1) logical

        % Configuration parameters shared among pipeline tasks.
        options (1,1) BaseOptions
    end

    methods
        function obj = EffectContext(y, t, options)
            % EFFECTCONTEXT Initializes the shared analysis context.
            %
            % INPUT:
            %   y       -> input signal represented as a double vector.
            %   t       -> time vector containing the corresponding
            %              sampling instants.
            %   options -> scalar BaseOptions object containing the
            %              configuration parameters for the analysis.
            %
            % The constructor validates the input data, converts the
            % signal and time vectors into column vectors, and initializes
            % the fields that will be populated during task execution.

            % Validate input data.
            if ~isa(y, 'double') || ~isvector(y) || ...
                    ~isa(t, 'double') || ~isvector(t)
                error("EffectContext:InvalidInput", ...
                    "The signal and time must be double vectors.");
            end

            if numel(y) ~= numel(t)
                error("EffectContext:InvalidInput", ...
                    "The signal and time vector must contain the same number of samples.");
            end

            if ~isa(options, 'BaseOptions') || ~isscalar(options)
                error("EffectContext:InvalidOptions", ...
                    "Options must be a scalar BaseOptions object.");
            end

            % Standardize input data as column vectors.
            obj.y = y(:);
            obj.t = t(:);

            % Store configuration parameters.
            obj.options = options;

            % Initialize fields populated during task execution.
            obj.model = [];
            obj.params0 = [];
            obj.params_fit = [];
            obj.y_fit = [];
            obj.R2 = NaN;
            obj.result = false;
        end
    end
end
