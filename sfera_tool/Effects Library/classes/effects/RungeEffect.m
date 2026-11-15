classdef RungeEffect < BaseEffect
    % RungeEffect
    %
    % Effect detector responsible for identifying Runge-like trends
    % in an input signal.
    %
    % The effect is modeled by:
    %
    %   y(t) = A / (1 + B * (tNorm - C)^2) + D
    %
    % where:
    %   tNorm = (t - min(t)) / (max(t) - min(t))
    %
    % The parameter vector is defined as:
    %   p(1) -> A: amplitude of the Runge peak.
    %   p(2) -> B: parameter controlling the peak width.
    %   p(3) -> C: normalized horizontal position of the peak.
    %   p(4) -> D: vertical offset.
    %
    % Time normalization is performed internally by the model,
    % preserving the original time vector stored in EffectContext.
    %
    % The analysis pipeline will consist of preprocessing, model
    % fitting, Runge-specific checks, R-squared computation,
    % acceptance checking, and optional plotting.

    methods
        function model = getModel(~)
            % GETMODEL Returns the Runge effect model.
            %
            % OUTPUT:
            %   model -> Function handle representing the Runge model.
            %
            % The time vector is normalized to the interval [0, 1]
            % before evaluating the model.

            model = @(p,t) p(1) ./ ...
                (1 + p(2) .* ...
                (((t - min(t)) ./ (max(t) - min(t))) - p(3)).^2) ...
                + p(4);
        end

        function params0 = getInitialParams(~, y, ~, opt)
            % GETINITIALPARAMS Returns the configured initial parameters.
            %
            % INPUT:
            %   y   -> Preprocessed input signal.
            %   opt -> Scalar RungeOptions object containing the
            %          initial parameter values.
            %
            % OUTPUT:
            %   params0 -> Initial parameter vector [A0, B0, C0, D0].
            %
            % The initial values are taken directly from the effect
            % configuration.

            if ~isa(opt, 'RungeOptions') || ~isscalar(opt)
                error('RungeEffect:InvalidOptions', ...
                    'Options must be a scalar RungeOptions object.');
            end

            params0 = opt.params0;
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Defines the task pipeline for Runge effect analysis.
            %
            % The pipeline performs the following operations:
            %   1. Preprocess the input signal.
            %   2. Validate the time vector.
            %   3. Fit the Runge model.
            %   4. Validate the estimated model parameters.
            %   5. Check the number of significant local maxima.
            %   6. Reject monotonic signals.
            %   7. Evaluate the symmetry of the signal around the fitted center.
            %   8. Compute the coefficient of determination.
            %   9. Check the fitting quality against the acceptance threshold.
            %  10. Optionally plot the original and fitted signals.
        
            obj.addTask(PreprocessTask());
            obj.addTask(RungeTimeCheckTask());
            obj.addTask(FitModelTask(obj));
            obj.addTask(RungePreCheckTask());
            obj.addTask(RungePeakCheckTask());
            obj.addTask(RungeMonotonicityCheckTask());
            obj.addTask(RungeSymmetryCheckTask());
            obj.addTask(R2ComputationTask());
            obj.addTask(PostCheckTask());
            obj.addTask(PlotTask());
        end
    end
end
