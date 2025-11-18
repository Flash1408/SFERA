function changePts = dySegmentation(y, opt) 
%DYSEGMENTATION Detects change points using a derivative-based segmentation method.
%
%   changePts = dySegmentation(y)
%
%   This function segments a 1-D signal by locating points where the
%   first derivative exhibits statistically significant changes. These
%   points typically correspond to sudden transitions in the original
%   signal such as slope changes, discontinuities, or the beginning of
%   new dynamic regimes.
%
%   INPUT
%       y : Numeric vector representing the input signal.
%       opt : dySegmentationOptions object (optional)
%             - thresholdMultiplier : multiplier for std of derivative (default 2)
%             - minDistanceFraction : minimum distance between change points as fraction of signal length (default 0.1)
%
%   OUTPUT
%       changePts : Indices of detected change points. The last index
%                   (length(y)) is always included to ensure the final
%                   segment is closed.
%
%   METHOD OVERVIEW
%       The segmentation procedure consists of four steps:
%
%       (1) Derivative computation
%           The first-order difference of the signal:
%               dy = diff(y)
%           This emphasizes regions where the signal changes rapidly.
%
%       (2) Threshold estimation
%           A threshold is computed as:
%               th = opt.thresholdMultiplier * std(dy)
%           Points where |dy| exceeds this threshold are considered
%           candidates for genuine change points.
%
%       (3) Candidate detection
%           All indices where the derivative exceeds the threshold:
%               cand = find(abs(dy) > th)
%           These represent potential transitions in the underlying signal.
%
%       (4) Minimum-distance filtering
%           To avoid detecting multiple points within the same transition,
%           candidates closer than a minimum spacing are suppressed.
%           The minimum distance is set to:
%               minDist = max(floor(length(y)* opt.minDistanceFraction), 1)
%           This retains only the most representative point in each region
%           of rapid change.
%
%   NOTES
%       - The method is robust to small fluctuations because the threshold
%         is based on the statistical spread of the derivative.
%       - The minimum distance rule prevents over-segmentation.
%       - The final index length(y) is appended to mark the end of the
%         last segment.


    if nargin < 2 || isempty(opt)
        opt = dySegmentationOptions();
    end

    % === 1. Compute the first derivative ===
    % The derivative highlights sudden changes in the signal
    dy = diff(y);
    
    % === 2. Define a threshold based on derivative statistics ===
    th = opt.thresholdMultiplier * std(dy);
    
    % === 3. Find candidate change points ===
    cand = find(abs(dy) > th);
    
    % === 4. Enforce a minimum distance between change points ===
    minDist = max(floor(length(y)* opt.minDistanceFraction), 1);

    if ~isempty(cand)
        keep = true(size(cand));
        lastPt = cand(1);
        for i = 2:length(cand)
            if cand(i) - lastPt < minDist
                keep(i) = false;
            else
                lastPt = cand(i);
            end
        end
        changePts = cand(keep);
    else
        changePts = [];
    end
    changePts = [changePts; length(y)];
end



