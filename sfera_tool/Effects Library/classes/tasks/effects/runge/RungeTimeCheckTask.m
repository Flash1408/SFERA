classdef RungeTimeCheckTask < Task
    % RungeTimeCheckTask
    %
    % Task responsible for validating the time vector before
    % Runge-like effect analysis.
    %
    % The Runge model internally normalizes the time vector to
    % the interval [0, 1]. This operation requires a non-zero
    % time interval.
    %
    % Signals whose time vectors contain no temporal variation
    % are rejected before model fitting.

    methods
        function obj = RungeTimeCheckTask()
            % RUNGETIMECHECKTASK Constructs a Runge time check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("RungeTimeCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Checks whether the time vector has a non-zero range.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the
            %              preprocessed signal and time vector.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the check
            %         was successfully executed.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Retrieves the time vector.
            %   3. Checks that at least two distinct time values exist.
            %
            % If the time interval is zero, context.result is set
            % to false.

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('RungeTimeCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Preserve a negative result established by a previous task.
            if ~context.result
                ok = true;
                return;
            end

            % Mark the check as successfully executable.
            ok = true;

            % Retrieve the preprocessed time vector.
            t = context.t;

            % Reject signals with no temporal variation.
            if isempty(t) || max(t) == min(t)
                context.result = false;
                return;
            end
        end
    end
end
