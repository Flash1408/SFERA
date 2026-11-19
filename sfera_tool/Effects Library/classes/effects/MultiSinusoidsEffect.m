classdef MultiSinusoidsEffect < BaseEffect
    % MultiSinusoidsEffect
    %
    % Effect responsible for detecting signals that can be approximated
    % by a sum of multiple sinusoidal components.
    %
    % The fitted model is:
    %
    %   y(t) = sum_k A_k * cos(omega_k * t + phi_k) + C
    %
    % Each sinusoidal component is described by three parameters:
    %   - A_k: amplitude
    %   - omega_k: angular frequency
    %   - phi_k: phase
    %
    % An additional parameter C represents the constant offset.
    %
    % The time vector is normalized to [0, 1] during model evaluation.
    % This makes the initial angular frequency guesses independent
    % of the original time scale.
    %
    % The number of sinusoidal components is defined by
    % MultiSinusoidsOptions.N.

    methods
        function model = getModel(~)
            % GETMODEL Return the multi-sinusoid fitting model.
            %
            % The model determines the number of sinusoidal components
            % from the number of parameters supplied to it.

            model = @(params, t) ...
                MultiSinusoidsEffect.evaluateModel(params, t);
        end

        function params0 = getInitialParams(~, y, t, opt)
            % GETINITIALPARAMS Compute initial fitting parameters.
            %
            % The initial amplitude is distributed equally among the
            % sinusoidal components.
            %
            % Initial angular frequencies correspond to integer numbers
            % of oscillations over the normalized observation interval.
            %
            % The initial phases are set to zero, while the constant
            % offset is initialized using the signal mean.

            if ~isscalar(opt) || ~isa(opt, 'MultiSinusoidsOptions')
                error('MultiSinusoidsEffect:InvalidOptions', ...
                    'Expected a scalar MultiSinusoidsOptions object.');
            end

            N = opt.N;

            if numel(t) < 2 || max(t) <= min(t)
                error('MultiSinusoidsEffect:InvalidTimeVector', ...
                    'The time vector must span a nonzero interval.');
            end

            signalRange = max(y) - min(y);
            initialAmplitude = signalRange / N;
            initialOffset = mean(y);

            params0 = zeros(1, 3*N + 1);

            for k = 1:N
                parameterIndex = 3*(k - 1) + 1;

                params0(parameterIndex)     = initialAmplitude;
                params0(parameterIndex + 1) = 2*pi*k;
                params0(parameterIndex + 2) = 0;
            end

            params0(end) = initialOffset;
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Define the analysis pipeline.
            %
            % The pipeline preprocesses the signal, fits the
            % multi-sinusoid model, evaluates the fitting quality,
            % applies the common acceptance threshold and optionally
            % plots the result.

            obj.addTask(PreprocessTask());
            obj.addTask(FitModelTask(obj));
            obj.addTask(R2ComputationTask());
            obj.addTask(PostCheckTask());
            obj.addTask(PlotTask());
        end
    end

    methods (Static, Access = private)
        function yFit = evaluateModel(params, t)
            % EVALUATEMODEL Evaluate the sum of sinusoidal components.
            %
            % The parameter vector contains three values per sinusoid
            % (amplitude, angular frequency and phase), followed by
            % the constant offset.
            %
            % The time vector is normalized to [0, 1] before
            % evaluating the sinusoidal components.

            if mod(numel(params) - 1, 3) ~= 0
                error('MultiSinusoidsEffect:InvalidParameters', ...
                    'The parameter vector must contain 3*N + 1 elements.');
            end

            timeRange = max(t) - min(t);

            if ~isfinite(timeRange) || timeRange <= 0
                error('MultiSinusoidsEffect:InvalidTimeVector', ...
                    'The time vector must span a finite, nonzero interval.');
            end

            tNorm = (t - min(t)) / timeRange;

            N = (numel(params) - 1) / 3;

            yFit = zeros(size(tNorm));

            for k = 1:N
                parameterIndex = 3*(k - 1) + 1;

                A = params(parameterIndex);
                omega = params(parameterIndex + 1);
                phi = params(parameterIndex + 2);

                yFit = yFit + A .* cos(omega .* tNorm + phi);
            end

            yFit = yFit + params(end);
        end
    end
end
