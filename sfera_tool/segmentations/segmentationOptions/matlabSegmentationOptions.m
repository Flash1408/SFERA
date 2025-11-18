classdef matlabSegmentationOptions < segmentationOptions
    properties
        statistic = 'mean'           % Chosen from {'mean', 'rms', 'std', 'linear'}
        maxChangeFraction = 0.02     % Fraction of signal length for maxNumChanges
    end
end

