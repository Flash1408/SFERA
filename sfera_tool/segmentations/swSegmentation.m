function changePts = swSegmentation(y, opt)
%SWSEGMENTATION Segments the signal using a sliding-window feature.
%
%   changePts = swSegmentation(y, metric, winLen, overlap)
%
%   This function performs signal segmentation by computing a feature
%   (variance, mean, energy, or RMS) within sliding windows and detecting 
%   significant changes in that feature over time. It is a general-purpose 
%   segmentation method suitable for signals whose statistical properties 
%   evolve gradually or abruptly.
%
%   INPUTS
%       y       : Input signal (vector).
%       opt     : swSegmentationOptions object (optional)
%                  - metric         : feature to compute in each window ('var','mean','energy','rms'), default 'mean'
%                  - winLenFraction : window length as fraction of signal length (default 0.2)
%                  - overlap        : number of overlapping samples between windows (default 0)
%
%   OUTPUT
%       changePts : Estimated change points (indices). The final sample 
%                   index (length(y)) is always appended.
%
%   METHOD OVERVIEW
%   (1) Sliding-window feature extraction
%       The signal is scanned using windows of length winLen, each shifted  
%       by a step equal to:
%
%           step = winLen – overlap
%
%       For each window, the chosen metric is computed, producing a 
%       feature sequence FEAT(k) that summarizes the signal’s behavior 
%       over time.
%
%   (2) Change detection on the feature trajectory
%       Changes are detected by examining the discrete derivative of FEAT:
%
%           abs(diff(FEAT)) > 2 * std(FEAT)
%
%       This threshold identifies windows whose feature value deviates
%       significantly from the typical variations, indicating a 
%       potential transition or change in the underlying behavior.
%
%   (3) Mapping window-based indices to signal indices
%       Detected window indices are converted back to sample indices using:
%
%           changePoint ≈ windowIndex * step
%
%       Duplicates are removed, indices are clipped to the signal length,
%       and the final sample index (N) is appended to ensure full coverage.
%
%   NOTES
%       - This method is useful when changes in *statistics* rather than 
%         amplitude alone mark transitions (e.g., noise bursts, drifting 
%         mean, energy changes).
%       - It is more flexible than derivative-based segmentation, but 
%         depends on window length and metric selection.
%       - Larger windows create smoother feature trends (fewer segments);
%         smaller windows increase sensitivity but may add noise.

    if nargin < 2 || isempty(opt)
        opt = swSegmentationOptions();
    end

    winLen = floor(opt.winLenFraction * length(y));
    
    step = winLen - opt.overlap; % step size between windows
    N = length(y);           % total signal length
    
    % === 1. Compute variance for each window ===
    feat = [];  % store variance values
    idxStart = 1;
    while idxStart + winLen - 1 <= N
        idxEnd = idxStart + winLen - 1;
        segment = y(idxStart:idxEnd);
        
        switch lower(opt.metric)
            case 'var'
                f = var(segment);
            case 'mean'
                f = mean(segment);
            case 'energy'
                f = sum(segment.^2);
            case 'rms'
                f = rms(segment);
            otherwise
                error('Unknown metric: %s', opt.metric);
        end
        feat(end+1) = f;  %#ok<AGROW>
        idxStart = idxStart + step;
    end
    
    % === 2. Detect large changes in variance ===
    th = 2 * std(feat);              % threshold
    cand = find(abs(diff(feat)) > th);
    
    % === 3. Map window indices ===
    changePts = cand * step;
    changePts = unique(min(changePts, N));
    changePts = [changePts(:); N];         % always include the end

end




