function divergent_oscillations = isDivOscillating(y, opt)
    % ISDIVOSCILLATING checks if a signal shows divergent oscillations
    % Model: y(t) = A * exp(beta * t) * cos(omega * t + phi)
    % Requires at least 2 significant peaks
    %
    % Returns true if beta > 0 and R^2 > threshold

    arguments
        y double
        opt divOscillationOptions = divOscillationOptions(); % default se non fornito
    end

    % --- Preprocessing ---
    y = y(:);
    y = y(~isnan(y) & ~isinf(y));

    % If signal too short, return false
    if length(y) < 5
        divergent_oscillations = false;
        return;
    end

    % --- Peaks check (at least 3 significant peaks) ---
    localRange = max(y) - min(y);
    validPeaks = findMaxPeaks(y, 0.1 * localRange, 100);
    if numel(validPeaks) < 3
        divergent_oscillations = false;
        return;
    end

    % --- Time normalization ---
    t = (1:length(y))';

    % --- Initial guesses ---
    A0 = max(abs(y));   % amplitude
    beta0 = 0.01;       % >0 for divergent
    omega0 = 1;      % guess 1 Hz
    phi0 = 0;
    opt.params0 = [A0, beta0, omega0, phi0];

    % --- Bounds ---
    lb = opt.lb;
    ub = opt.ub;

    % --- Model definition ---
    model = @(params, t) params(1) * exp(params(2) * t) .* cos(params(3) * t + params(4));

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', ...
    'TolFun', opt.tolFun, ...
    'MaxIterations', opt.maxIter, ...
    'Display', 'off');

    try
        % --- Fit model ---
        params_fit = lsqcurvefit(model, opt.params0, t, y, lb, ub, options);

        % --- Divergence requires beta > 0 ---
        beta_fit = params_fit(2);
        if beta_fit <= 0
            divergent_oscillations = false;
            return;
        end

        % --- Compute fitted curve ---
        y_fit = model(params_fit, t);

        % --- Compute R^2 ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % --- Threshold criterion ---
        divergent_oscillations = R2 > opt.threshold;

        % --- Optional plot ---
        if divergent_oscillations && opt.showPlot
            figure;
            plot(y, 'b', 'LineWidth', 1.5); hold on;
            plot(y_fit, 'r--', 'LineWidth', 1.5);
            legend('Signal','Fitted');
            title(['Divergent fit, R^2 = ' num2str(R2,'%.2f')]);
            hold off;
        end

    catch
        divergent_oscillations = false;
    end
end



