classdef swSegmentationOptions < segmentationOptions
    properties
        metric = 'mean'              % 'var', 'mean', 'energy', 'rms'
        winLenFraction = 0.2         % window length as fraction of signal
        overlap = 0                  % samples of overlap
    end
end


