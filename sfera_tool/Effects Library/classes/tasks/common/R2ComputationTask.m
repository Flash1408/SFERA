classdef R2ComputationTask < Task
    % R2ComputationTask
    %
    % Task responsible for computing the coefficient of determination
    % (R-squared) to evaluate the goodness of fit of an estimated model.
    %
    % The coefficient is computed by comparing the observed signal with
    % the signal estimated by the fitted model.
    %
    % The resulting value is stored in the shared EffectContext and is
    % used by subsequent tasks to evaluate whether the fitted model
    % satisfies the required goodness-of-fit threshold.
    %
    % If the total variability of the observed signal is zero, R-squared
    % is undefined and is stored as NaN.

    methods
        function obj = R2ComputationTask()
            % R2COMPUTATIONTASK Constructs an R-squared computation task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("R2ComputationTask");
        end

        function ok = execute(~, context)
            % EXECUTE Computes the coefficient of determination.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the observed
            %              signal and the fitted signal.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the computation
            %         was completed successfully.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Checks the availability and consistency of the
            %      observed and fitted signals.
            %   3. Verifies that both signals contain finite values.
            %   4. Computes the residual and total sums of squares.
            %   5. Stores the resulting R-squared value in context.R2.
            %
            % If the input data are invalid or the fitted signal is
            % unavailable, context.result is set to false.
            % A constant observed signal produces an undefined R-squared
            % value (NaN), without causing the task execution to fail.

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

            % Ensure that both signals contain only finite values.
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

            % Mark the computation as successfully completed.
            ok = true;
        end
    end
end
