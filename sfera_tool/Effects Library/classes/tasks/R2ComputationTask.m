classdef R2ComputationTask < Task
    % R2ComputationTask computes the coefficient of determination.
    %
    % This task evaluates the quality of the fitted model by comparing
    % the observed signal with the signal estimated by the model.
    % The computed R-squared value is stored in the analysis context
    % for subsequent tasks.

    methods
        function obj = R2ComputationTask()
            % Initializes the task.
            obj = obj@Task("R2ComputationTask");
        end

        function ok = execute(~, context)
            % Computes R-squared using the observed and fitted signals.
            %
            % The result is stored in context.R2.
            % The task returns false if the input data are invalid or
            % if the fitted signal is unavailable.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('R2ComputationTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            y = context.y;
            yFit = context.y_fit;

            % Ensure that the observed and fitted signals are compatible.
            if isempty(yFit) || numel(y) ~= numel(yFit)
                context.result = false;
                return;
            end

            if any(~isfinite(y)) || any(~isfinite(yFit))
                context.result = false;
                return;
            end

            % Compute the residual and total sums of squares.
            residuals = y - yFit;
            SSR = sum(residuals.^2);
            SST = sum((y - mean(y)).^2);

            % Handle constant signals for which R-squared is undefined.
            if SST == 0
                context.R2 = NaN;
            else
                context.R2 = 1 - SSR / SST;
            end

            ok = true;
        end
    end
end

