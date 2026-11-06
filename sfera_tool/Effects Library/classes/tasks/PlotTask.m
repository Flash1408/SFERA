classdef PlotTask < Task
    % PlotTask
    %
    % Task responsible for visualizing the results of effect analysis.
    %
    % When plotting is enabled through the analysis options, this task
    % displays the original signal together with the fitted model and
    % reports the coefficient of determination (R-squared).
    %
    % Plotting is optional and does not affect the numerical analysis
    % result. Any plotting failure is reported as a warning without
    % invalidating an otherwise completed analysis.

    methods

        function obj = PlotTask()
            % PLOTTASK Constructs a plotting task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("PlotTask");
        end

        function ok = execute(~, context)
            % EXECUTE Generates a plot of the original and fitted signals.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the original
            %              signal, fitted signal, time vector, R-squared
            %              value and analysis options.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the plotting task
            %         completed its execution.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Checks whether plotting is enabled.
            %   3. Displays the original signal and fitted model.
            %   4. Includes the R-squared value in the plot title.
            %
            % If plotting is disabled, no figure is generated.
            % If plotting fails, a warning is issued and the numerical
            % analysis result remains unchanged.

            % Validate the shared analysis context.
            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('PlotTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            if ~isa(context.options, 'BaseOptions') || ...
                    ~isscalar(context.options)

                error('PlotTask:InvalidOptions', ...
                    'The context must contain a scalar BaseOptions object.');
            end

            % Mark the task as successfully executed.
            ok = true;

            % Skip visualization when plotting is disabled.
            if ~context.options.showPlot
                return;
            end

            % Generate the plot without modifying the analysis result.
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
                % Report plotting failures without invalidating the
                % numerical analysis result.
                warning('PlotTask:PlotFailed', ...
                    ['Unable to generate the plot. ' ...
                     'The numerical result is unchanged. ' ...
                     'Details: %s'], ...
                    ME.message);
            end

        end

    end

end
