function [isDiv, howDiv] = isDivergent(y, effectName, customFunc, params0)
%ISDIVERGENT Detects divergent or oscillatory behavior in a signal.
%
%   [isDiv, howDiv] = isDivergent(y)
%       Performs a full scan across all available divergence/oscillation
%       models. Returns the first detected effect.
%
%   [isDiv, howDiv] = isDivergent(y, effectName)
%       Tests the signal only against the specified effect. The effectName
%       must match one of the supported models (see list below).
%
%   [isDiv, howDiv] = isDivergent(y, [], customFunc, params0)
%       Uses a user-defined custom model instead of predefined effects.
%       The custom function must follow the signature:
%           f(params, t)
%       where:
%           - params  : vector of parameters
%           - t      : the independent variable of the model (e.g., time).
%
%   INPUTS
%       y          - Numeric vector representing the signal under analysis.
%
%       effectName - (Optional) String specifying which model to test.
%                    Supported values include:
%                       'Exponential Divergence'
%                       'Damped Oscillations'
%                       'Permanent Oscillations'
%                       'Divergent Oscillations'
%                       'Sum of Sinusoids'
%                       'Runge Trend'
%                       'Arctangent Trend'
%                       'Cubic Radix Trend'
%                       'Fifth Radix Trend'
%
%       customFunc - (Optional) Custom function handle or string.
%                    If provided, this overrides effectName.
%                    Must be callable as:
%                        output = customFunc(params, t)
%
%       params0    - (Optional) Initial parameter vector for customFunc.
%                    Required only when customFunc is used.
%
%   OUTPUTS
%       isDiv      - Logical true/false indicating whether divergence or
%                    oscillatory behavior was detected.
%
%       howDiv     - String describing the detected effect. If no effect
%                    matches the signal, returns:
%                       'No divergence detected'
%
%   BEHAVIOR
%       The function operates in three modes:
%
%       (1) Custom Mode:
%           If customFunc is provided, the function evaluates divergence
%           using the user-defined model and params0.
%
%       (2) Specific-Effect Mode:
%           If effectName is provided, only the corresponding model is tested.
%
%       (3) Full-Scan Mode (default):
%           All predefined models are tested in a fixed priority order.
%           The first positive detection is returned.
%
%   NOTES
%       - Each predefined effect corresponds to a dedicated options class
%         (e.g., expDivergenceOptions) and a matching detector function
%         (e.g., isExpDivergent).
%
%       - The function expects y to be a column or row vector. No missing
%         values should be present.
%
%   EXAMPLES
%       % Full scan
%       [flag, type] = isDivergent(signal);
%
%       % Test only exponential divergence
%       [flag, type] = isDivergent(signal, 'Exponential Divergence');
%
%       % Custom model
%       myModel = @(p,t) p(1) * exp(p(2)*t);
%       [flag, type] = isDivergent(signal, [], myModel, [1, 0.1]);


    % --- CASE 1: Custom function ---
    if nargin >= 3 && ~isempty(customFunc)
        if isempty(params0)
            error('params0 must be provided when using a custom function.');
        end
        if ischar(customFunc)
            customFunc = str2func(customFunc);
        elseif ~isa(customFunc, 'function_handle')
            error('customFunc must be a function handle or string.');
        end

        % Use generic divergence function (internally creates t, options)
        opt = [];  % can pass default inside isCustomDivergent
        isDiv = isCustomDivergent(y, opt, customFunc, params0);
        howDiv = ternary(isDiv, 'Custom Divergent Behavior', 'No divergence detected by custom function');
        return;
    end

    % --- CASE 2: Specific effect ---
    if nargin >= 2 && ~isempty(effectName)
        switch effectName
            case 'Exponential Divergence'
                opt = expDivergenceOptions();  % create specific options object
                isDiv = isExpDivergent(y, opt);  
            case 'Damped Oscillations'
                opt = dampOscillationOptions();
                opt.threshold = 0.7;
                isDiv = isDampOscillating(y, opt);
            case 'Permanent Oscillations'
                opt = permOscillationOptions();
                isDiv = isPermOscillating(y, opt);
            case 'Divergent Oscillations'
                opt = divOscillationOptions();
                isDiv = isDivOscillating(y, opt);
            case 'Sum of Sinusoids'
                opt = multiSinusoidsOptions();
                isDiv = isMultiSinusoids(y, opt);
            case 'Runge Trend'
                opt = rungeOptions();
                isDiv = isRunge(y, opt);
            case 'Arctangent Trend'
                opt = arcTanOptions();
                isDiv = isArcTanDivergent(y, opt);
            case 'Cubic Radix Trend'
                opt = cubicRadixOptions();
                isDiv = isCubicRadix(y, opt);
            case 'Fifth Radix Trend'
                opt = fifthRadixOptions();
                isDiv = isFifthRadix(y, opt);
            otherwise
                warning('Unknown effectName: %s. Running full analysis.', effectName);
                isDiv = false;
        end
        howDiv = ternary(isDiv, effectName, 'No divergence detected');
        return;
    end

    % --- CASE 3: Full scan (default) ---
    modelTests = {
        'Exponential Divergence',   @isExpDivergent,   @expDivergenceOptions;
        'Permanent Oscillations',   @isPermOscillating,@permOscillationOptions;
        'Damped Oscillations',      @isDampOscillating,@dampOscillationOptions;
        'Divergent Oscillations',   @isDivOscillating, @divOscillationOptions;
        'Cubic Radix Trend',        @isCubicRadix,     @cubicRadixOptions;
        'Fifth Radix Trend',        @isFifthRadix,     @fifthRadixOptions;
        'Arctangent Trend',         @isArcTanDivergent,@arcTanOptions;
        'Runge Trend',              @isRunge,          @rungeOptions;
        'Sum of Sinusoids',         @isMultiSinusoids, @multiSinusoidsOptions
    };

    isDiv = false;
    howDiv = 'No divergence detected';

    for k = 1:size(modelTests,1)
        optClass = modelTests{k,3};
        opt = optClass();  % instantiate specific options
        fn = modelTests{k,2};
        if fn(y, opt)
            isDiv = true;
            howDiv = modelTests{k,1};
            return;
        end
    end
end

% ---> Helper: inline ternary operator <---
function out = ternary(cond, a, b)
    if cond
        out = a;
    else
        out = b;
    end
end





