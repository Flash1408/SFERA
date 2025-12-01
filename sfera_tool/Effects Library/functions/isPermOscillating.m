function isPerm = isPermOscillating(y, opt)
    % ISPERMOSCILLATING checks if a signal exhibits permanent oscillations
    % Model: y(t) = A * cos(omega * t + phi)
    % Uses both curve fitting and spectral analysis
    %
    % Returns true if:
    %   - fit is good (R² > threshold)
    %   - beta ~ 0 (no damping or divergence)
    %   - OR strong spectral peak is detected

    arguments
        y double
        opt permOscillationOptions = permOscillationOptions()
    end

    % --- Preprocessing ---
    y = y(:);
    y = y(~isnan(y) & ~isinf(y));

    if length(y) < 5
        isPerm = false;
        return
    end

    % --- Peak check (quick reject) ---
    localRange = max(y) - min(y);
    validPeaks = findMaxPeaks(y, 0.1 * localRange, 100);
    if numel(validPeaks) < 3
        isPerm = false;
        return
    end

    % --- Time vector ---
    t = (1:length(y))';     

    % --- Initial parameters ---
    A0 = (max(y) - min(y))/2;
    offset0 = mean(y);
    omega0 = 2*pi;                    
    phi0 = 0;
    p0 = [A0, 0, omega0, phi0, offset0];

    % --- Bounds ---
    lb = [-Inf -opt.betaTol 0 -2*pi min(y)];
    ub = [ Inf  opt.betaTol Inf  2*pi max(y)];

    % --- Model definition ---
    model = @(p,t) p(1) * exp(p(2)*t) .* cos(p(3)*t + p(4)) + p(5);

    % --- Fit options ---
    options = optimoptions('lsqcurvefit',...
    'Display','off',...
    'MaxIterations', opt.maxIter,...
    'TolFun', opt.tolFun);

    try
        % --- Fit model ---
        params_fit = lsqcurvefit(model, p0, t, y, lb, ub, options);
        beta_fit = params_fit(2);

         % --- Check amplitude ---
        A_fit = abs(params_fit(1));
        if A_fit < 0.05 * (max(y)-min(y))
            isPerm = false;
            return;
        end

        % --- Compute fitted values ---
        y_fit    = model(params_fit, t);

        % --- Compute R-squared ---
        residuals = y - y_fit;
        SSR = sum(residuals.^2);
        SST = sum((y - mean(y)).^2);
        R2 = 1 - SSR/SST;

        % --- Fit criterion ---
        opt.betaTol = 1e-5;
        useFit = (R2 > opt.threshold) && (abs(beta_fit) < opt.betaTol);

    catch
        useFit = false;
    end

    % --- FFT analysis ---
    Y = fft(y);
    N = length(y);
    P2 = abs(Y/N);
    P1 = P2(1:floor(N/2)+1);
    P1(2:end-1) = 2 * P1(2:end-1);
    Pnorm = P1 / sum(P1);
    spectralRatio = max(Pnorm);

    useFFT = (spectralRatio > opt.spectralThreshold);

    % --- Final decision: OR ---
    isPerm = useFit || useFFT;

    % --- Optional plot ---
    if opt.showPlot
        figure;
        subplot(2,1,1)
        plot(t,y,'b','LineWidth',1.5); hold on;
        if exist('y_fit','var')
            plot(t,y_fit,'r--','LineWidth',1.5);
        end
        legend('Signal','Fit');
        title(sprintf('R^2 = %.3f   |beta|=%.3g', R2, abs(beta_fit)));

        subplot(2,1,2)
        f = linspace(0,1, numel(P1));
        plot(f, P1);
        title(sprintf('Spectrum (ratio=%.3f)', spectralRatio));
        xlabel('Freq');
    end
end



