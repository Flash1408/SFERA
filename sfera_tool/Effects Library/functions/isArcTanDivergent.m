function isArcTan = isArcTanDivergent(y)
    
    % Create a vector of indices for t-axis
    y = y(:);
    if iscell(y)
        y = cell2mat(y);
    end
    y = y(~isnan(y) & ~isinf(y));

    % If the signal is too short, return false
    if length(y) < 5
        isArcTan = false;
        return;
    end

    % Time vector normalized to [0,1] to improve stability
    t = (0:length(y)-1)' / length(y);
    
    % ArcTangent model function
    model = @(params, t) params(1) * atan((x - params(2)) / params(3)) + params(4);
    
    % Initial guess for parameters in the model 
    A0 = max(y) - min(y);
    H0 = mean(t);
    B0 = (max(t) - min(t))/2;
    K0 = mean(y);
    params0 = [A0, H0, B0, K0];

    % Parameter bounds (to prevent instability)
    lb = [-10*(max(y) - min(y)), min(t), eps, min(y)];
    ub = [ 10*(max(y) - min(y)), max(t), max(t) - min(t), max(y)];

    
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
        isArcTan = R2 > threshold;
        
        if isArcTan
            figure;
            plot(t,y,'b','LineWidth',1.5); hold on;
            plot(t,y_fit,'r--','LineWidth',1.5);
            legend('Real signal','Arctangent fit');
            title(['R^2 = ' num2str(R2,'%.2f')]);
            hold off;
        end
        
    catch
        % If fit fails
        isArcTan = false;
    end
end

