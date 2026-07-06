%Questa classe corrisponde alla funzione "isExpDivergent"
classdef ExpEffect < BaseEffect

    methods

        function model = getModel(~)
            model = @(p,t) p(1) + p(2)*exp(p(3)*t);
        end

        function params0 = getInitialParams(~, y, opt)
            A0 = min(y);
            B0 = max(y) - min(y);

            if isfield(opt, 'params0') && numel(opt.params0) >= 3
                C0 = opt.params0(3);
            else
                C0 = 0.01; % valore di default sicuro
            end

            params0 = [A0, B0, C0];
        end

    end

end