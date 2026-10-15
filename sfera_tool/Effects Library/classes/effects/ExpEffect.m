% This class corresponds to the legacy function "isExpDivergent".
%
% It defines the exponential model and computes its initial parameters.
% The analysis pipeline is configured through configureTasks.

classdef ExpEffect < BaseEffect

    methods

        function model = getModel(~)
            % Returns the exponential model:
            % y(t) = A + B * exp(C * t)

            model = @(p,t) p(1) + p(2)*exp(p(3)*t);
        end

        function params0 = getInitialParams(~, y, opt)
            % Computes the initial parameters from the input signal.
            %
            % A0 and B0 are estimated from the data, while C0 is
            % retrieved from the effect-specific options.

            if ~isa(opt, 'ExpOptions') || ~isscalar(opt)
                error('ExpEffect:InvalidOptions', ...
                    'Options must be a scalar ExpOptions object.');
            end

            y = y(:);
            y = y(isfinite(y));

            if isempty(y)
                error('ExpEffect:InvalidSignal', ...
                    'The signal must contain at least one finite sample.');
            end

            A0 = min(y);
            B0 = max(y) - min(y);
            C0 = opt.params0(3);

            params0 = [A0, B0, C0];
        end

    end
    
    methods (Access = protected)

        function configureTasks(obj)
            % Configures the task pipeline for exponential analysis.
            %
            % Data preprocessing must be completed before fitting
            % the exponential model.

            obj.addTask(PreprocessTask());
            obj.addTask(FitModelTask(obj));
        end
        
    end

end
