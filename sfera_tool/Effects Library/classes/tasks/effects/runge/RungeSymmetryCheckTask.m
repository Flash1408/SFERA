classdef RungeSymmetryCheckTask < Task
    % RungeSymmetryCheckTask
    %
    % Task responsible for verifying the approximate symmetry of the
    % input signal around the fitted peak center during Runge-like
    % effect analysis.
    %
    % This task divides the preprocessed signal into two portions,
    % corresponding to the left and right sides of the fitted peak
    % center, and compares their standard deviations.
    %
    % The validation criterion is:
    %   - The absolute difference between the standard deviations
    %     of the two signal portions must not exceed 30% of the
    %     standard deviation of the entire signal.
    %
    % Signals that do not satisfy this criterion are rejected.

    methods
        function obj = RungeSymmetryCheckTask()
            % RUNGESYMMETRYCHECKTASK Constructs a Runge symmetry-check
            % task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("RungeSymmetryCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Evaluates the approximate symmetry of the input
            % signal around the fitted peak center.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the
            %              preprocessed signal, time vector, and fitted
            %              parameters.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the symmetry
            %         check was successfully executed.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Retrieves the preprocessed signal, time vector, and
            %      fitted parameters.
            %   3. Normalizes the time vector to [0, 1].
            %   4. Identifies the sample closest to the fitted peak center.
            %   5. Divides the signal into left and right portions.
            %   6. Compares the standard deviations of the two portions.
            %
            % If the difference exceeds the accepted threshold, or if
            % either portion contains fewer than two samples,
            % context.result is set to false.
        
            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('RungeSymmetryCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end
        
            % Preserve a negative result established by a previous task.
            if ~context.result
                ok = true;
                return;
            end
        
            % Mark the symmetry check as successfully executable.
            ok = true;
        
            % Retrieve the preprocessed signal, time vector, and fitted parameters.
            y = context.y;
            t = context.t;
            params = context.params_fit;
        
            % Ensure that the fitted parameters are available and valid.
            if numel(params) ~= 4 || any(~isfinite(params))
                context.result = false;
                return;
            end
        
            % Retrieve the fitted peak center.
            C = params(3);
        
            % Normalize the time vector to the interval [0, 1].
            tNorm = (t - min(t)) ./ (max(t) - min(t));
        
            % Find the sample whose normalized time is closest to the
            % fitted peak center.
            [~, idxC] = min(abs(tNorm - C));
        
            % Ensure that both portions contain at least two samples,
            % as required for a meaningful standard deviation.
            if idxC < 2 || idxC >= numel(y)
                context.result = false;
                return;
            end
        
            % Divide the signal into its left and right portions.
            left = y(1:idxC);
            right = y(idxC:end);
        
            % Compare the standard deviations of the two portions.
            if abs(std(left) - std(right)) > 0.3 * std(y)
                context.result = false;
                return;
            end
        end
    end
end
