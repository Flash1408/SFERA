classdef ArcTanEffect < BaseEffect
    % ArcTanEffect implements the arc-tangent model for signal analysis.

    methods
        function model = getModel(~)
            % Returns the arc-tangent model function.
            model = @(p,t) p(1) * atan((t - p(2)) / p(3)) + p(4);
        end

        function params0 = getInitialParams(~, ~, opt)
            % Computes the initial parameters for the arc-tangent model.
            if ~isa(opt, 'ArcTanOptions') || ~isscalar(opt)
                error('ArcTanEffect:InvalidOptions', ...
                    'Options must be a scalar ArcTanOptions object.');
            end

            params0 = opt.params0;
        end
    end

    methods (Access = protected)
        function configureTasks(obj)
            % Configures the task pipeline for arc-tangent analysis.
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