classdef FitModelTask < Task
    % FitModelTask
    %
    % Task responsible for estimating the parameters of an effect model
    % using nonlinear least-squares optimization.
    %
    % This task retrieves the model function and its initial parameter
    % estimates from the corresponding BaseEffect object, performs the
    % fitting procedure using the bounds and solver configuration stored
    % in EffectContext, and stores the resulting estimates in the shared
    % context.
    %
    % The fitting results are made available to subsequent tasks for
    % goodness-of-fit evaluation and effect validation.

    properties (Access = private)
        % Effect object providing the model and initial parameter estimates.
        effect
    end

    methods
        function obj = FitModelTask(effect)
            % FITMODELTASK Constructs a model-fitting task.
            %
            % INPUT:
            %   effect -> Scalar BaseEffect object providing the model
            %             function and initial parameter estimates.
            %
            % The constructor validates and stores the effect object
            % required by the fitting procedure.

            obj = obj@Task("FitModelTask");

            if ~isa(effect, 'BaseEffect') || ~isscalar(effect)
                error('FitModelTask:InvalidEffect', ...
                    'The effect must be a scalar BaseEffect object.');
            end

            obj.effect = effect;
        end

        function ok = execute(obj, context)
            % EXECUTE Estimates the parameters of the effect model.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the input
            %              signal, time vector and fitting options.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether model fitting
            %         completed successfully.
            %
            % The method:
            %   1. Validates the analysis context and fitting options.
            %   2. Retrieves the model and initial parameters from the effect.
            %   3. Validates the initial parameters and optimization bounds.
            %   4. Configures and executes the nonlinear least-squares solver.
            %   5. Evaluates the fitted model at the input time samples.
            %   6. Stores the fitting results in the shared context.
            %
            % If fitting fails or produces non-finite results,
            % context.result is set to false.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('FitModelTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            if ~isa(context.options, 'BaseOptions') || ...
                    ~isscalar(context.options)
                error('FitModelTask:InvalidOptions', ...
                    'The context must contain a scalar BaseOptions object.');
            end

            opt = context.options;

            if ~isprop(opt, 'lb') || ~isprop(opt, 'ub')
                error('FitModelTask:InvalidOptions', ...
                    'The options must define lower and upper bounds (lb and ub).');
            end

            y = context.y;
            t = context.t;

            % Ensure that the signal and time vectors are compatible.
            if numel(y) ~= numel(t) || numel(y) < 5
                context.result = false;
                return;
            end

            % Retrieve the model provided by the effect.
            model = obj.effect.getModel();

            % Ensure that the effect provides a valid model function.
            if ~isa(model, 'function_handle')
                error('FitModelTask:InvalidModel', ...
                    'The effect must provide a valid model function.');
            end

            % Compute the initial parameters for the fitting procedure.
            params0 = obj.effect.getInitialParams(y, opt);

            % Validate the initial parameters and optimization bounds.
            % All three vectors must be numeric and have the same number of elements.
            if ~isnumeric(params0) || ~isvector(params0) || isempty(params0) || ...
                    ~isnumeric(opt.lb) || ~isvector(opt.lb) || ...
                    ~isnumeric(opt.ub) || ~isvector(opt.ub) || ...
                    numel(params0) ~= numel(opt.lb) || ...
                    numel(params0) ~= numel(opt.ub)

                error('FitModelTask:InvalidParameters', ...
                    'Initial parameters and bounds must be numeric vectors of equal length.');
            end

            % Ensure that parameters and bounds contain valid real values.
            % Infinite bounds are allowed, but NaN values are not.
            if ~isreal(params0) || any(~isfinite(params0)) || ...
                    ~isreal(opt.lb) || any(isnan(opt.lb)) || ...
                    ~isreal(opt.ub) || any(isnan(opt.ub))

                error('FitModelTask:InvalidParameters', ...
                    'Parameters and bounds must contain valid real values.');
            end

            % Verify that the initial parameters satisfy the specified bounds.
            if any(opt.lb > opt.ub) || ...
                    any(params0 < opt.lb) || any(params0 > opt.ub)

                error('FitModelTask:InvalidParameters', ...
                    'Initial parameters must lie within the specified bounds.');
            end

            % Validate the solver configuration parameters.
            if ~isnumeric(opt.tolFun) || ~isscalar(opt.tolFun) || ...
                    ~isfinite(opt.tolFun) || opt.tolFun <= 0 || ...
                    ~isnumeric(opt.maxIter) || ~isscalar(opt.maxIter) || ...
                    ~isfinite(opt.maxIter) || opt.maxIter < 1 || ...
                    fix(opt.maxIter) ~= opt.maxIter

                error('FitModelTask:InvalidOptions', ...
                    'Solver tolerances and iteration limits must contain valid values.');
            end

            % Configure the nonlinear least-squares solver.
            solverOptions = optimoptions('lsqcurvefit', ...
                'Display', 'off', ...
                'TolFun', opt.tolFun, ...
                'MaxIterations', opt.maxIter);

            try
                % Estimate the model parameters within the specified bounds.
                paramsFit = lsqcurvefit( ...
                    model, params0, t, y, ...
                    opt.lb, opt.ub, solverOptions);

                % Evaluate the fitted model at the input time samples.
                yFit = model(paramsFit, t);

                if any(~isfinite(paramsFit)) || any(~isfinite(yFit))
                    context.result = false;
                    return;
                end

                % Store the fitting results for subsequent tasks.
                context.model = model;
                context.params0 = params0;
                context.params_fit = paramsFit;
                context.y_fit = yFit;

                ok = true;

            catch
                % Report fitting failure through the task result.
                context.result = false;
                return;
            end
        end
    end
end
