classdef ArcTanPostCheckTask < Task
    % ArcTanPostCheckTask
    %
    % Task responsible for performing a final validation specific to
    % arc-tangent effect analysis after model fitting.
    %
    % This task evaluates whether the amplitude of the fitted
    % arc-tangent model is sufficiently large compared to the range
    % of the original input signal.
    %
    % The task can only reject an effect that has not already been
    % rejected by a previous validation stage. An existing negative
    % analysis result is therefore preserved.

    methods
        function obj = ArcTanPostCheckTask()
            % ARCTANPOSTCHECKTASK Constructs an arc-tangent post-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("ArcTanPostCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Validates the amplitude of the fitted arc-tangent model.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the original
            %              signal, fitted parameters and current analysis
            %              result.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the validation
            %         task was executed successfully.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Checks the availability and validity of the four
            %      fitted model parameters.
            %   3. Computes the range of the original signal.
            %   4. Compares the absolute fitted amplitude with 20% of
            %      the original signal range.
            %
            % The analysis result is rejected if the fitted amplitude
            % is insufficient and no previous validation has rejected
            % the effect.
            %
            % A rejected effect does not imply that task execution failed.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('ArcTanPostCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Validate the fitted model parameters.
            if ~isnumeric(context.params_fit) || ...
                    ~isvector(context.params_fit) || ...
                    numel(context.params_fit) ~= 4 || ...
                    ~isreal(context.params_fit) || ...
                    any(~isfinite(context.params_fit))
                error('ArcTanPostCheckTask:InvalidParameters', ...
                    'The context must contain four valid fitted parameters.');
            end

            % Retrieve the fitted parameters and the original signal range.
            paramsFit = context.params_fit;
            localRange = max(context.y) - min(context.y);

            % Reject the effect if its fitted amplitude is too small.
            % Preserve any rejection performed by previous validation tasks.
            A_fit = abs(paramsFit(1));

            if context.result && A_fit < 0.2 * localRange
                context.result = false;
            end

            % Mark the validation task as successfully completed.
            ok = true;
        end
    end
end
