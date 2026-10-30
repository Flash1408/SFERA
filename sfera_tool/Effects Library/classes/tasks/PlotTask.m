classdef PlotTask < Task
    % PlotTask is responsible for visualizing the results of signal
    % analysis when plotting is enabled.
    %
    % It displays the original signal and the fitted model, including
    % the computed R-squared value in the plot title.
    % Plotting is optional and must not affect the numerical result.

    methods

        function obj = PlotTask()
            obj = obj@Task("PlotTask");
        end

        function ok = execute(~, context)
            % Validates the shared context before accessing its data.

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('PlotTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Plotting is skipped when visualization is disabled.
            % The numerical analysis result remains unchanged.

            ok = true;

            if ~context.options.showPlot
                return;
            end

            % Generates the plot without changing the analysis result.
            % A plotting failure is reported as a warning and does not
            % invalidate an otherwise completed numerical analysis.

            try
                figure;

                plot(context.t, context.y, ...
                    'b', 'LineWidth', 1.5);
                hold on;

                plot(context.t, context.y_fit, ...
                    'r--', 'LineWidth', 1.5);

                legend('Original signal', 'Fitted model');

                title(['Model fit, R^2 = ' ...
                    num2str(context.R2, '%.2f')]);

                xlabel('Time');
                ylabel('Signal');

                hold off;

            catch ME
                warning('PlotTask:PlotFailed', ...
                    ['Unable to generate the plot. ' ...
                     'The numerical result is unchanged. ' ...
                     'Details: %s'], ...
                    ME.message);
            end

        end

    end

end
