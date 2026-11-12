classdef ExpEffect < BaseEffect
    % ExpEffect
    %
    % Concrete effect class implementing the recognition of exponential
    % divergence in an input signal.
    %
    % This class corresponds to the legacy function "isExpDivergent".
    %
    % It defines the exponential model, computes its initial fitting
    % parameters, and configures the sequence of tasks required for
    % exponential effect analysis.
    %
    % The mathematical model is:
    %   y(t) = A + B * exp(C * t)
    %
    % The model parameters are estimated through nonlinear least-squares
    % fitting and evaluated using the coefficient of determination.

    methods
        function model = getModel(~)
            % GETMODEL Returns the exponential effect model.
            %
            % OUTPUT:
            %   model -> function handle representing:
            %            y(t) = A + B * exp(C * t)
            %
            % The parameter vector is defined as:
            %   p(1) -> A: vertical offset.
            %   p(2) -> B: exponential amplitude.
            %   p(3) -> C: exponential growth or decay rate.

            model = @(p,t) p(1) + p(2)*exp(p(3)*t);
        end

        function params0 = getInitialParams(~, y, t, opt)
            % GETINITIALPARAMS Computes the initial exponential model parameters.
            %
            % INPUT:
            %   y   -> Input signal used to estimate the initial parameters.
            %   t   -> Time vector corresponding to the input signal.
            %   opt -> Scalar ExpOptions object containing effect-specific
            %          configuration parameters.
            %
            % OUTPUT:
            %   params0 -> Initial parameter vector [A0, B0, C0].
            %
            % The initial offset and amplitude are estimated from the signal.
            % The initial exponential rate is estimated from the ratio between
            % the second and first derivatives of a polynomial approximation.
            % The configured rate is retained if the estimate is unreliable.

            if ~isa(opt, 'ExpOptions') || ~isscalar(opt)
                error('ExpEffect:InvalidOptions', ...
                    'Options must be a scalar ExpOptions object.');
            end

            % Ensure that the input vectors have compatible dimensions.
            y = y(:);
            t = t(:);

            if numel(y) ~= numel(t)
                error('ExpEffect:InvalidSignal', ...
                    'The signal and time vectors must have the same length.');
            end

            % Retain only finite paired samples.
            validSamples = isfinite(y) & isfinite(t);
            y = y(validSamples);
            t = t(validSamples);

            if numel(y) < 5
                error('ExpEffect:InvalidSignal', ...
                    'At least five finite samples are required.');
            end

            % Estimate the initial offset and exponential amplitude.
            A0 = min(y);
            B0 = max(y) - min(y);

            % Retrieve the configured initial exponential rate.
            C0 = opt.params0(3);

            % Estimate the exponential rate from a quadratic approximation.
            if B0 > 0 && numel(unique(t)) >= 3
                tCenter = mean(t);
                tScale = max(abs(t - tCenter));

                if tScale > 0
                    normalizedT = (t - tCenter) / tScale;
                    coefficients = polyfit(normalizedT, y, 2);

                    firstDerivative = polyval(polyder(coefficients), normalizedT);
                    secondDerivative = 2 * coefficients(1);

                    derivativeThreshold = 1e-8 * max(abs(firstDerivative));

                    validDerivatives = abs(firstDerivative) > derivativeThreshold;

                    if nnz(validDerivatives) >= 3
                        estimatedRates = secondDerivative ./ ...
                            firstDerivative(validDerivatives) / tScale;

                        estimatedC = median(estimatedRates);

                        if isfinite(estimatedC) && abs(estimatedC) > eps
                            C0 = estimatedC;
                        end
                    end
                end
            end

            params0 = [A0, B0, C0];
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Defines the task pipeline for exponential
            % effect analysis.
            %
            % The pipeline performs the following operations:
            %   1. Preprocess the input signal.
            %   2. Fit the exponential model.
            %   3. Compute the coefficient of determination.
            %   4. Check the fitting quality against the acceptance threshold.
            %   5. Optionally plot the original and fitted signals.

            obj.addTask(PreprocessTask());
            obj.addTask(FitModelTask(obj));
            obj.addTask(R2ComputationTask());
            obj.addTask(PostCheckTask());
            obj.addTask(PlotTask());
        end
    end
end
