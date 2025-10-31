function isFifthRad = isFifthRadix(y)
    % ISFIFTHRADIX checks if a signal follows a 5th-root type trend
    % Model: y(t) = A * ((B * (t - H))^(1/5)) + K

    % Ensure column vector and remove NaN/Inf
    y = y(:);
    if iscell(y)
        y = cell2mat(y);
    end
    y = y(~isnan(y) & ~isinf(y));

    % If too short, skip
    if length(y) < 5
        isFifthRad = false;
        return;
    end

    % Normalize time to [0,1] for numerical stability
    t = (0:length(y)-1)' / length(y);

    % Model definition (nthroot handles negative inputs safely)
    model = @(params, t) params(1) * nthroot(params(2) * (t - params(3)), 5) + params(4);

    % Initial guesses
    A0 = std(y);       % amplitude scaling
    B0 = 1;            % horizontal scaling
    H0 = mean(t);      % horizontal shift
    K0 = mean(y);      % vertical offset
    params0 = [A0, B0, H0, K0];

    % Parameter bounds (loose but finite to avoid divergence)
    lb = [0, -10, 0, min(y)-abs(std(y))];    % A>=0, B can be negative, H in [0,1], K near min(y)
    ub = [Inf,  10, 1, max(y)+abs(std(y))];  % H bounded in [0,1], reasonable K

    % Fit options
    options = optimoptions('lsqcurvefit','Display','off','MaxIterations',1000,'TolFun',1e-6);

    try
        % Fit curve
        params_fit = lsqcurvefit(model, params0, t, y, lb, ub, options);

        % Predicted curve
        y_fit = model(params_fit, t);

        % Goodness of fit (R²)
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % Threshold
        threshold = 0.95;
        isFifthRad = R2 > threshold;

        if isFifthRad
            figure;
            plot(t,y,'b','LineWidth',1.5); hold on;
            plot(t,y_fit,'r--','LineWidth',1.5);
            legend('Real data','Fifth root fit');
            title(['R^2 = ' num2str(R2,'%.2f')]);
        end

    catch
        % If fitting fails
        isFifthRad = false;
    end
end
