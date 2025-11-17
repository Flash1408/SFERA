function [isDiv, howDiv] = isDivergent(y, effectName, customFunc, params0)
%ISDIVERGENT Detects divergent or oscillatory behavior in a signal
%
%   [isDiv, howDiv] = isDivergent(y, effectName, customFunc, params0)
%
%   PARAMETERS:
%       y          - Signal vector
%       effectName - Optional, string specifying which model to test
%       customFunc - Optional, custom function handle or string: f(params, t)
%       params0    - Optional, initial parameters for customFunc
%
%   RETURNS:
%       isDiv      - True if divergence detected
%       howDiv     - String describing detected effect

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
        opt = [];  % can pass default inside isGenericDiv
        isDiv = isGenericDiv(y, opt, customFunc, params0);
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

%% Helper: simple inline ternary operator
function out = ternary(cond, a, b)
    if cond
        out = a;
    else
        out = b;
    end
end





