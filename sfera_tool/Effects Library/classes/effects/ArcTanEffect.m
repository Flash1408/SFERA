classdef ArcTanEffect < BaseEffect
    % ArcTanEffect
    %
    % Concrete effect class implementing the recognition of arc-tangent
    % shaped variations in an input signal.
    %
    % This class defines the arc-tangent model, retrieves its initial
    % fitting parameters from the effect-specific options, and configures
    % the sequence of tasks required for effect analysis.
    %
    % The mathematical model is:
    %   y(t) = A * atan((t - H) / C) + D
    %
    % The model parameters are estimated through nonlinear least-squares
    % fitting and evaluated using the coefficient of determination.
    % Additional checks are performed before and after model fitting.

    methods
        function model = getModel(~)
            % GETMODEL Returns the arc-tangent effect model.
            %
            % OUTPUT:
            %   model -> function handle representing:
            %            y(t) = A * atan((t - H) / C) + D
            %
            % The parameter vector is defined as:
            %   p(1) -> A: amplitude.
            %   p(2) -> H: horizontal position of the central transition.
            %   p(3) -> C: parameter controlling the transition slope.
            %   p(4) -> D: vertical offset.

            model = @(p,t) p(1) * atan((t - p(2)) / p(3)) + p(4);
        end

        function params0 = getInitialParams(~, ~, opt)
            % GETINITIALPARAMS Retrieves the initial arc-tangent parameters.
            %
            % INPUT:
            %   opt -> scalar ArcTanOptions object containing the
            %          initial model parameters.
            %
            % OUTPUT:
            %   params0 -> initial parameter vector [A0, H0, C0, D0].
            %
            % Unlike ExpEffect, all initial parameters are directly
            % provided by the effect-specific configuration object.

            if ~isa(opt, 'ArcTanOptions') || ~isscalar(opt)
                error('ArcTanEffect:InvalidOptions', ...
                    'Options must be a scalar ArcTanOptions object.');
            end

            params0 = opt.params0;
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Defines the task pipeline for arc-tangent
            % effect analysis.
            %
            % The pipeline performs the following operations:
            %   1. Preprocess the input signal.
            %   2. Check whether the signal has sufficient curvature
            %      for arc-tangent analysis.
            %   3. Fit the arc-tangent model.
            %   4. Compute the coefficient of determination.
            %   5. Check the fitting quality against the acceptance threshold.
            %   6. Validate the fitted amplitude.
            %   7. Optionally plot the original and fitted signals.

            obj.addTask(PreprocessTask());
            obj.addTask(ArcTanPreCheckTask());
            obj.addTask(FitModelTask(obj));
            obj.addTask(R2ComputationTask());
            obj.addTask(PostCheckTask());
            obj.addTask(ArcTanPostCheckTask());
            obj.addTask(PlotTask());
        end
    end
end
