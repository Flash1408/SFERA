classdef RungeMonotonicityCheckTask < Task
    % RungeMonotonicityCheckTask
    %
    % Task responsible for verifying that the input signal is not
    % monotonically increasing or decreasing during Runge-like
    % effect analysis.
    %
    % This task evaluates the differences between consecutive signal
    % samples to determine whether the signal exhibits at least one
    % change in direction.
    %
    % The validation criteria are:
    %   - The signal must not be monotonically increasing.
    %   - The signal must not be monotonically decreasing.
    %
    % Signals that do not satisfy these criteria are rejected before
    % the subsequent shape validation tasks.

    methods
        function obj = RungeMonotonicityCheckTask()
            % RUNGEMONOTONICITYCHECKTASK Constructs a Runge
            % monotonicity-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("RungeMonotonicityCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Evaluates whether the input signal is
            % monotonically increasing or decreasing.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the
            %              preprocessed input signal.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the
            %         monotonicity check was successfully executed.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Retrieves the preprocessed input signal.
            %   3. Computes the differences between consecutive samples.
            %   4. Checks whether all differences have the same
            %      nonnegative or nonpositive sign.
            %
            % If the input signal is monotonically increasing or
            % decreasing, context.result is set to false.

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('RungeMonotonicityCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Preserve a negative result established by a previous task.
            if ~context.result
                ok = true;
                return;
            end

            % Mark the monotonicity check as successfully executable.
            ok = true;

            % Retrieve the preprocessed input signal.
            y = context.y;

            % Compute the differences between consecutive samples.
            dy = diff(y);

            % Reject signals that are monotonically increasing
            % or monotonically decreasing.
            if all(dy >= 0) || all(dy <= 0)
                context.result = false;
                return;
            end
        end
    end
end
