classdef RungePreCheckTask < Task
    % RungePreCheckTask
    %
    % Task responsible for performing preliminary parameter checks
    % specific to Runge-like effect analysis.
    %
    % This task evaluates the parameters estimated by the fitting stage
    % to determine whether they satisfy the fundamental characteristics
    % expected from a Runge-like signal.
    %
    % The checks include:
    %   - A minimum value for the parameter controlling peak width.
    %   - A minimum amplitude relative to the input signal range.
    %   - A peak center sufficiently far from the signal boundaries.
    %
    % Signals that do not satisfy these criteria are rejected before
    % the subsequent shape validation tasks.

    methods
        function obj = RungePreCheckTask()
            % RUNGEPRECHECKTASK Constructs a Runge pre-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("RungePreCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Evaluates whether the fitted Runge parameters
            % satisfy the preliminary acceptance criteria.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the
            %              preprocessed signal and fitted parameters.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the preliminary
            %         checks were successfully executed.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Retrieves the fitted parameters and input signal.
            %   3. Checks the minimum peak-width parameter.
            %   4. Checks the fitted amplitude relative to signal range.
            %   5. Checks that the peak center lies inside the
            %      accepted normalized interval.
            %
            % If any acceptance criterion is not satisfied,
            % context.result is set to false.

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('RungePreCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Preserve a negative result established by a previous task.
            if ~context.result
                ok = true;
                return;
            end

            % Mark the preliminary checks as successfully executable.
            ok = true;

            % Retrieve the preprocessed signal and fitted parameters.
            y = context.y;
            params = context.params_fit;

            % Ensure that fitted parameters are available and valid.
            if numel(params) ~= 4 || any(~isfinite(params))
                context.result = false;
                return;
            end

            A = params(1);
            B = params(2);
            C = params(3);

            % Compute the input signal range.
            localRange = max(y) - min(y);

            % Check that the peak-width parameter is sufficiently large.
            if B < 1
                context.result = false;
                return;
            end

            % Check that the fitted peak amplitude is sufficiently large
            % relative to the input signal range.
            if A < 0.05 * localRange
                context.result = false;
                return;
            end

            % Check that the fitted peak center is not too close
            % to either boundary of the normalized signal interval.
            if C < 0.1 || C > 0.9
                context.result = false;
                return;
            end
        end
    end
end
