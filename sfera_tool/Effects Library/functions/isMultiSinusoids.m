function multi_sinusoids = isMultiSinusoids(y, N)
    % ISMULTISINUSOIDS checks if a signal can be fitted with a sum of sinusoids
    % Model: y(t) = sum_k A_k * cos(omega_k * t + phi_k) + c
    % Returns true if the fit is good (R^2 > threshold)

    % --- Preprocessing ---
    y = y(:);
    if iscell(y)
        y = cell2mat(y);
    end
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        multi_sinusoids = false;
        return
    end

    % --- Time normalization ---
    t = (1:length(y))'/length(y);

    % --- Initial guesses ---
    C0 = mean(y);
    params0 = [];
    for k = 1:N
        Ak0 = (max(y)-min(y))/N;   % amp guess
        omega0 = 2*pi*k;           % increasing freq guess
        phi0 = 0;                  % phase guess
        params0 = [params0, Ak0, omega0, phi0];
    end
    params0 = [params0, C0];  % add offset

    % --- Model definition (vectorized) ---
    model = @(params,t) local_model(params,t,N);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit','TolFun',1e-6,'MaxIterations',1000,'Display','off');

    try
        % Fit model
        params_fit = lsqcurvefit(model, params0, t, y, [], [], options);

        % Compute fitted values
        y_fit = model(params_fit, t);

        % R-squared
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % Threshold
        threshold = 0.95;
        multi_sinusoids = R2 > threshold;

        % === Plot result ===
        if multi_sinusoids
            figure;
            plot(y,'b','LineWidth',1.5); hold on;
            plot(y_fit,'r--','LineWidth',1.5);
            legend('Real segment','Sum of sinusoids fit');
            title(['Multi-sinusoid fit, R^2 = ' num2str(R2,'%.2f')]);
            hold off;
        end

    catch 
        multi_sinusoids = false;
    end
end

function y_fit = local_model(params,t,N)
    y_fit = zeros(size(t));
    for k = 1:N
        A = params(3*(k-1)+1);
        omega = params(3*(k-1)+2);
        phi = params(3*(k-1)+3);
        y_fit = y_fit + A*cos(omega*t + phi);
    end
    y_fit = y_fit + params(end);
end
