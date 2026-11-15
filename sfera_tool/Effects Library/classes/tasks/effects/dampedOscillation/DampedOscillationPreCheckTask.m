classdef DampedOscillationPreCheckTask < Task
    % DampedOscillationPreCheckTask
    %
    % Task responsible for performing preliminary signal checks
    % specific to damped oscillation effect analysis.
    %
    % This task evaluates whether the input signal contains a
    % sufficient number of positive local maxima with adequate
    % amplitude and minimum separation.
    %
    % Signals that do not satisfy the peak-based acceptance
    % criterion are rejected before the fitting stage.

    properties
        % Minimum number of peaks required for damped oscillation fitting.
        minPeaks (1,1) double = 3

        % Minimum peak amplitude expressed as a fraction of signal range.
        amplitudeThreshold (1,1) double = 0.1

        % Minimum distance between consecutive accepted peaks.
        minPeakDistance (1,1) double = 100
    end

    methods
        function obj = DampedOscillationPreCheckTask()
            % DAMPEDOSCILLATIONPRECHECKTASK Constructs a damped
            % oscillation pre-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("DampedOscillationPreCheckTask");
        end

        function ok = execute(obj, context)
            % EXECUTE Evaluates whether the input signal contains
            % sufficient peaks for damped oscillation model fitting.
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
            %   3. Determines the minimum peak amplitude.
            %   4. Identifies sufficiently separated positive local maxima.
            %   5. Checks whether the required number of peaks is present.
            %
            % If the signal does not satisfy the acceptance criterion,
            % context.result is set to false.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('DampedOscillationPreCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Retrieve the preprocessed signal from the analysis context.
            y = context.y;

            % Compute the signal range and minimum peak amplitude.
            localRange = max(y) - min(y);
            ampThreshold = obj.amplitudeThreshold * localRange;
            
            % Identify positive local maxima satisfying the amplitude
            % and minimum distance requirements.
            [~, peaksIdx] = findMaxPeaks(y, ampThreshold, obj.minPeakDistance);
            
            % Reject signals containing too few valid peaks.
            if numel(peaksIdx) < obj.minPeaks
                context.result = false;
                return;
            end

            % Mark the preliminary check as successfully completed.
            ok = true;
        end
    end
end