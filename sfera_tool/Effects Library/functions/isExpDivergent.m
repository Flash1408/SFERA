function isExp = isExpDivergent(y)
    % ISEXP DIVERGENT checks if the signal y fits an exponential trend
    % Returns true if the exponential fit has R^2 > threshold, false otherwise

    % Force y to be a column and remove invalid values
    y = y(:);
    if iscell(y)
        y = cell2mat(y);
    end
    y = y(~isnan(y) & ~isinf(y));

    % If the signal is too short, fitting is not meaningful
    if length(y) < 5
        isExp = false;
        return
    end

    % Normalize time axis to [0,1] to avoid overflow in exp(B*t)
    % t = (0:length(y)-1)'/length(y);
    % 
    % % Exponential model function: y = A * exp(B * t)
    % model = @(params, t) params(1) * exp(params(2) * t);
    % 
    % % Initial guess for parameters
    % % A0 = first value of y (or epsilon if y(1)=0)
    % % B0 = small positive slope
    % A0 = max(y(1), eps);
    % params0 = [A0, 0.01];
    % 
    % % Parameter bounds to prevent divergence
    % lb = [-Inf, -10];   % A unbounded, B not too negative
    % ub = [Inf, 10];  % A unbounded, B not too large positive

    t = (0:length(y)-1)';  % Keep original scale
    model = @(p,t) p(1) + p(2)*exp(p(3)*t);  % offset 
    
    A0 = min(y);  % or mean
    B0 = max(y)-min(y);
    C0 = -0.00001; % small negative decay
    params0 = [A0, B0, C0];
    
    lb = [-Inf, -Inf, -Inf];
    ub = [Inf, Inf, Inf];


    % Fit with lsqcurvefit
    options = optimoptions('lsqcurvefit', 'Display', 'off');
    try
        % Optimize parameters
        params_fit = lsqcurvefit(model, params0, t, y, lb, ub, options);

        % Compute fitted values
        y_fit = model(params_fit, t);

        % Compute R-squared to evaluate goodness of fit
        residuals = y - y_fit;
        SSR = sum(residuals.^2);              % Sum of squared residuals
        SST = sum((y - mean(y)).^2);          % Total sum of squares
        R2 = 1 - SSR / SST;                   % Coefficient of determination

        % Decide if exponential fit is good enough
        threshold = 0.95;
        isExp = R2 > threshold;
        
        % if isExp
            % === Plot result ===
            % figure;
            % plot(y,'b','LineWidth',1.5); hold on;
            % plot(y_fit,'r--','LineWidth',1.5);
            % legend('Real segment','Exponential fit');
            % title(['Exponential fit, R^2 = ' num2str(R2,'%.2f')]);
            % hold off;
        % end
    catch
        % If fitting fails (e.g., numerical issues), return false
        isExp = false;
    end
end
