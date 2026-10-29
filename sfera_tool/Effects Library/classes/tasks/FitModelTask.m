classdef FitModelTask < Task
    % FitModelTask estimates the parameters of an effect model.
    %
    % This task retrieves the model and its initial parameters from the
    % corresponding effect, performs the curve fitting, and stores the
    % results in the analysis context.

    properties (Access = private)
        effect
    end

    methods
        function obj = FitModelTask(effect)
            % Initializes the task with the effect to be analyzed.

            obj = obj@Task("FitModelTask");

            if ~isa(effect, 'BaseEffect') || ~isscalar(effect)
                error('FitModelTask:InvalidEffect', ...
                    'The effect must be a scalar BaseEffect object.');
            end

            obj.effect = effect;
        end

        function ok = execute(obj, context)
            % Fits the model using the data and options stored in context.
            %
            % The fitted model, parameters, and estimated signal are
            % stored in context for subsequent tasks.

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

            % Configure the nonlinear least-squares solver.
            solverOptions = optimoptions('lsqcurvefit', ...
                'Display', 'off', ...
                'TolFun', opt.tolFun, ...
                'MaxIterations', opt.maxIter);

            % Validate the solver configuration parameters.
            if ~isnumeric(opt.tolFun) || ~isscalar(opt.tolFun) || ...
                    ~isfinite(opt.tolFun) || opt.tolFun <= 0 || ...
                    ~isnumeric(opt.maxIter) || ~isscalar(opt.maxIter) || ...
                    ~isfinite(opt.maxIter) || opt.maxIter < 1 || ...
                    fix(opt.maxIter) ~= opt.maxIter

                error('FitModelTask:InvalidOptions', ...
                    'Solver tolerances and iteration limits must contain valid values.');
            end

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