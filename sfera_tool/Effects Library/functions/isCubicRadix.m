function isCubicRad = isCubicRadix(y)
    % ISCUBICRADIX checks if a signal follows a cubic radix trend
    % Model: y(t) = A * ((B * (t - H)).^(1/3)) + K

    % Force column vector and remove invalid values
    y = y(:);
    if iscell(y)
        y = cell2mat(y);
    end
    y = y(~isnan(y) & ~isinf(y));

    % If the signal is too short, return false
    if length(y) < 5
        isCubicRad = false;
        return;
    end

    % Time vector normalized to [0,1] to improve stability
    t = (0:length(y)-1)' / length(y);

    % Model definition (safe cubic root: sign(x).*abs(x).^(1/3))
    model = @(params, t) params(1) .* sign(params(2) .* (t - params(3))) ...
                                  .* abs(params(2) .* (t - params(3))).^(1/3) ...
                                  + params(4);

    % Initial parameter guesses
    A0 = std(y);      % amplitude
    B0 = 1;           % scaling of x
    H0 = 0.5;         % shift (centered in middle of time vector)
    K0 = mean(y);     % vertical offset
    params0 = [A0, B0, H0, K0];

    % Parameter bounds (to prevent instability)
    lb = [0, 0, 0, -Inf];
    ub = [Inf, Inf, 1, Inf];

    % Fit options
    options = optimoptions('lsqcurvefit', ...
                           'Display','off', ...
                           'MaxIterations',1000, ...
                           'TolFun',1e-6);

    try
        % Fit model
        params_fit = lsqcurvefit(model, params0, t, y, lb, ub, options);

        % Fitted values
        y_fit = model(params_fit, t);

        % R-squared
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % Threshold for accepting cubic radix behavior
        threshold = 0.95;
        isCubicRad = R2 > threshold;
        
        if isCubicRad
            figure;
            plot(t,y,'b','LineWidth',1.5); hold on;
            plot(t,y_fit,'r--','LineWidth',1.5);
            legend('Real signal','CubicRadix fit');
            title(['Cubic radix fit, R^2 = ' num2str(R2,'%.2f')]);
            hold off;
        end
        
    catch
        % If fit fails
        isCubicRad = false;
    end
end


