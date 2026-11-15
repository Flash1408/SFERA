classdef RungePeakCheckTask < Task
    % RungePeakCheckTask
    %
    % Task responsible for verifying the number of significant peaks
    % detected in the input signal during Runge-like effect analysis.
    %
    % This task evaluates the preprocessed signal using MATLAB's
    % findpeaks function to determine whether it contains the expected
    % number of peaks.
    %
    % The validation criterion is:
    %   - Exactly one significant peak must be detected.
    %
    % The minimum peak prominence is defined as 5% of the input signal
    % range, preserving the criterion adopted by the legacy isRunge
    % function.
    %
    % Signals that do not satisfy this criterion are rejected before
    % the subsequent shape validation tasks.

    methods
        function obj = RungePeakCheckTask()
            % RUNGEPEAKCHECKTASK Constructs a Runge peak-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("RungePeakCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Evaluates whether the input signal contains
            % exactly one significant peak.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the
            %              preprocessed input signal.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the peak
            %         validation was successfully executed.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Retrieves the preprocessed input signal.
            %   3. Computes the minimum peak prominence as 5% of
            %      the input signal range.
            %   4. Detects the peaks using MATLAB's findpeaks function.
            %   5. Checks that exactly one peak has been detected.
            %
            % If the expected number of peaks is not detected,
            % context.result is set to false.

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('RungePeakCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Preserve a negative result established by a previous task.
            if ~context.result
                ok = true;
                return;
            end

            % Mark the peak validation as successfully executable.
            ok = true;

            % Retrieve the preprocessed input signal.
            y = context.y;

            % Compute the minimum peak prominence as 5% of the
            % input signal range.
            signalRange = max(y) - min(y);
            minPeakProminence = 0.05 * signalRange;

            % Detect peaks in the input signal.
            [pks, ~] = findpeaks(y, ...
                'MinPeakProminence', minPeakProminence);

            % Check that exactly one significant peak has been detected.
            if numel(pks) ~= 1
                context.result = false;
                return;
            end
        end
    end
end
