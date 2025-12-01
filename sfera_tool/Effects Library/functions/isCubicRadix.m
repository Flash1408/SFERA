function isCubicRad = isCubicRadix(y, opt)
    % ISCUBICRADIX checks if a signal follows a cubic radix trend
    % Model: y(t) = A + B* ((C * (t - H)).^(1/3))
    %
    % Returns true if R^2 > threshold.

    arguments
        y double
        opt cubicRadixOptions = cubicRadixOptions()
    end

    % --- Preprocessing ---
    y = y(:);
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isCubicRad = false;
        return;
    end

    % --- Time vector ---
    t = (0:length(y)-1)';

    % --- Model definition (safe cubic root) ---
    model = @(p, t) p(1) .* sign(p(2) .* (t - p(3))) ...
                       .* abs(p(2) .* (t - p(3))).^(1/3) ...
                       + p(4);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', ...
                           'Display', 'off', ...
                           'MaxIterations', opt.maxIter, ...
                           'TolFun', opt.tolFun);

    try
        % --- Fit model ---
        params_fit = lsqcurvefit(model, opt.params0, t, y, opt.lb, opt.ub, options);

        % --- Compute fitted values ---
        y_fit = model(params_fit, t);

        % --- Compute R-squared ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % --- Threshold criterion ---
        isCubicRad = R2 > opt.threshold;

        % --- Optional plot ---
        if isCubicRad && opt.showPlot
            figure;
            plot(t, y, 'b', 'LineWidth', 1.5); hold on;
            plot(t, y_fit, 'r--', 'LineWidth', 1.5);
            legend('Real signal', 'CubicRadix fit');
            title(['Cubic radix fit, R^2 = ' num2str(R2, '%.2f')]);
            hold off;
        end

    catch
        isCubicRad = false;
    end
end



