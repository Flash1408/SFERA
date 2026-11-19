classdef DivOscillationEffect < BaseEffect
    % DivOscillationEffect
    %
    % Effect detector responsible for identifying divergent oscillations
    % in an input signal.
    %
    % The effect is modeled by:
    %
    %   y(t) = A * exp(beta*t) * cos(omega*t + phi)
    %
    % The parameter vector is defined as:
    %   p(1) -> A: initial oscillation amplitude.
    %   p(2) -> beta: exponential growth coefficient.
    %   p(3) -> omega: angular frequency.
    %   p(4) -> phi: initial phase.
    %
    % A positive beta indicates an exponentially increasing
    % oscillation amplitude.
    %
    % The analysis pipeline consists of preprocessing, preliminary
    % peak validation, model fitting, divergence validation,
    % R-squared computation, acceptance checking, and optional plotting.

    methods
        function model = getModel(~)
            % GETMODEL Returns the divergent oscillation model.
            %
            % OUTPUT:
            %   model -> Function handle representing the divergent
            %            oscillation model.
            %
            % The model describes an oscillatory signal whose
            % amplitude increases exponentially over time.

            model = @(p,t) p(1) .* exp(p(2) .* t) .* ...
                cos(p(3) .* t + p(4));
        end

        function params0 = getInitialParams(~, y, t, opt)
            % getInitialParams
            %
            % Computes the initial parameter estimates for divergent
            % oscillation fitting.
            %
            % The amplitude is estimated from the maximum absolute signal
            % value, while the angular frequency is estimated from the
            % average time interval between consecutive positive peaks.
            %
            % The frequency estimation uses the same peak detection
            % criteria as DivOscillationPreCheckTask.

            % Validate the options object.
            if ~isa(opt, 'DivOscillationOptions') || ~isscalar(opt)
                error('DivOscillationEffect:InvalidOptions', ...
                    'Options must be a scalar DivOscillationOptions object.');
            end

            % Start from the default parameter estimates.
            params0 = opt.params0;

            % Estimate the initial amplitude.
            params0(1) = max(abs(y));

            % Detect positive peaks using the same criteria as the
            % preliminary signal analysis.
            localRange = max(y) - min(y);
            amplitudeThreshold = 0.1 * localRange;
            minPeakDistance = 100;

            [~, peaksIdx] = findMaxPeaks( ...
                y, amplitudeThreshold, minPeakDistance);

            % Estimate the angular frequency from the peak-to-peak
            % time intervals.
            if numel(peaksIdx) >= 2
                peakTimes = t(peaksIdx);
                periods = diff(peakTimes);

                validPeriods = periods(isfinite(periods) & periods > 0);

                if ~isempty(validPeriods)
                    estimatedPeriod = median(validPeriods);
                    params0(3) = 2 * pi / estimatedPeriod;
                end
            end
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Defines the task pipeline for divergent oscillation analysis.
            %
            % The pipeline performs the following operations:
            %   1. Preprocess the input signal.
            %   2. Check the presence of significant local maxima.
            %   3. Fit the divergent oscillation model.
            %   4. Verify that the estimated growth coefficient is positive.
            %   5. Compute the coefficient of determination.
            %   6. Check the fitting quality against the acceptance threshold.
            %   7. Optionally plot the original and fitted signals.

            obj.addTask(PreprocessTask());
            obj.addTask(DivOscillationPreCheckTask());
            obj.addTask(FitModelTask(obj));
            obj.addTask(DivOscillationPostCheckTask());
            obj.addTask(R2ComputationTask());
            obj.addTask(PostCheckTask());
            obj.addTask(PlotTask());
        end
    end
end
