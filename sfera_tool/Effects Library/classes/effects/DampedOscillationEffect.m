classdef DampedOscillationEffect < BaseEffect
    % DampedOscillationEffect
    %
    % Concrete effect class implementing the recognition of damped
    % oscillations in an input signal.
    %
    % This class defines the damped oscillation model, computes its
    % initial fitting parameters and configures the sequence of tasks
    % required for effect analysis.
    %
    % The mathematical model is:
    %   y(t) = A * exp(beta * t) * cos(omega * t + phi) + C
    %
    % The model parameters are estimated through nonlinear least-squares
    % fitting and evaluated using the coefficient of determination.
    % Additional checks are performed before and after model fitting.

    methods
        function model = getModel(~)
            % GETMODEL Returns the damped oscillation effect model.
            %
            % OUTPUT:
            %   model -> function handle representing:
            %            y(t) = A * exp(beta * t) * cos(omega * t + phi) + C
            %
            % The parameter vector is defined as:
            %   p(1) -> A: oscillation amplitude.
            %   p(2) -> beta: exponential damping coefficient.
            %   p(3) -> omega: angular frequency.
            %   p(4) -> phi: phase shift.
            %   p(5) -> C: vertical offset.
    
            model = @(p,t) p(1) .* exp(p(2) .* t) .* ...
                cos(p(3) .* t + p(4)) + p(5);
        end

        function params0 = getInitialParams(~, y, opt)
            % GETINITIALPARAMS Computes the initial damped oscillation parameters.
            %
            % INPUT:
            %   y   -> input signal used to compute the initial amplitude
            %          and vertical offset.
            %   opt -> scalar DampedOscillationOptions object containing
            %          the remaining initial model parameters.
            %
            % OUTPUT:
            %   params0 -> initial parameter vector [A0, beta0, omega0,
            %              phi0, C0].
            %
            % The initial amplitude and vertical offset are computed from
            % the input signal, while the remaining parameters are retrieved
            % from the effect-specific configuration object.

            if ~isa(opt, 'DampedOscillationOptions') || ~isscalar(opt)
                error('DampedOscillationEffect:InvalidOptions', ...
                    'Options must be a scalar DampedOscillationOptions object.');
            end

            % Normalize the input signal.
            y = y(:);

            % Compute signal-dependent initial parameters.
            A0 = max(abs(y));
            C0 = mean(y);

            % Retrieve the remaining initial parameters from the options.
            params0 = opt.params0;
            params0(1) = A0;
            params0(5) = C0;
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Defines the task pipeline for damped
            % oscillation effect analysis.
            %
            % The pipeline performs the following operations:
            %   1. Preprocess the input signal.
            %   2. Check whether the signal contains enough valid peaks.
            %   3. Fit the damped oscillation model.
            %   4. Compute the coefficient of determination.
            %   5. Check the fitting quality against the acceptance threshold.
            %   6. Validate the fitted damped oscillation parameters.
            %   7. Optionally plot the original and fitted signals.

            obj.addTask(PreprocessTask());
            obj.addTask(DampedOscillationPreCheckTask());
            obj.addTask(FitModelTask(obj));
            obj.addTask(R2ComputationTask());
            obj.addTask(PostCheckTask());
            obj.addTask(DampedOscillationPostCheckTask());
            obj.addTask(PlotTask());
        end
    end
end