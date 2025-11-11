function isMulti = isMultiSinusoids(y, opt)
    % ISMULTISINUSOIDS checks if a signal can be fitted with a sum of sinusoids
    % Model: y(t) = sum_k A_k * cos(omega_k * t + phi_k) + c
    %
    % Returns true if the fit is good (R^2 > threshold)

    arguments
        y double
        opt multiSinusoidsOptions = multiSinusoidsOptions()
    end

    % --- Preprocessing ---
    y = y(:);
    % if iscell(y)
    %     y = cell2mat(y);
    % end
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isMulti = false;
        return
    end

    % --- Time vector normalized to [0,1] ---
    t = (1:length(y))';

    % --- Initial guesses ---
    C0 = mean(y);
    params0 = [];
    for k = 1:opt.N
        Ak0 = (max(y)-min(y))/opt.N;
        omega0 = 2*pi*k;  % increasing frequency guess
        phi0 = 0;
        params0 = [params0, Ak0, omega0, phi0]; %#ok<AGROW>
    end
    opt.params0 = [params0, C0];

    % --- Model definition ---
    model = @(params,t) local_model(params,t,opt.N);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit', ...
        'TolFun', opt.tolFun, ...
        'MaxIterations', opt.maxIter, ...
        'Display', 'off');

    try
        % --- Fit model ---
        params_fit = lsqcurvefit(model, opt.params0, t, y, [], [], options);

        % --- Compute fitted values ---
        y_fit = model(params_fit, t);

        % --- R-squared ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % --- Decision ---
        isMulti = R2 > opt.threshold;

        % --- Optional plot ---
        if isMulti && opt.showPlot
            figure;
            plot(y,'b','LineWidth',1.5); hold on;
            plot(y_fit,'r--','LineWidth',1.5);
            legend('Real segment','Sum of sinusoids fit');
            title(['Multi-sinusoid fit, R^2 = ' num2str(R2,'%.2f')]);
            hold off;
        end

    catch
        isMulti = false;
    end
end


function y_fit = local_model(params, t, N)
    % LOCAL_MODEL builds the sum of N cosine components
    y_fit = zeros(size(t));
    for k = 1:N
        A = params(3*(k-1)+1);
        omega = params(3*(k-1)+2);
        phi = params(3*(k-1)+3);
        y_fit = y_fit + A * cos(omega * t + phi);
    end
    y_fit = y_fit + params(end);
end
