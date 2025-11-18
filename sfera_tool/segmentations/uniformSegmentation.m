function changePts = uniformSegmentation(y, opt)
%UNIFORMSEGMENTATION Segments the signal into uniform-length intervals.
%
%   changePts = uniformSegmentation(y, perc)
%
%   This function splits a signal into segments of equal length, defined
%   as a percentage of the total signal length. It is a simple segmentation
%   strategy that does not rely on signal features or derivatives.
%
%   INPUTS
%       y    : Input signal (vector).
%       opt : UniformSegmentationOptions object (optional)
%             - perc : percentage of signal for each segment (0-100), default 10
%
%   OUTPUT
%       changePts : Indices of segment boundaries, including the last sample.
%
%   METHOD OVERVIEW
%   (1) Compute total length of the signal:
%           N = max(y)
%
%   (2) Compute step size:
%           step = round(N * perc / 100)
%
%   (3) Generate segment boundaries:
%           changePts = startIndex:step:N
%       Ensures that the last index of the signal is always included.
%
%   NOTES
%       - This method does not consider signal content or dynamics; it
%         is purely uniform.
%       - Useful as a baseline segmentation or when equal-length windows
%         are required for further analysis.
%       - perc should be chosen according to the desired granularity.

    if nargin < 2 || isempty(opt)
        opt = uniformSegmentationOptions();
    end

    % Compute number of samples per segment
    N = length(y);
    step = round(N * opt.perc / 100);
    
    changePts = 1:step:N;

    if changePts(end) ~= N
        changePts = [changePts N]; % ensure last sample is included
    end

end


