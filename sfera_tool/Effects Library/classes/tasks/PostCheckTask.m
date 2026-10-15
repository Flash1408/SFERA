classdef PostCheckTask < Task
    % PostCheckTask evaluates the fitted model against the acceptance threshold.
    %
    % This task compares the R-squared value stored in the analysis
    % context with the threshold specified in the analysis options.
    % The analysis result is stored in context.result.

    methods
        function obj = PostCheckTask()
            % Initializes the task.
            obj = obj@Task("PostCheckTask");
        end

        
        function ok = execute(~, context)
            % Checks whether the fitted model satisfies the threshold.
            %
            % The task returns true if the check is completed.
            % The analysis result is stored in context.result.

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('PostCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            r2 = context.R2;
            threshold = context.options.threshold;

            % Reject undefined or non-finite R-squared values.
            if ~isfinite(r2)
                context.result = false;
                ok = true;
                return;
            end

            % Evaluate the acceptance criterion.
            context.result = r2 > threshold;
            ok = true;
        end

    end
end
