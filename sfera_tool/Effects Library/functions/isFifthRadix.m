function isFifthRad = isFifthRadix(y, opt)
    % ISFIFTHRADIX checks if a signal follows a 5th-root type trend
    % Model: y(t) = A * ((B * (t - H))^(1/5)) + K
    %
    % Returns true if R² > threshold.

    arguments
        y double
        opt fifthRadixOptions = fifthRadixOptions()
    end

    % --- Preprocessing ---
    y = y(:);
    % if iscell(y)
    %     y = cell2mat(y);
    % end
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isFifthRad = false;
        return;
    end

    % --- Time normalization ---
    t = (0:length(y)-1)';

    % --- Model definition (safe 5th root) ---
    model = @(p, t) p(1) * nthroot(p(2) * (t - p(3)), 5) + p(4);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', ...
        'Display', 'off', ...
        'MaxIterations', opt.maxIter, ...
        'TolFun', opt.tolFun);

    try
        % --- Fit model ---
        params_fit = lsqcurvefit(model, opt.params0, t, y, opt.lb, opt.ub, options);

        % --- Compute fitted curve ---
        y_fit = model(params_fit, t);

        % --- Compute R² ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR / SST;

        % --- Threshold criterion ---
        isFifthRad = R2 > opt.threshold;

        % --- Optional plot ---
        if isFifthRad && opt.showPlot
            figure;
            plot(t, y, 'b', 'LineWidth', 1.5); hold on;
            plot(t, y_fit, 'r--', 'LineWidth', 1.5);
            legend('Real data', 'Fifth root fit');
            title(['Fifth root fit, R^2 = ' num2str(R2, '%.2f')]);
            hold off;
        end
    catch
        isFifthRad = false;
    end
end
