function changePts = swSegmentation(y, t, metric, winLen, overlap)
    % Sliding-window segmentation based on metric
    %
    % INPUTS:
    %   y       : input signal (vector)
    %   t       : time signal (vector)   
    %   winLen  : window length (in samples)
    %   overlap : number of samples overlapped between windows
    %   metric  : feature to compute in each window
    %             options: 'var', 'mean', 'energy', 'rms'
    %
    % OUTPUT:
    %   changePts : indices of detected change points

    if nargin < 3
        metric = 'mean';  % default metric
    end
    if nargin < 4
        winLen = floor(0.2*length(y));   % default window length
    end
    if nargin < 5
        overlap = 0;  % default overlap
    end
    

    step = winLen - overlap; % step size between windows
    N = length(y);           % total signal length
    
    % === 1. Compute variance for each window ===
    feat = [];  % store variance values
    idxStart = 1;
    while idxStart + winLen - 1 <= N
        idxEnd = idxStart + winLen - 1;
        segment = y(idxStart:idxEnd);
        
        switch lower(metric)
            case 'var'
                f = var(segment);
            case 'mean'
                f = mean(segment);
            case 'energy'
                f = sum(segment.^2);
            case 'rms'
                f = rms(segment);
            otherwise
                error('Unknown metric: %s', metric);
        end
        feat(end+1) = f;  
        idxStart = idxStart + step;
    end
    
    % === 2. Detect large changes in variance ===
    th = 2 * std(feat);              % threshold
    cand = find(abs(diff(feat)) > th);
    
    % === 3. Map window indices ===
    changePts = cand * step;
    changePts = unique(min(changePts, N));
    changePts = [changePts(:); N];         % always include the end
    
    % === 4. Plot results ===
    % figure
    % plot(t, y, 'DisplayName', 'Signal');
    % hold on
    % xline(t(changePts), 'r--', 'LineWidth', 1.5, ...
    %       'HandleVisibility','off');
    % title(['Sliding-window segmentation (' metric ')'])
    % legend show
end




