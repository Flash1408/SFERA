function isRungeLike = isRunge(y, opt)
    % ISRUNGE checks if a signal follows a Runge-like function
    % Model: y(t) = A / (1 + B * (t - C)^2) + D
    %
     % Returns true if the fit is good (R^2 > threshold)

    arguments
        y double
        opt rungeOptions = rungeOptions()
    end

    % --- Preprocessing ---
    y = y(:);
    % if iscell(y)
    %     y = cell2mat(y);
    % end
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isRungeLike = false;
        return;
    end

    % --- Time vector normalized to [0,1] ---
    t = (0:length(y)-1)';

    % --- Model definition ---
    model = @(p, t) p(1) ./ (1 + p(2) * (t - p(3)).^2) + p(4);

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

        % --- Compute R² ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % --- Decision ---
        isRungeLike = R2 > opt.threshold;

        % --- Optional visualization ---
        if isRungeLike && opt.showPlot
            figure;
            plot(t, y, 'b', 'LineWidth', 1.5); hold on;
            plot(t, y_fit, 'r--', 'LineWidth', 1.5);
            legend('Real data', 'Runge fit');
            title(['Runge model, R^2 = ' num2str(R2, '%.2f')]);
            hold off;
        end

    catch
        isRungeLike = false;
    end
end
