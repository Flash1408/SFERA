
classdef PermOscillationAnalysisTask < Task
    % PermOscillationAnalysisTask
    %
    % Task responsible for evaluating the independent fitting and
    % spectral criteria used for permanent oscillation detection.
    %
    % The fitting criterion verifies whether the input signal can be
    % approximated by a sinusoidal model with negligible damping or
    % divergence.
    %
    % The spectral criterion evaluates whether the signal exhibits
    % a sufficiently dominant frequency component.
    %
    % The two criteria are independent: fitting may be skipped
    % or fail without preventing spectral analysis, and spectral
    % analysis may be disabled without preventing curve fitting.
    %
    % The final detection result is obtained by combining both
    % criteria through a logical OR operation.

    properties (SetAccess = private)
        % Indicates whether the fitting criterion is satisfied.
        useFit (1,1) logical = false

        % Indicates whether the spectral criterion is satisfied.
        useFFT (1,1) logical = false

        % Indicates whether the fitting procedure produced valid results.
        fitSucceeded (1,1) logical = false

        % Fitted damping or divergence coefficient.
        betaFit (1,1) double = NaN

        % Maximum normalized spectral magnitude.
        spectralRatio (1,1) double = NaN

        % Single-sided amplitude spectrum.
        spectrum (1,:) double = []

        % Frequency axis associated with the single-sided spectrum.
        frequencies (1,:) double = []
    end

    methods
        function obj = PermOscillationAnalysisTask()
            % PERMOSCILLATIONANALYSISTASK Constructs the analysis task.
            %
            % The task evaluates the fitting and spectral criteria
            % independently and combines their results.

            obj = obj@Task("PermOscillationAnalysisTask");
        end
    end

    methods (Access = private)

        function validateOptions(obj, opt)
            % VALIDATEOPTIONS Checks the configuration required by the
            % permanent oscillation analysis.
            %
            % Parameter vectors must contain five elements, corresponding to:
            % amplitude, damping coefficient, angular frequency, phase
            % and vertical offset.
            %
            % Infinite bounds are allowed, but NaN values and inconsistent
            % parameter limits are not.

            if ~isa(opt, 'PermOscillationOptions') || ~isscalar(opt)
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'Options must be a scalar PermOscillationOptions object.');
            end

            % Validate parameter vectors.
            if numel(opt.lb) ~= 5 || numel(opt.ub) ~= 5 || ...
                    numel(opt.params0) ~= 5
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'Parameter vectors must contain exactly five elements.');
            end

            if any(isnan(opt.lb)) || any(isnan(opt.ub))
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'Parameter bounds cannot contain NaN values.');
            end

            if any(opt.lb > opt.ub)
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'Lower bounds cannot exceed upper bounds.');
            end

            if ~isreal(opt.params0) || any(~isfinite(opt.params0))
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'Initial parameters must be finite real values.');
            end

            % Validate solver configuration.
            if ~isscalar(opt.tolFun) || ~isfinite(opt.tolFun) || opt.tolFun <= 0
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'tolFun must be a positive finite scalar.');
            end

            if ~isscalar(opt.maxIter) || ~isfinite(opt.maxIter) || ...
                    opt.maxIter < 1 || mod(opt.maxIter, 1) ~= 0
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'maxIter must be a positive integer.');
            end

            if ~isscalar(opt.maxFunEvals) || ~isfinite(opt.maxFunEvals) || ...
                    opt.maxFunEvals < 1 || mod(opt.maxFunEvals, 1) ~= 0
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'maxFunEvals must be a positive integer.');
            end

            if ~isscalar(opt.betaTol) || ~isfinite(opt.betaTol) || opt.betaTol <= 0
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'betaTol must be a positive finite scalar.');
            end

            if ~isscalar(opt.spectralThreshold) || ...
                    ~isfinite(opt.spectralThreshold) || ...
                    opt.spectralThreshold < 0 || opt.spectralThreshold > 1
                error('SFERA:PermOscillationAnalysisTask:InvalidOptions', ...
                    'spectralThreshold must be a finite scalar between 0 and 1.');
            end
        end

        function params0 = getInitialParams(obj, y, opt)
            % GETINITIALPARAMS Computes the initial parameter estimates.
            %
            % The initial amplitude and offset are estimated from the signal,
            % while beta, angular frequency and phase are taken from the
            % user-configured initial parameters.

            signalRange = max(y) - min(y);

            params0 = opt.params0;

            params0(1) = signalRange / 2;
            params0(5) = mean(y);
        end

        function executeFit(obj, context)
            % EXECUTEFIT Estimates the parameters of the damped sinusoidal model.
            %
            % The fitting procedure is independent of the spectral analysis:
            % a fitting failure is recorded but does not interrupt the task.
            %
            % The model is:
            %   y(t) = A * exp(beta*t) * cos(omega*t + phi) + D

            y = context.y;
            t = (1:numel(y))';

            % Skip curve fitting when the preliminary check indicates
            % that the signal does not satisfy the required peak conditions.
            if ~context.fitEligible
                return;
            end

            opt = context.options;

            % Retrieve the model and initial parameter estimates.
            model = @(p,t) p(1) .* exp(p(2).*t) .* ...
                cos(p(3).*t + p(4)) + p(5);

            params0 = obj.getInitialParams(y, opt);

            % Ensure the initial estimates satisfy the configured bounds.
            if any(params0 < opt.lb) || any(params0 > opt.ub)
                error('SFERA:PermOscillationAnalysisTask:InvalidInitialParameters', ...
                    'Initial parameters must lie within the configured bounds.');
            end

            % Configure the nonlinear least-squares solver.
            solverOptions = optimoptions('lsqcurvefit', ...
                'Display', 'off', ...
                'MaxIterations', opt.maxIter, ...
                'MaxFunctionEvaluations', opt.maxFunEvals, ...
                'TolFun', opt.tolFun);

            % Perform the fitting.
            try
                [paramsFit, ~, ~, exitFlag, output] = lsqcurvefit( ...
                    model, params0, t, y, opt.lb, opt.ub, solverOptions);

            catch ME
                % Preserve the error identifier and message for diagnostic purposes.
                % A fitting failure does not prevent spectral analysis.
                context.fitError = string(ME.identifier) + ": " + string(ME.message);
                return;
            end

            % Store fitting diagnostics.
            context.fitExitFlag = exitFlag;
            context.fitOutput = output;

            % Check whether the fitting algorithm converged.
            if exitFlag <= 0
                context.fitError = "The fitting algorithm did not converge.";
                return;
            end

            if ~isreal(paramsFit) || any(~isfinite(paramsFit))
                context.fitError = "The fitting algorithm produced invalid parameters.";
                return;
            end

            % Evaluate the fitted model.
            yFit = model(paramsFit, t);

            if ~isreal(yFit) || any(~isfinite(yFit))
                context.fitError = "The fitted model produced invalid values.";
                return;
            end

            % Store fitting results in the shared context.
            context.model = model;
            context.params0 = params0;
            context.params_fit = paramsFit;
            context.y_fit = yFit;

            % Compute the coefficient of determination.
            residuals = y - yFit;
            SST = sum((y - mean(y)).^2);

            if SST > 0
                context.R2 = 1 - sum(residuals.^2) / SST;
            else
                context.R2 = NaN;
            end

            % Store fitting diagnostics.
            obj.betaFit = paramsFit(2);
            obj.fitSucceeded = true;

            % Apply the fitting acceptance criteria.
            signalRange = max(y) - min(y);
            amplitudeFit = abs(paramsFit(1));

            obj.useFit = ...
                isfinite(context.R2) && ...
                context.R2 > opt.threshold && ...
                abs(obj.betaFit) < opt.betaTol && ...
                amplitudeFit >= 0.05 * signalRange;
        end

        function executeFFT(obj, context)
            % EXECUTEFFT Evaluates the spectral criterion using the FFT.
            %
            % The normalized single-sided spectrum is computed from the input
            % signal. The spectral criterion is satisfied when the maximum
            % normalized spectral magnitude exceeds the configured threshold.
            %
            % The DC component is intentionally retained to preserve the
            % behavior of the legacy implementation.

            opt = context.options;

            % Skip spectral analysis when disabled.
            if ~opt.useSpectralCheck
                return;
            end

            y = context.y;
            N = numel(y);

            % Reject signals without any variation.
            if all(y == y(1))
                return;
            end

            % Compute the single-sided amplitude spectrum.
            Y = fft(y);
            P2 = abs(Y / N);
            P1 = P2(1:floor(N/2)+1);

            % Account for the negative-frequency contribution.
            if mod(N, 2) == 0
                P1(2:end-1) = 2 * P1(2:end-1);
            else
                P1(2:end) = 2 * P1(2:end);
            end

            % Normalize the spectrum.
            totalMagnitude = sum(P1);

            if ~isfinite(totalMagnitude) || totalMagnitude <= 0
                return;
            end

            Pnorm = P1 / totalMagnitude;

            % Store the spectrum and its normalized frequency axis.
            obj.spectrum = P1;
            obj.frequencies = (0:floor(N/2)) / N;

            % Transfer spectral data to the shared analysis context.
            context.spectrum = obj.spectrum;
            context.frequencies = obj.frequencies;

            % Evaluate the spectral dominance criterion.
            obj.spectralRatio = max(Pnorm);

            % Transfer the spectral dominance ratio to the shared analysis context.
            context.spectralRatio = obj.spectralRatio;

            % Determine whether the spectral dominance criterion is satisfied.
            obj.useFFT = obj.spectralRatio > opt.spectralThreshold;
        end
    end

    methods
        function ok = execute(obj, context)
            % EXECUTE Evaluates the fitting and spectral criteria.
            %
            % Both analyses are independent. A failure in the fitting
            % procedure does not prevent the execution of the spectral analysis.
            %
            % The task itself is considered successfully executed when the
            % analysis criteria have been evaluated, regardless of the final
            % detection result.
            %
            % The analysis configuration is validated before either
            % criterion is evaluated.

            % Reset diagnostic properties.
            obj.useFit = false;
            obj.useFFT = false;
            obj.fitSucceeded = false;
            obj.betaFit = NaN;
            obj.spectralRatio = NaN;
            obj.spectrum = [];
            obj.frequencies = [];

            % Reset fitting diagnostics in the context.
            context.fitExitFlag = NaN;
            context.fitOutput = struct();
            context.fitError = "";

            % Reset spectral data in the shared analysis context.
            context.spectrum = [];
            context.frequencies = [];
            context.spectralRatio = NaN;

            % Validate the analysis configuration.
            obj.validateOptions(context.options);

            % Evaluate the fitting criterion.
            obj.executeFit(context);

            % Evaluate the spectral criterion independently.
            obj.executeFFT(context);

            % Combine the currently available criteria.
            context.result = obj.useFit || obj.useFFT;

            ok = true;
        end
    end
end

