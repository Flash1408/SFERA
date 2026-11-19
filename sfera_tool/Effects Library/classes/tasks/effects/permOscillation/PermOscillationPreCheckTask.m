classdef PermOscillationPreCheckTask < Task
    % PermOscillationPreCheckTask
    %
    % Task responsible for performing preliminary signal checks
    % specific to permanent oscillation effect analysis.
    %
    % This task evaluates whether the input signal contains a
    % sufficient number of positive local maxima with adequate
    % amplitude and minimum separation.
    %
    % Signals that do not satisfy the peak-based criterion are
    % marked as ineligible for curve fitting. Spectral analysis
    % can still be performed independently.

    properties
        % Minimum number of peaks required for permanent oscillation analysis.
        minPeaks (1,1) double = 3

        % Minimum peak amplitude expressed as a fraction of signal range.
        amplitudeThreshold (1,1) double = 0.1

        % Minimum distance between consecutive accepted peaks.
        minPeakDistance (1,1) double = 100
    end

    methods
        function obj = PermOscillationPreCheckTask()
            % PERMOSCILLATIONPRECHECKTASK Constructs a permanent
            % oscillation pre-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("PermOscillationPreCheckTask");
        end

        
        function ok = execute(obj, context)
            % EXECUTE Evaluates whether the input signal contains
            % sufficient peaks for attempting curve fitting.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the
            %              preprocessed input signal.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the preliminary
            %         check was successfully completed.
            %
            % The peak-based criterion determines whether curve fitting
            % is eligible. Failure to satisfy this criterion does not
            % interrupt the analysis pipeline, allowing spectral analysis
            % to proceed independently.
        
            ok = false;
        
            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('PermOscillationPreCheckTask:InvalidContext', ...
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
        
            % Determine whether the signal is eligible for curve fitting.
            context.fitEligible = numel(peaksIdx) >= obj.minPeaks;
        
            % Mark the preliminary check as successfully completed.
            ok = true;
        end

    end
end
