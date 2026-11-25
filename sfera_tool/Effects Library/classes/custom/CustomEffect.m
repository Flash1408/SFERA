classdef CustomEffect < BaseEffect
    % CustomEffect
    %
    % Concrete effect class implementing the analysis of a user-defined
    % model.
    %
    % The model definition is provided through a UserModel object.
    % CustomEffect adapts this definition to the common BaseEffect
    % interface and reuses the existing analysis task pipeline.
    %
    % Model fitting, goodness-of-fit evaluation, and plotting are
    % delegated to the corresponding task classes.

    properties (SetAccess = private)
        % Definition of the custom model used during the analysis.
        userModel (1,1) UserModel
    end

    methods
        function obj = CustomEffect(userModel, options)
            % CUSTOMEFFECT Constructs an effect based on a UserModel.
            %
            % INPUT:
            %   userModel -> Scalar UserModel containing the model
            %                function, initial parameters, and bounds.
            %   options   -> Scalar BaseOptions object containing the
            %                general analysis configuration.
            %
            % The constructor creates a CustomOptions object combining
            % the general configuration with the model-specific parameters.

            obj@BaseEffect();

            % Validate the custom model definition.
            if ~isa(userModel, 'UserModel') || ~isscalar(userModel) || ...
                    ~userModel.validateModel()

                error('CustomEffect:InvalidUserModel', ...
                    'A valid scalar UserModel object is required.');
            end

            % Validate the general analysis configuration.
            if ~isa(options, 'BaseOptions') || ~isscalar(options)
                error('CustomEffect:InvalidOptions', ...
                    'Options must be a scalar BaseOptions object.');
            end

            obj.userModel = userModel;

            % Create the specialized options object.
            customOptions = CustomOptions();

            % Copy the general analysis configuration.
            customOptions.threshold = options.threshold;
            customOptions.showPlot = options.showPlot;
            customOptions.tolFun = options.tolFun;
            customOptions.maxIter = options.maxIter;
            customOptions.maxFunEvals = options.maxFunEvals;

            % Copy the model-specific configuration.
            customOptions.params0 = userModel.initialParams(:)';
            customOptions.lb = userModel.lb(:)';
            customOptions.ub = userModel.ub(:)';

            % Configure the inherited analysis pipeline.
            obj.setOptions(customOptions);
        end

        function model = getModel(obj)
            % GETMODEL Returns the user-defined model function.
            %
            % OUTPUT:
            %   model -> Function handle representing the custom model.
            %
            % The expected function signature is:
            %   yFit = model(params, t)

            model = obj.userModel.modelFunction;
        end

        function params0 = getInitialParams(~, ~, ~, opt)
            % GETINITIALPARAMS Returns the initial fitting parameters.
            %
            % INPUT:
            %   opt -> Scalar CustomOptions object.
            %
            % OUTPUT:
            %   params0 -> Initial parameter vector for model fitting.

            if ~isa(opt, 'CustomOptions') || ~isscalar(opt)
                error('CustomEffect:InvalidOptions', ...
                    'Options must be a scalar CustomOptions object.');
            end

            params0 = opt.params0;
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Defines the task pipeline for custom
            % effect analysis.
            %
            % The pipeline performs the following operations:
            %   1. Preprocess the input signal.
            %   2. Fit the user-defined model.
            %   3. Compute the coefficient of determination.
            %   4. Check the fitting quality against the acceptance threshold.
            %   5. Optionally execute the user-defined post-check.
            %   6. Optionally plot the original and fitted signals.

            obj.addTask(PreprocessTask());
            obj.addTask(FitModelTask(obj));
            obj.addTask(R2ComputationTask());
            obj.addTask(PostCheckTask());

            if obj.userModel.requiresPostCheck
                obj.addTask(CustomPostCheckTask(obj.userModel));
            end

            obj.addTask(PlotTask());
        end
    end
end
