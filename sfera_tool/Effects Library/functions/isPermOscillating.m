function isPerm = isPermOscillating(y, opt)
    % ISPERMOSCILLATING checks if a signal exhibits permanent oscillations
    % Model: y(t) = A * cos(omega * t + phi)
    % Uses both curve fitting and spectral analysis
    %
    % Returns true if:
    %   - fit is good (R² > threshold)
    %   - beta ~ 0 (no damping)
    %   - AND/OR strong spectral peak is detected

    arguments
        y double
        opt permOscillationOptions = permOscillationOptions()
    end

    % --- Preprocessing ---
    y = y(:);
    % if iscell(y)
    %     y = cell2mat(y);
    % end
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isPerm = false;
        return
    end

    % --- Peak check ---
    [validPeaks] = findMaxPeaks(y, 0.2 * max(y), 100);
    if numel(validPeaks) < 3
        isPerm = false;
        return
    end

    % --- Time normalization ---
    t = (0:length(y)-1)';

    % --- Initial guesses ---
    A0 = max(abs(y));
    beta0 = 0;           % no damping
    omega0 = 2 * pi;     % frequency guess
    phi0 = 0;
    opt.params0 = [A0, beta0, omega0, phi0];

    % --- Model ---
    model = @(p, t) p(1) * exp(p(2) * t) .* cos(p(3) * t + p(4));

    % --- Optimization ---
    options = optimoptions('lsqcurvefit', ...
        'TolFun', opt.tolFun, ...
        'MaxIterations', opt.maxIter, ...
        'Display', 'off');

    try
        params_fit = lsqcurvefit(model, opt.params0, t, y, opt.lb, opt.ub, options);
        beta_fit = params_fit(2);

        % --- Check for nearly zero damping ---
        if abs(beta_fit) > opt.betaTol
            isPerm = false;
            return
        end

        % --- Compute R² ---
        y_fit = model(params_fit, t);
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % --- Primary criterion: R² threshold ---
        isPerm = R2 > opt.threshold;

        % --- Spectral check (optional or fallback) ---
        if ~isPerm && opt.useSpectralCheck
            Y_fft = fft(y);
            N = length(y);
            P2 = abs(Y_fft / N);
            P1 = P2(1:floor(N/2) + 1);
            P1(2:end-1) = 2 * P1(2:end-1);

            % Normalize and compute spectral norm
            Pnorm = P1 / sum(P1);
            spectralRatio = max(Pnorm);  % dominance of one frequency

            % If dominant frequency is clear enough
            isPerm = spectralRatio > opt.spectralThreshold;
        end

        % --- Optional plot ---
        if isPerm && opt.showPlot
            figure;
            subplot(2,1,1)
            plot(y,'b','LineWidth',1.5); hold on;
            plot(y_fit,'r--','LineWidth',1.5);
            legend('Signal','Fit'); title(sprintf('R² = %.3f', R2));
            hold off;

            subplot(2,1,2)
            f = (0:floor(N/2)) / N;
            plot(f, P1); title('Spectrum'); xlabel('Frequency'); ylabel('Amplitude');
        end

    catch
        isPerm = false;
    end
end


