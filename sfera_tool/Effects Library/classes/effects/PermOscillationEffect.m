classdef PermOscillationEffect < BaseEffect
    % PermOscillationEffect
    %
    % Concrete effect class implementing permanent oscillation detection.
    %
    % The effect identifies signals exhibiting sustained oscillatory
    % behavior through a combination of exponential cosine fitting
    % and spectral analysis.
    %
    % The analysis model is:
    %
    %   y(t) = A * exp(beta * t) * cos(omega * t + phi) + D
    %
    % where:
    %   A     -> oscillation amplitude
    %   beta  -> exponential growth or damping coefficient
    %   omega -> angular frequency
    %   phi   -> phase
    %   D     -> signal offset

    methods
        function model = getModel(~)
            % GETMODEL Returns the mathematical model of the effect.
            %
            % OUTPUT:
            %   model -> function handle representing an exponentially
            %            modulated cosine with a constant offset.

            model = @(p,t) p(1).*exp(p(2).*t).* ...
                cos(p(3).*t + p(4)) + p(5);
        end

        function params0 = getInitialParams(~, y, ~, opt)
            % GETINITIALPARAMS Computes the initial model parameters.
            %
            % INPUT:
            %   y   -> preprocessed input signal.
            %   t   -> time vector (unused by this initialization).
            %   opt -> PermOscillationOptions configuration object.
            %
            % OUTPUT:
            %   params0 -> initial parameter vector:
            %              [A0, beta0, omega0, phi0, D0].
            %
            % The initial amplitude and offset are estimated from
            % the input signal, while the remaining parameters are
            % taken from the supplied configuration.

            if ~isa(opt, 'PermOscillationOptions') || ~isscalar(opt)
                error('PermOscillationEffect:InvalidOptions', ...
                    'Options must be a scalar PermOscillationOptions object.');
            end

            y = y(:);

            signalRange = max(y) - min(y);

            params0 = opt.params0;
            params0(1) = signalRange / 2;
            params0(5) = mean(y);
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % CONFIGURETASKS Defines the analysis pipeline for
            % permanent oscillation detection.
            %
            % The pipeline first preprocesses the input signal,
            % then performs a preliminary peak check, followed by
            % the combined fitting and spectral analysis.
            % Finally, it optionally plots the analysis results.

            obj.addTask(PreprocessTask());
            obj.addTask(PermOscillationPreCheckTask());
            obj.addTask(PermOscillationAnalysisTask());
            obj.addTask(PermOscillationPlotTask());
        end
    end
end