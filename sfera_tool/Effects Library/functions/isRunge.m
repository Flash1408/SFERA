function isRungeLike = isRunge(y, opt)
    % ISRUNGE checks if a signal follows a Runge-like function
    % Model: y(t) = A + B / (1 + C*(t - H)^2) 

    arguments
        y double
        opt rungeOptions = rungeOptions()
    end

    % --- Preprocessing ---
    y = y(:);
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isRungeLike = false;
        return;
    end

    % --- Time vector ---
    t = linspace(0,1,length(y))';

    % --- Model ---
    model = @(p,t) p(1) ./ (1 + p(2) * (t - p(3)).^2) + p(4);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', ...
        'Display', 'off', ...
        'MaxIterations', opt.maxIter, ...
        'TolFun', opt.tolFun);

    try
        % --- Fit parameters ---
        params_fit = lsqcurvefit(model, opt.params0, t, y, opt.lb, opt.ub, options);

        A = params_fit(1);
        B = params_fit(2);
        C = params_fit(3);
        D = params_fit(4);

        y_fit = model(params_fit, t);

        % --- R² ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % --- Validation checks ---
        % 1) B must not be too small (avoid degenerate straight line)
        if B < 1
            isRungeLike = false;
            return;
        end

        % 2) A must be large enough (visible peak)
        if A < 0.05 * (max(y) - min(y))
            isRungeLike = false;
            return;
        end

        % 3) Peak center C must lie well inside the signal
        if C < 0.1 || C > 0.9
            isRungeLike = false;
            return;
        end

        % 4) Detect single dominant peak
        [pks, locs] = findpeaks(y, 'MinPeakProminence', 0.05*range(y));
        if length(pks) ~= 1
            isRungeLike = false;
            return;
        end

        % 5) Runge must not be monotonic
        dy = diff(y);
        if all(dy >= 0) || all(dy <= 0)
            isRungeLike = false;
            return;
        end

        % 6) Symmetry check around peak (Runge should be approx symmetric)
        idxC = round(C * length(y));
        left  = y(1:idxC);
        right = y(idxC:end);

        if abs(std(left) - std(right)) > 0.3 * std(y)
            isRungeLike = false;
            return;
        end

        % --- Threshold criterion ---
        isRungeLike = R2 > opt.threshold;

        % --- Optional Plot ---
        if isRungeLike && opt.showPlot
            figure;
            plot(t, y, 'b','LineWidth',1.5); hold on;
            plot(t, y_fit, 'r--','LineWidth',1.5);
            legend('Signal','Runge fit');
            title(['Runge model, R^2 = ' num2str(R2,'%.2f')]);
            hold off;
        end

    catch
        isRungeLike = false;
    end
end

