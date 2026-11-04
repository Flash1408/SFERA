classdef PostCheckTask < Task
    % PostCheckTask
    %
    % Task responsible for evaluating the goodness of fit of an estimated
    % model against the acceptance threshold defined in BaseOptions.
    %
    % This task retrieves the coefficient of determination (R-squared)
    % and the configured threshold from the shared EffectContext.
    %
    % The analysis result is stored in context.result:
    %   - true if R-squared is finite and exceeds the threshold.
    %   - false otherwise.
    %
    % A rejected effect does not imply that task execution has failed.
    % The task returns true when the validation is completed successfully.

    methods
        function obj = PostCheckTask()
            % POSTCHECKTASK Constructs a post-fitting validation task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("PostCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Checks whether the fitted model satisfies the
            % configured goodness-of-fit threshold.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the R-squared
            %              value and analysis options.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the validation
            %         task was executed successfully.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Retrieves R-squared and the configured threshold.
            %   3. Rejects undefined or non-finite R-squared values.
            %   4. Compares R-squared against the acceptance threshold.
            %
            % The validation outcome is stored in context.result.
            % Task execution can succeed even when the effect is rejected.

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

            % Accept the effect only if R-squared exceeds the threshold.
            context.result = r2 > threshold;
            ok = true;
        end

    end
end
