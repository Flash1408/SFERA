classdef UserModel < handle
    % UserModel
    %
    % Configuration container for user-defined mathematical models.
    %
    % This class stores the information required to define a custom
    % parametric model, including its mathematical function, initial
    % parameter estimates, fitting bounds, and optional post-fit check.
    %
    % UserModel separates model definition from effect execution:
    % the actual analysis is performed by CustomEffect.

    properties
        % Mathematical model function.
        % Expected signature: y = modelFunction(params, t).
        modelFunction

        % Initial parameter estimates for nonlinear least-squares fitting.
        initialParams double

        % Lower and upper bounds for model parameters.
        lb double
        ub double

        % Model identification and documentation.
        modelName string
        description string

        % Indicates whether an additional post-fit validation is required.
        requiresPostCheck (1,1) logical

        % User-defined post-fit validation function.
        customPostCheck
    end

    methods
        function obj = UserModel()
            % USERMODEL Initializes an empty custom model definition.
            %
            % Properties are initialized with neutral default values.
            % A complete configuration must be provided before the model
            % can be used for effect analysis.

            obj.modelFunction = [];
            obj.initialParams = [];
            obj.lb = [];
            obj.ub = [];
            obj.modelName = "";
            obj.description = "";
            obj.requiresPostCheck = false;
            obj.customPostCheck = [];
        end

        function isValid = validateModel(obj)
            % VALIDATEMODEL Checks whether the custom model definition
            % contains a valid and consistent configuration.
            %
            % RETURNS:
            %   isValid -> true if the model configuration is valid,
            %              false otherwise.

            isValid = false;

            % Validate the mathematical model function.
            if ~isa(obj.modelFunction, 'function_handle') || ...
                    ~isscalar(obj.modelFunction)
                return;
            end

            % Validate initial parameter estimates.
            if ~isnumeric(obj.initialParams) || ...
                    ~isreal(obj.initialParams) || ...
                    ~isvector(obj.initialParams) || ...
                    isempty(obj.initialParams) || ...
                    any(~isfinite(obj.initialParams(:)))
                return;
            end

            % Validate fitting bounds.
            if ~isnumeric(obj.lb) || ~isnumeric(obj.ub) || ...
                    ~isreal(obj.lb) || ~isreal(obj.ub) || ...
                    ~isvector(obj.lb) || ~isvector(obj.ub) || ...
                    isempty(obj.lb) || isempty(obj.ub)
                return;
            end

            % Standardize parameter vectors as row vectors.
            params0 = obj.initialParams(:)';
            lb = obj.lb(:)';
            ub = obj.ub(:)';

            % Check for invalid bound values.
            if any(isnan(lb)) || any(isnan(ub))
                return;
            end

            % Check parameter vector dimensions.
            if numel(params0) ~= numel(lb) || ...
                    numel(params0) ~= numel(ub)
                return;
            end

            % Check consistency of lower and upper bounds.
            if any(lb > ub)
                return;
            end

            % Check that initial parameters satisfy the fitting bounds.
            if any(params0 < lb) || any(params0 > ub)
                return;
            end

            % Validate model identification.
            if ~isstring(obj.modelName) || ...
                    ~isscalar(obj.modelName) || ...
                    strlength(strtrim(obj.modelName)) == 0
                return;
            end

            % Validate model description.
            if ~isstring(obj.description) || ~isscalar(obj.description)
                return;
            end

            % Validate post-fit check configuration.
            if ~islogical(obj.requiresPostCheck) || ...
                    ~isscalar(obj.requiresPostCheck)
                return;
            end

            if obj.requiresPostCheck
                if ~isa(obj.customPostCheck, 'function_handle') || ...
                        ~isscalar(obj.customPostCheck)
                    return;
                end
            end

            isValid = true;
        end
    end
end