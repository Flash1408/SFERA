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

        function params0 = getInitialParams(~, y, opt)
            % GETINITIALPARAMS Computes the initial exponential model parameters.
            %
            % INPUT:
            %   y   -> input signal used to estimate the initial parameters.
            %   opt -> scalar ExpOptions object containing effect-specific
            %          configuration parameters.
            %
            % OUTPUT:
            %   params0 -> initial parameter vector [A0, B0, C0].
            %
            % The initial offset A0 and amplitude B0 are estimated from
            % the finite signal samples, while the initial rate C0 is
            % retrieved from the effect-specific options.

            if ~isa(opt, 'ExpOptions') || ~isscalar(opt)
                error('ExpEffect:InvalidOptions', ...
                    'Options must be a scalar ExpOptions object.');
            end

            % Retain only finite signal samples.
            y = y(:);
            y = y(isfinite(y));

            if isempty(y)
                error('ExpEffect:InvalidSignal', ...
                    'The signal must contain at least one finite sample.');
            end

            % Estimate the initial offset and exponential amplitude.
            A0 = min(y);
            B0 = max(y) - min(y);

            % Retrieve the initial exponential rate from the options.
            C0 = opt.params0(3);

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
