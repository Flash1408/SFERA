classdef PermOscillationPlotTask < Task
    % PermOscillationPlotTask
    %
    % Task responsible for visualizing the results of permanent
    % oscillation analysis.
    %
    % When plotting is enabled through the analysis options, this task
    % generates a figure containing two subplots:
    %
    %   1. Time-domain representation:
    %      Displays the original signal and, when available, the fitted
    %      damped sinusoidal model.
    %
    %   2. Frequency-domain representation:
    %      Displays the single-sided amplitude spectrum computed through
    %      the FFT.
    %
    % The fitted model is displayed only when the fitting procedure
    % produced valid results. Spectral information is displayed whenever
    % it is available, independently of the fitting outcome.
    %
    % Plotting is optional and does not affect the numerical analysis
    % result. Any plotting failure is reported as a warning without
    % invalidating an otherwise completed analysis.

    methods

        function obj = PermOscillationPlotTask()
            % PERMOSCILLATIONPLOTTASK Constructs the plotting task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("PermOscillationPlotTask");
        end

        function ok = execute(~, context)
            % EXECUTE Generates the time-domain and frequency-domain plots.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the original
            %              signal, fitted signal, time vector, fitting
            %              diagnostics, spectral data and analysis options.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the plotting task
            %         completed its execution.
            %
            % The method:
            %   1. Validates the analysis context and its options.
            %   2. Checks whether plotting is enabled.
            %   3. Displays the original signal and, when available,
            %      the fitted model in the first subplot.
            %   4. Displays the single-sided amplitude spectrum in the
            %      second subplot, when available.
            %   5. Includes the available fitting and spectral diagnostics
            %      in the corresponding subplot titles.
            %
            % If plotting is disabled, no figure is generated.
            % If fitting or spectral analysis is unavailable, the
            % corresponding information is simply omitted.
            % If plotting fails, a warning is issued and the numerical
            % analysis result remains unchanged.

            % Validate the shared analysis context.
            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('PermOscillationPlotTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            if ~isa(context.options, 'PermOscillationOptions') || ...
                    ~isscalar(context.options)

                error('PermOscillationPlotTask:InvalidOptions', ...
                    ['The context must contain a scalar ' ...
                     'PermOscillationOptions object.']);
            end

            % Mark the task as successfully executed.
            ok = true;

            % Skip visualization when plotting is disabled.
            if ~context.options.showPlot
                return;
            end

            % Generate both subplots without modifying the analysis result.
            try
                figure;

                % First subplot: time-domain signal and fitted model.
                subplot(2, 1, 1);

                plot(context.t, context.y, ...
                    'b', 'LineWidth', 1.5);
                hold on;

                if ~isempty(context.y_fit)
                    plot(context.t, context.y_fit, ...
                        'r--', 'LineWidth', 1.5);

                    legend('Original signal', 'Fitted model');
                else
                    legend('Original signal');
                end

                % Include the available fitting diagnostics in the title.
                if isfinite(context.R2)
                    title(['Signal and fitted model, R^2 = ' ...
                        num2str(context.R2, '%.3f')]);
                else
                    title('Original signal (fitting unavailable)');
                end

                xlabel('Sample index');
                ylabel('Signal');

                hold off;

                % Second subplot: single-sided amplitude spectrum.
                subplot(2, 1, 2);

                if ~isempty(context.spectrum) && ...
                    ~isempty(context.frequencies) && ...
                    numel(context.spectrum) == numel(context.frequencies)

                    plot(context.frequencies, context.spectrum, ...
                        'b', 'LineWidth', 1.5);

                    xlabel('Normalized frequency (cycles/sample)');
                    ylabel('Amplitude');

                    % Include the spectral dominance ratio when available.
                    if isfinite(context.spectralRatio)
                        title(['Single-sided amplitude spectrum, ratio = ' ...
                            num2str(context.spectralRatio, '%.3f')]);
                    else
                        title('Single-sided amplitude spectrum');
                    end

                else
                    % Display a message when spectral analysis is unavailable.
                    text(0.5, 0.5, 'Spectrum unavailable', ...
                        'HorizontalAlignment', 'center');

                    title('Single-sided amplitude spectrum');
                    axis off;
                end

            catch ME
                % Report plotting failures without invalidating the
                % numerical analysis result.
                warning('PermOscillationPlotTask:PlotFailed', ...
                    ['Unable to generate the plots. ' ...
                     'The numerical result is unchanged. ' ...
                     'Details: %s'], ...
                    ME.message);
            end

        end

    end

end
