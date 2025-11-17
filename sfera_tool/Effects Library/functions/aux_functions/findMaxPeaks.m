function [peaksVal, peaksIdx] = findMaxPeaks(y, ampThresh, minDist)
% findMaxPeaks  Finds significant local maxima in a signal
%
%   [peaksVal, peaksIdx] = findMaxPeaks(y, ampThresh, minDist)
%
%   y          : input signal (vector)
%   ampThresh  : minimum amplitude threshold (e.g., 0.2*max(y))
%   minDist    : minimum distance between peaks (in samples)
%
%   peaksVal   : values of the detected peaks
%   peaksIdx   : indices of the detected peaks

    % --- handle missing input arguments with default values ---
    if nargin < 2 || isempty(ampThresh)
        ampThresh = 0; % default: no amplitude threshold
    end
    if nargin < 3 || isempty(minDist)
        minDist = 1; % default: no minimum distance
    end

    % ensure y is a column vector
    y = y(:);

    % --- find candidate local maxima ---
    % A sample y(i) is a local maximum if it is greater than the previous sample
    % and greater than or equal to the next sample.
    candIdx = find(y(2:end-1) > y(1:end-2) & y(2:end-1) >= y(3:end)) + 1;

    % --- apply amplitude threshold ---
    % Keep only those peaks whose value exceeds the given threshold.
    candIdx = candIdx(y(candIdx) >= ampThresh);

    % if no candidates remain, return empty outputs
    if isempty(candIdx)
        peaksVal = [];
        peaksIdx = [];
        return;
    end

    % --- enforce minimum distance between peaks ---
    peaksIdx = [];
    lastIdx = -inf;
    for k = 1:numel(candIdx)
        idx = candIdx(k);
        if idx - lastIdx > minDist
            % if the peak is far enough from the previous one, keep it
            peaksIdx(end+1) = idx; %#ok<AGROW>
            lastIdx = idx;
        else
            % if peaks are too close, keep the higher one
            if y(idx) > y(peaksIdx(end))
                peaksIdx(end) = idx;
                lastIdx = idx;
            end
        end
    end

    % --- return the corresponding peak values ---
    peaksVal = y(peaksIdx);
end




