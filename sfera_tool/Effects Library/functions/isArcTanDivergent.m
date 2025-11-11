function isArcTan = isArcTanDivergent(y, opt)
    % ISARCTANDIVERGENT checks if a signal follows an arctangent divergence trend.
    % Model: y(t) = A * atan((t - H) / B) + K
    %
     % Returns true if the fit is good (R^2 > threshold)

    arguments
        y double
        opt arcTanOptions = arcTanOptions()
    end

    % --- Preprocessing ---
    y = y(:);
    % if iscell(y)
    %     y = cell2mat(y);
    % end
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isArcTan = false;
        return;
    end

    % --- Normalized time vector ---
    t = (0:length(y)-1)';

    % --- Model definition ---
    model = @(p, t) p(1) * atan((t - p(2)) / p(3)) + p(4);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', ...
        'Display', 'off', ...
        'MaxIterations', opt.maxIter, ...
        'TolFun', opt.tolFun);

    try
        % --- Fit curve ---
        params_fit = lsqcurvefit(model, opt.params0, t, y, opt.lb, opt.ub, options);

        % --- Predicted curve ---
        y_fit = model(params_fit, t);

        % --- R² ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR / SST;

        % --- Check threshold ---
        isArcTan = R2 > opt.threshold;

        % --- Optional plot ---
        if isArcTan && opt.showPlot
            figure;
            plot(t, y, 'b', 'LineWidth', 1.5); hold on;
            plot(t, y_fit, 'r--', 'LineWidth', 1.5);
            legend('Real signal', 'Arctangent fit');
            title(['Arctangent fit, R^2 = ' num2str(R2, '%.2f')]);
            hold off;
        end

    catch
        isArcTan = false;
    end
end


