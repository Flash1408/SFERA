function isDiv = isGenericDiv(y, opt, customFunc, params0)
%ISGENERICDIV Generic divergence detection using a user-defined parametric model.
%
%   isDiv = isGenericDiv(y, t, opt, customFunc, params0)
%
%   PARAMETERS:
%       y          - Numeric signal vector
%       t          - Time vector corresponding to y
%       opt        - Options object (must have property 'threshold')
%       customFunc - String or function handle representing the model:
%                    f(params, t) -> predicted y
%       params0    - Initial parameter guesses for the custom function
%
%   RETURNS:
%       isDiv      - Logical flag, true if the model fits y with R² > opt.threshold


    % --- Preprocessing ---
    y = y(:);
    t = (0:length(y)-1)';
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isDiv = false;
        return;
    end

    % --- Convert string to function handle if needed ---
    if ischar(customFunc)
        customFunc = str2func(customFunc);
    elseif ~isa(customFunc,'function_handle')
        error('customFunc must be a string or a function handle.');
    end

    % --- Fit bounds (optional: can be extended via opt) ---
    lb = [];
    ub = [];

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', ...
        'Display','off', ...
        'MaxIterations',1000, ...
        'TolFun',1e-6);

    try
        % Perform nonlinear least-squares fit
        params_fit = lsqcurvefit(customFunc, params0, t, y, lb, ub, options);

        % Compute fitted curve
        y_fit = customFunc(params_fit, t);

        % Compute R²
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR / SST;

        % Threshold check
        isDiv = R2 > 0.95;

        % Optional plot (commented out)
        % if isDiv
        %     figure;
        %     plot(t, y, 'b', 'LineWidth',1.5); hold on;
        %     plot(t, y_fit, 'r--', 'LineWidth',1.5);
        %     legend('Signal','Custom fit');
        %     title(['Custom fit, R^2 = ', num2str(R2,'%.2f')]);
        %     hold off;
        % end

    catch
        % If fitting fails, return false
        isDiv = false;
    end
end


