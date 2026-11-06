classdef FitModelTask < Task
    % FitModelTask
    %
    % Task responsible for estimating the parameters of an effect model
    % through bounded nonlinear least-squares optimization.
    %
    % This task retrieves the model function and initial parameter
    % estimates from the corresponding BaseEffect object, validates the
    % fitting configuration, and executes the optimization procedure
    % using the solver options and parameter bounds stored in EffectContext.
    %
    % After a successful optimization, the fitted model is evaluated at
    % the input time samples and the resulting parameters and estimated
    % signal are stored in the shared context.
    %
    % Solver termination information and fitting errors are also stored
    % in EffectContext to support diagnostic inspection.
    %
    % The fitting results are made available to subsequent tasks for
    % goodness-of-fit computation and effect validation.

    properties (Access = private)
        % BaseEffect object providing the model function and initial
        % parameter estimates required by the fitting procedure.
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
            % The constructor initializes the task identifier and
            % validates the effect object required by the fitting
            % procedure.

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
            %   context -> Scalar EffectContext object containing the
            %              input signal, time vector and fitting options.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the fitting task
            %         completed successfully.
            %
            % The method:
            %   1. Validates the analysis context and fitting options.
            %   2. Retrieves the model and initial parameters from the effect.
            %   3. Validates the initial parameters and optimization bounds.
            %   4. Validates the solver configuration.
            %   5. Configures and executes the nonlinear least-squares solver.
            %   6. Checks the solver termination status and stores diagnostic
            %      information in the shared context.
            %   7. Evaluates the fitted model at the input time samples.
            %   8. Validates and stores the fitting results in the context.
            %
            % The task is considered successful only if the solver
            % terminates with a positive exit flag and the fitted model
            % produces a valid output signal.
            %
            % If the solver does not converge or the fitting procedure
            % fails, context.result is set to false. Solver diagnostics
            % and fitting errors are preserved in EffectContext whenever
            % available.

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
            % All three vectors must be numeric and have the same number
            % of elements.
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
            % Tolerances must be positive, while iteration and function
            % evaluation limits must be positive integer values.
            if ~isnumeric(opt.tolFun) || ~isscalar(opt.tolFun) || ...
                    ~isfinite(opt.tolFun) || opt.tolFun <= 0 || ...
                    ~isnumeric(opt.maxIter) || ~isscalar(opt.maxIter) || ...
                    ~isfinite(opt.maxIter) || opt.maxIter < 1 || ...
                    fix(opt.maxIter) ~= opt.maxIter || ...
                    ~isnumeric(opt.maxFunEvals) || ~isscalar(opt.maxFunEvals) || ...
                    ~isfinite(opt.maxFunEvals) || opt.maxFunEvals < 1 || ...
                    fix(opt.maxFunEvals) ~= opt.maxFunEvals

                error('FitModelTask:InvalidOptions', ...
                    'Solver tolerances and iteration limits must contain valid values.');
            end

            % Configure the nonlinear least-squares solver.
            solverOptions = optimoptions('lsqcurvefit', ...
                'Display', 'off', ...
                'TolFun', opt.tolFun, ...
                'MaxIterations', opt.maxIter, ...
                'MaxFunctionEvaluations', opt.maxFunEvals);

            try
                % Estimate the model parameters within the specified bounds.
                [paramsFit, ~, ~, exitflag, output] = lsqcurvefit( ...
                    model, params0, t, y, ...
                    opt.lb, opt.ub, solverOptions);

                % Store solver termination information for diagnostics.
                context.fitExitFlag = exitflag;
                context.fitOutput = output;

                % Reject the fitting if the solver did not converge.
                if exitflag <= 0
                    context.result = false;
                    return;
                end

                % Evaluate the fitted model at the input time samples.
                yFit = model(paramsFit, t);

                % Ensure that the fitted signal is a real numeric vector.
                if ~isnumeric(yFit) || ~isreal(yFit) || ~isvector(yFit)
                    context.result = false;
                    return;
                end

                % Ensure that the fitted parameters and signal contain
                % only finite values and that the signal has the expected
                % number of samples.
                if numel(yFit) ~= numel(y) || ...
                        any(~isfinite(paramsFit)) || any(~isfinite(yFit))
                    context.result = false;
                    return;
                end

                % Store the fitting results for subsequent tasks.
                context.model = model;
                context.params0 = params0;
                context.params_fit = paramsFit;
                context.y_fit = yFit;

                ok = true;

            catch ME
                % Store the fitting error for diagnostic purposes.
                context.fitError = string(ME.message);

                % Report fitting failure through the task result.
                context.result = false;
                return;
            end
        end
    end
end
