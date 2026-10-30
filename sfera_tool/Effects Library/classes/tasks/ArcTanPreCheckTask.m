classdef ArcTanPreCheckTask < Task
    % ArcTanPreCheckTask performs preliminary checks specific to the
    % arc-tangent effect before fitting the model.

    methods
        function obj = ArcTanPreCheckTask()
            % Initializes the task with its name.
            obj = obj@Task("ArcTanPreCheckTask");
        end

        function ok = execute(~, context)
            % Checks whether the input signal is suitable for arc-tangent
            % model fitting.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('ArcTanPreCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Retrieve the preprocessed signal from the analysis context.
            y = context.y;

            % Compute the signal range and its average second-order variation.
            localRange = max(y) - min(y);
            curv = mean(abs(diff(diff(y))));

            % Reject signals whose curvature is too small compared to their range.
            if curv < 0.001 * localRange
                context.result = false;
                return;
            end

            ok = true;
        end
    end
end