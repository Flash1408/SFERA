classdef ArcTanPostCheckTask < Task
    % ArcTanPostCheckTask performs a final check specific to the
    % arc-tangent effect after model fitting.

    methods
        function obj = ArcTanPostCheckTask()
            % Initializes the task with its name.
            obj = obj@Task("ArcTanPostCheckTask");
        end

        function ok = execute(~, context)
            % Checks whether the fitted arc-tangent model has a
            % sufficiently large amplitude.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('ArcTanPostCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

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

            % Check whether the fitted amplitude is sufficiently large.
            A_fit = abs(paramsFit(1));

            if A_fit < 0.2 * localRange
                context.result = false;
            else
                context.result = true;
            end

            ok = true;
        end
    end
end