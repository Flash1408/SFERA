function isExp = isExpDivergent(y, opt)
    % ISEXP DIVERGENT checks if the signal y fits an exponential trend
    % Model: y(t) = A + B * exp(C * t)
    % Returns true if the exponential fit has R^2 > threshold

    arguments
        y double
        opt expDivergenceOptions = expDivergenceOptions() 
    end

    % --- Preprocessing ---
    y = y(:);
    % if iscell(y)
    %     y = cell2mat(y);
    % end
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isExp = false;
        return
    end

    % --- Time vector ---
    t = (0:length(y)-1)';

    % --- Model definition ---
    model = @(p,t) p(1) + p(2)*exp(p(3)*t); 

    % --- Initial guesses ---
    A0 = min(y);  % baseline
    B0 = max(y) - min(y);
    C0 = opt.initC0;  % preso dall’oggetto opzioni
    opt.params0 = [A0, B0, C0];

    % --- Bounds ---
    lb = opt.lb;
    ub = opt.ub;

    % --- Optimization options ---
    options = optimoptions('lsqcurvefit', ...
        'Display', 'off', ...
        'TolFun', opt.tolFun, ...
        'MaxIterations', opt.maxIter);

    try
        % --- Fit model ---
        params_fit = lsqcurvefit(model, opt.params0, t, y, lb, ub, options);

        % --- Compute fitted curve ---
        y_fit = model(params_fit, t);

        % --- Compute R² ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR / SST;

        % --- Threshold criterion ---
        isExp = R2 > opt.threshold;
        
        % --- Optional plot ---
        if isExp && opt.showPlot            
            figure;
            plot(y,'b','LineWidth',1.5); hold on;
            plot(y_fit,'r--','LineWidth',1.5);
            legend('Real segment','Curve fit');
            title(['Exponential fit, R^2 = ' num2str(R2,'%.2f')]);
            hold off;
         end

    catch
        isExp = false;
    end
end
