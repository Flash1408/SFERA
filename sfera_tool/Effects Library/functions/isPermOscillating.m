function permanent_oscillations = isPermOscillating(y)
    % ISPERMOSCILLATING checks if a signal exhibits permanent oscillations
    % Model: y(t) = A * cos(omega * t + phi)
    % Returns true if beta ~ 0 (no damping) and fit is good (R^2 > threshold)

     % --- Preprocessing ---
    y = y(:);
    if iscell(y)
        y = cell2mat(y);
    end
    y = y(~isnan(y) & ~isinf(y));

    % If signal too short, return false
    if length(y) < 5
        permanent_oscillations = false;
        return
    end

    % --- Peak check (at least 2 significant peaks) ---
    [validPeaks] = findMaxPeaks(y, 0.2*max(y), 100);
    

    if numel(validPeaks) < 3
        permanent_oscillations = false;
        return;
    end

    % --- Time normalization ---
    t = (0:length(y)-1)' / length(y);

    % --- Initial guesses ---
    A0 = max(abs(y));
    beta0 = 0;           % No damping
    omega0 = 2*pi;       % frequency
    phi0 = 0;            % phase
    params0 = [A0, beta0, omega0, phi0];

    % --- Parameter bounds ---
    lb = [0, -1e-6, 0, -pi];  % A>=0, beta ~0, omega>=0, phi bounded
    ub = [Inf, 1e-6, 50, pi]; % beta ~0, omega reasonable, phi bounded

    % --- Model definition ---
    model = @(params, t) params(1) * exp(params(2) * t) .* cos(params(3) * t + params(4));

    % --- Fit options ---
    options = optimoptions('lsqcurvefit','TolFun',1e-6,'MaxIterations',1000,'Display','off');

    try
        % Fit model
        params_fit = lsqcurvefit(model, params0, t, y, lb, ub, options);

        % Check beta (should be ~0 for permanent oscillations)
        beta_fit = params_fit(2);
        if abs(beta_fit) > 1e-9
            permanent_oscillations = false;
            return
        end

        % Compute fitted values
        y_fit = model(params_fit, t);

        % R-squared
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % Threshold for good fit
        threshold = 0.95;
        permanent_oscillations = R2 > threshold;

        if permanent_oscillations
            % === Plot result ===
            figure;
            plot(y,'b','LineWidth',1.5); hold on;
            plot(y_fit,'r--','LineWidth',1.5);
            legend('Real segment','Curve fit');
            title(['R^2 = ' num2str(R2,'%.2f')]);
            hold off;
        end

    catch
        % If fitting fails, return false
        permanent_oscillations = false;
    end
end

% % Calculate the Fourier transform of the signal
% Y_fft = fft(y);
% N = length(y);
% 
% % Calculate the power spectrum
% P2 = abs(Y_fft / N);
% P1 = P2(1:N/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% 
% % Find the dominant frequency
% [~, idx] = max(P1);
% 
% % Check if there is a well-defined dominant frequency (stable oscillation)
% if idx > 1 && idx < N/2
%     permanent_oscillations = true;  % Stable oscillation detected
% else
%     permanent_oscillations = false; % No stable oscillation detected
% end

