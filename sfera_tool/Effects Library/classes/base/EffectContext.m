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
    % All tasks operate on the same context instance.

    properties
        % Input data (column vectors)
        y (:,1) double
        t (:,1) double

        % Model definition (assigned when needed)
        model

        % Parameters and intermediate results
        params0 double
        params_fit double
        y_fit double

        % Goodness-of-fit metric
        R2 (1,1) double

        % Execution result
        result (1,1) logical

        % Configuration
        options (1,1) BaseOptions
    end

    methods
        function obj = EffectContext(y, t, options)
            % Validate input data
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

            % Standardize input data as column vectors
            obj.y = y(:);
            obj.t = t(:);

            % Store configuration
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
