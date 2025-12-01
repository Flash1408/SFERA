function damping_oscillations = isDampOscillating(y, opt)
    % ISDAMPOSCILLATING checks if a signal exhibits damped oscillations
    % Model: y(t) = A + B* exp(beta * t) * cos(omega * t + phi) 
    %
    % Returns true if the fit is good (R^2 > threshold) and beta < 0

    arguments
        y double
        opt dampOscillationOptions = dampOscillationOptions(); 
    end

    % --- Preprocessing ---
    y = y(:);
    y = y(~isnan(y) & ~isinf(y));

    % If the signal is too short, return false
    if length(y) < 5
        damping_oscillations = false;
        return
    end

    % --- Peak check (at least 3 significant peaks) --- 
    localRange = max(y) - min(y);
    validPeaks = findMaxPeaks(y, 0.1 * localRange, 100);
    if numel(validPeaks) < 3
        damping_oscillations = false;
        return;
    end

    % --- Time vector ---
    t = (1:length(y))';

    % --- Initial parameters ---
    A0 = max(abs(y));    % amplitude
    beta0 = -0.01;       % negative damping
    omega0 = 0.01;       % frequency
    phi0 = 0;            % phase
    C0 = mean(y);        % offset
    opt.params0 = [A0, beta0, omega0, phi0, C0];

    % --- Bounds ---
    lb = opt.lb;
    ub = opt.ub;

    % --- Model definition ---
    model = @(params, t) params(1) * exp(params(2) * t) .* cos(params(3) * t + params(4)) + params(5);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', ...
    'TolFun', opt.tolFun, ...
    'MaxIterations', opt.maxIter, ...
    'Display', 'off');
    
    try
        % --- Fit model ---
        params_fit = lsqcurvefit(model, opt.params0, t, y, lb, ub, options);

        % --- Check amplitude ---
        A_fit = abs(params_fit(1));
        if A_fit < 0.05 * (max(y)-min(y))
            damping_oscillations = false;
            return;
        end

        % --- Check beta (must be negative for damping) ---
        beta_fit = params_fit(2);
        if beta_fit >= 0
            damping_oscillations = false;
            return
        end

        % --- Check frequency ---
        omega_fit = params_fit(3);
        if omega_fit < 0.5
            damping_oscillations = false;
            return;
        end


        % --- Compute fitted values ---
        y_fit = model(params_fit, t);

        % --- Compute R-squared ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % --- Threshold criterion ---
        damping_oscillations = R2 > opt.threshold;
        
        % --- Optional plot ---
        if  opt.showPlot     
            figure;
            plot(y,'b','LineWidth',1.5); hold on;
            plot(y_fit,'r--','LineWidth',1.5);
            legend('Real segment','Curve fit');
            title(['Damping fit, R^2 = ' num2str(R2,'%.2f')]);
            hold off;
        end
    catch
        damping_oscillations = false;
    end
end




