classdef (Abstract) segmentationOptions
    %SEGMENTATIONOPTIONS Abstract base class for all segmentation options
    %
    %   This class defines the interface for all segmentation option objects.
    %   Each concrete subclass must define the parameters required by its
    %   corresponding segmentation algorithm.
    %
    %   Properties and methods of the abstract class are intended to ensure
    %   uniform handling of segmentation options across different methods.
    %
    %   Usage:
    %       % Subclass example
    %       opt = swSegmentationOptions();
    %       opt.metric = 'mean';
    %       changePts = swSegmentation(y, opt);
end

