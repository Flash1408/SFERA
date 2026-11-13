classdef CubicRadixEffect < BaseEffect
    % CubicRadixEffect
    %
    % Effect detector responsible for identifying cubic radix trends
    % in an input signal.
    %
    % The effect is modeled by:
    %
    %   y(t) = A * sign(B * (t - C)) ...
    %              * abs(B * (t - C))^(1/3) + D
    %
    % The parameter vector is defined as:
    %   p(1) -> A: amplitude of the cubic-root component.
    %   p(2) -> B: horizontal scaling factor.
    %   p(3) -> C: horizontal translation.
    %   p(4) -> D: vertical offset.
    %
    % The analysis pipeline is inherited from BaseEffect and consists
    % of preprocessing, model fitting, R-squared computation,
    % acceptance checking, and optional plotting.

    methods
        function model = getModel(~)
            % GETMODEL Returns the cubic radix effect model.
            %
            % OUTPUT:
            %   model -> Function handle representing the cubic radix
            %            model.
            %
            % The sign and absolute-value operations ensure that the
            % cube root is evaluated as a real-valued function also
            % for negative arguments.

            model = @(p,t) p(1) .* ...
                sign(p(2) .* (t - p(3))) .* ...
                abs(p(2) .* (t - p(3))).^(1/3) + p(4);
        end

        function params0 = getInitialParams(~, y, ~, opt)
            % GETINITIALPARAMS Returns the configured initial parameters.
            %
            % INPUT:
            %   y   -> Preprocessed input signal.
            %   opt -> Scalar CubicRadixOptions object containing the
            %          initial parameter values.
            %
            % OUTPUT:
            %   params0 -> Initial parameter vector [A0, B0, C0, D0].
            %
            % The initial values are taken directly from the effect
            % configuration, preserving the legacy initialization
            % strategy.

            if ~isa(opt, 'CubicRadixOptions') || ~isscalar(opt)
                error('CubicRadixEffect:InvalidOptions', ...
                    'Options must be a scalar CubicRadixOptions object.');
            end

            params0 = opt.params0;
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Defines the task pipeline for cubic radix
            % effect analysis.
            %
            % The pipeline performs the following operations:
            %   1. Preprocess the input signal.
            %   2. Fit the cubic radix model.
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
