function [peaksVal, peaksIdx] = findMaxPeaks(y, ampThresh, minDist)
% FINDMAXPEAKS Identifies significant local maxima in a signal.
%
%   This utility function detects positive local maxima in an input
%   signal, applying an amplitude threshold and a minimum separation
%   between consecutive peaks.
%
%   The function first identifies candidate local maxima, then filters
%   them according to their amplitude and minimum distance.
%   When two consecutive candidates are too close, only the higher
%   peak is retained.
%
%   INPUT:
%       y          -> Input signal represented as a vector.
%       ampThresh  -> Minimum amplitude required for a peak to be
%                     considered valid.
%                     Default: 0.
%       minDist    -> Minimum required distance between consecutive
%                     accepted peaks, expressed in samples.
%                     Default: 1.
%
%   OUTPUT:
%       peaksVal   -> Values of the detected local maxima.
%       peaksIdx   -> Indices of the detected local maxima in the
%                     original input signal.
%
%   NOTES:
%       - Only positive local maxima are considered.
%       - The amplitude threshold is applied before distance filtering.
%       - When two candidates are closer than or equal to minDist,
%         the higher peak is retained.
%       - The input signal is internally converted into a column vector.

    % Validate the input signal.
    if ~isnumeric(y) || ~isvector(y) || ~isreal(y) || isempty(y)
        error('findMaxPeaks:InvalidSignal', ...
            'The input signal must be a non-empty real numeric vector.');
    end
    
    % Assign default values to optional arguments.
    if nargin < 2 || isempty(ampThresh)
        ampThresh = 0;
    end
    
    if nargin < 3 || isempty(minDist)
        minDist = 1;
    end
    
    % Validate the amplitude threshold.
    if ~isnumeric(ampThresh) || ~isscalar(ampThresh) || ...
            ~isreal(ampThresh) || ~isfinite(ampThresh)
        error('findMaxPeaks:InvalidAmplitudeThreshold', ...
            'The amplitude threshold must be a finite real numeric scalar.');
    end
    
    % Validate the minimum peak distance.
    if ~isnumeric(minDist) || ~isscalar(minDist) || ...
            ~isreal(minDist) || ~isfinite(minDist) || ...
            minDist < 0 || fix(minDist) ~= minDist
        error('findMaxPeaks:InvalidMinimumDistance', ...
            'The minimum peak distance must be a non-negative integer.');
    end
    
    % Convert the input signal into a column vector.
    y = y(:);
    
    % Identify candidate local maxima.
    % A sample is considered a local maximum when it is strictly greater
    % than its preceding sample and greater than or equal to its next sample.
    candIdx = find( ...
        y(2:end-1) > y(1:end-2) & ...
        y(2:end-1) >= y(3:end)) + 1;
    
    % Retain only candidates satisfying the amplitude threshold.
    candIdx = candIdx(y(candIdx) >= ampThresh);
    
    % Initialize empty outputs if no valid candidates are found.
    if isempty(candIdx)
        peaksVal = [];
        peaksIdx = [];
        return;
    end
    
    % Initialize the accepted peak indices.
    peaksIdx = zeros(numel(candIdx), 1);
    numPeaks = 0;
    
    % Enforce the minimum distance between consecutive peaks.
    for k = 1:numel(candIdx)
        currentIdx = candIdx(k);
    
        if numPeaks == 0 || ...
                currentIdx - peaksIdx(numPeaks) > minDist
    
            % Accept the candidate if it is sufficiently distant.
            numPeaks = numPeaks + 1;
            peaksIdx(numPeaks) = currentIdx;
    
        elseif y(currentIdx) > y(peaksIdx(numPeaks))
    
            % Otherwise, retain the higher candidate.
            peaksIdx(numPeaks) = currentIdx;
        end
    end
    
    % Remove unused preallocated entries.
    peaksIdx = peaksIdx(1:numPeaks).';
    
    % Retrieve the values corresponding to the accepted peak indices.
    peaksVal = y(peaksIdx);
end




