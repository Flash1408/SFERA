classdef dySegmentationOptions < segmentationOptions
    properties
        thresholdMultiplier = 2      % multiplier for std of derivative
        minDistanceFraction = 0.1    % fraction of signal length for min distance between change points
    end
end


