classdef ArcTanPreCheckTask < Task
    % ArcTanPreCheckTask
    %
    % Task responsible for performing preliminary signal checks specific
    % to arc-tangent effect analysis.
    %
    % This task evaluates the signal range and its average absolute
    % second-order finite difference to determine whether the input
    % signal exhibits sufficient variation for arc-tangent model fitting.
    %
    % Signals that do not satisfy the curvature-based acceptance
    % criterion are rejected before the fitting stage.

    methods
        function obj = ArcTanPreCheckTask()
            % ARCTANPRECHECKTASK Constructs an arc-tangent pre-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("ArcTanPreCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Evaluates whether the input signal is suitable
            % for arc-tangent model fitting.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the
            %              preprocessed input signal.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the preliminary
            %         check was successfully completed.
            %
            % The method:
            %   1. Retrieves the preprocessed signal.
            %   2. Computes its range.
            %   3. Computes the mean absolute second-order finite difference.
            %   4. Compares the resulting variation indicator against
            %      a threshold proportional to the signal range.
            %
            % If the signal does not satisfy the acceptance criterion,
            % context.result is set to false.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('ArcTanPreCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Retrieve the preprocessed signal from the analysis context.
            y = context.y;

            % Compute the signal range and average absolute
            % second-order finite difference.
            localRange = max(y) - min(y);
            curv = mean(abs(diff(diff(y))));

            % Reject signals with insufficient second-order variation
            % relative to their range.
            if curv < 0.001 * localRange
                context.result = false;
                return;
            end

            % Mark the preliminary check as successfully completed.
            ok = true;
        end
    end
end
