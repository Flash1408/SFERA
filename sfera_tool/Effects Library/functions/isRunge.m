function runge = isRunge(y)
    % ISRUNGE checks if a signal follows a Runge-like function
    % Model: y(t) = A / (1 + B * (t - C)^2) + D

    % Ensure column vector and remove invalid values
    y = y(:);
    if iscell(y)
        y = cell2mat(y);
    end
    y = y(~isnan(y) & ~isinf(y));

    % If too short, skip
    if length(y) < 5
        runge = false;
        return;
    end

    % Normalize time to [0,1] for stability
    t = (0:length(y)-1)' / length(y);

    % Model definition
    model = @(params, t) params(1) ./ (1 + params(2) * (t - params(3)).^2) + params(4);

    % Initial guesses
    A0 = max(y) - min(y);   % amplitude
    B0 = 10;                % curvature strength
    C0 = mean(t);           % horizontal shift
    D0 = mean(y);           % vertical offset
    params0 = [A0, B0, C0, D0];

    % Parameter bounds
    lb = [0, 0, 0, min(y) - abs(std(y))];    % A>=0, B>=0, C in [0,1], D near min(y)
    ub = [Inf, 1e3, 1, max(y) + abs(std(y))]; % B limited to avoid flatness

    % Fit options
    options = optimoptions('lsqcurvefit', 'Display', 'off', ...
                           'MaxIterations', 1000, 'TolFun', 1e-6);

    try
        % Fit curve
        params_fit = lsqcurvefit(model, params0, t, y, lb, ub, options);

        % Predicted curve
        y_fit = model(params_fit, t);

        % R² goodness of fit
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % Threshold
        threshold = 0.95;
        runge = R2 > threshold;

        if runge
            figure;
            plot(t,y,'b','LineWidth',1.5); hold on;
            plot(t,y_fit,'r--','LineWidth',1.5);
            legend('Real data','Runge fit');
            title(['Runge model, R^2 = ' num2str(R2,'%.2f')]);
        end

    catch
        % If fitting fails
        runge = false;
    end
end
