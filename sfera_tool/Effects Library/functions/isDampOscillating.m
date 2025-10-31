function damping_oscillations = isDampOscillating(y)
    % ISDAMPOSCILLATING checks if a signal exhibits damped oscillations
    % Model: y(t) = A * exp(beta * t) * cos(omega * t + phi) + c
    % Returns true if the fit is good (R^2 > threshold) and beta < 0

    % --- Preprocessing ---
    y = y(:);
    if iscell(y)
        y = cell2mat(y);
    end
    y = y(~isnan(y) & ~isinf(y));

    % If the signal is too short, return false
    if length(y) < 5
        damping_oscillations = false;
        return
    end

    % --- Peak check (at least 2 significant peaks) --- 
    [validPeaks] = findMaxPeaks(y, 0.2*max(y), 100);
    

    if numel(validPeaks) < 3
        damping_oscillations = false;
        return;
    end

    % --- Time normalization ---
    t = (1:length(y))'/length(y);

    % --- Initial guesses ---
    A0 = max(abs(y));    % amplitude
    beta0 = -0.01;       % negative damping
    omega0 = 1;          % frequency
    phi0 = 0;            % phase
    C0 = mean(y);        % offset
    params0 = [A0, beta0, omega0, phi0, C0];

    % --- Parameter bounds ---
    % lb = [0, -10, 0, -pi];   % A>=0, beta negative, omega positive, phi in [-pi,pi]
    % ub = [Inf, 0, 50, pi];   % beta <= 0, omega reasonable, phi bounded

    % --- Model definition ---
    model = @(params, t) params(1) * exp(params(2) * t) .* cos(params(3) * t + params(4)) + params(5);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', 'TolFun',1e-6, 'MaxIterations',1000, 'Display','off');

    try
        % Fit model
        params_fit = lsqcurvefit(model, params0, t, y, [], [], options);

        % Check beta (must be negative for damping)
        beta_fit = params_fit(2);
        if beta_fit >= 0
            damping_oscillations = false;
            return
        end

        % Compute fitted values
        y_fit = model(params_fit, t);

        % R-squared
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % Threshold for accepting damped oscillation
        threshold = 0.95;
        damping_oscillations = R2 > threshold;

        if damping_oscillations
            % === Plot result ===
            figure;
            plot(y,'b','LineWidth',1.5); hold on;
            plot(y_fit,'r--','LineWidth',1.5);
            legend('Real segment','Curve fit');
            title(['Damping fit, R^2 = ' num2str(R2,'%.2f')]);
            hold off;
         end

    catch
        % If fitting fails, return false
        damping_oscillations = false;
    end
end




