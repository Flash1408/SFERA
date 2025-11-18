function changePts = matlabSegmentation(y, opt)
%MATLABSEGMENTATION Segments the signal using MATLAB’s built-in change-point detection.
%
%   changePts = matlabSegmentation(y)
%
%   This function uses MATLAB's built-in function FINDCHANGEPTS to detect 
%   abrupt changes in the mean value of a 1-D signal. It provides a 
%   convenient wrapper with automatic parameter selection suitable for 
%   typical use cases in signal segmentation.
%
%   INPUT
%       y : Numeric vector representing the input signal.
%       opt : MatlabSegmentationOptions object (optional)
%             - statistic: type of change to detect, specified as one of these values:
%                   "mean" — Detect changes in mean. If you call findchangepts with no output arguments, 
%                    the function plots the signal, the changepoints, and the mean value of each segment 
%                    enclosed by consecutive changepoints. 
%                   "rms" — Detect changes in root-mean-square level. If you call findchangepts with no 
%                    output arguments, the function plots the signal and the changepoints. 
%                   "std" — Detect changes in standard deviation, using Gaussian log-likelihood. 
%                    If you call findchangepts with no output arguments, the function plots the signal, 
%                    the changepoints, and the mean value of each segment enclosed by consecutive changepoints.
%                   "linear" — Detect changes in mean and slope. If you call findchangepts with no output arguments, 
%                    the function plots the signal, the changepoints, and the line that best fits each portion 
%                    of the signal enclosed by consecutive changepoints.
%             - maxChangeFraction : maximum fraction of signal length to detect changes (default 0.02)
%
%   OUTPUT
%       changePts : Indices of detected change points. The final index 
%                   (length(y)) is always included so that the last segment 
%                   is properly closed.
%
%   METHOD OVERVIEW
%       The segmentation relies on MATLAB’s FINDCHANGEPTS with the 
%       following configuration:
%
%       (1) Number of allowed change points
%           The maximum number of changes is limited to:
%               maxChanges = floor(opt.maxChangeFraction * length(y));
%           This prevents over-segmentation on long signals and adapts the 
%           complexity of the search to the signal length.
%
%       (2) Change-point detection statistic
%           The function is called as:
%               findchangepts(y, 'Statistic',opt.statistic, ...
%                                 'MaxNumChanges',maxChanges)
%           This instructs MATLAB to detect points where the *e.g., mean* of the 
%           signal changes significantly. Internally, FINDCHANGEPTS uses 
%           a cost-minimization approach based on piecewise-constant models:
%
%               segmented signal ≈ sequence of constant-mean segments
%
%           Change points are chosen to minimize the total residual error 
%           between the model and the actual signal, subject to the 
%           constraint on the maximum number of segments.
%
%       (3) Final change point
%           The final index (length(y)) is appended because 
%           FINDCHANGEPTS does not return it automatically.
%
%   NOTES
%       - This method is best suited for signals where changes occur as 
%         shifts in mean value.
%       - Compared to derivative-based segmentation, this approach is 
%         more robust to noise and gradual slope variations.
%       - The number of segments is constrained to avoid detecting 
%         spurious changes.


    % Use 'findchangepts' built-in function with 'opt.statistic' metric and maximum
    % number of changing points depending on the signal length
    if nargin < 2 || isempty(opt)
        opt = matlabSegmentationOptions();
    end

    maxChanges = floor(opt.maxChangeFraction * length(y));

    % Use built-in findchangepts function
    changePts = findchangepts(y, 'Statistic', opt.statistic, 'MaxNumChanges', maxChanges);
    changePts = [changePts(:); length(y)];

end

