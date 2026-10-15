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

            if ~isa(effect, 'ExpEffect') || ~isscalar(effect)
                error('FitModelTask:InvalidEffect', ...
                    'The effect must be a scalar ExpEffect object.');
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

            if ~isa(context.options, 'ExpOptions') || ...
                    ~isscalar(context.options)
                error('FitModelTask:InvalidOptions', ...
                    'The context must contain a scalar ExpOptions object.');
            end

            y = context.y;
            t = context.t;
            opt = context.options;

            % Ensure that the signal and time vectors are compatible.
            if numel(y) ~= numel(t) || numel(y) < 5
                context.result = false;
                return;
            end

            % Retrieve the model and compute its initial parameters.
            model = obj.effect.getModel();
            params0 = obj.effect.getInitialParams(y, opt);

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