function [isDiv, howDiv] = isDivergent(y, opt, effectName, customFunc, params0)
%ISDIVERGENT Detects if a signal exhibits divergent or oscillatory behavior.
%
%   [isDiv, howDiv] = isDivergent(y, t, opt, effectName, customFunc, params0)
%
%   PARAMETERS:
%       y          - Signal to analyze (numeric vector)
%       t          - Time vector corresponding to y (optional)
%                    If empty, it will be automatically generated as 
%                    t = (0:length(y)-1)';
%       opt        - Options object (subclass of 'options') containing parameters 
%                    like threshold, bounds, initial guesses, etc.
%       effectName - (Optional) String specifying which model to test:
%                    'Exponential Divergence', 'Damped Oscillations', etc.
%       customFunc - (Optional) Custom model function handle of the form f(p,t)
%       params0    - (Optional) Initial parameter guesses for customFunc
%
%   RETURNS:
%       isDiv  - Logical flag, true if divergence/trend detected
%       howDiv - Description of the detected effect
%
%   The function can operate in three modes:
%       1. Custom model mode (when customFunc is provided)
%       2. Specific model mode (when effectName is provided)
%       3. Full scan mode (default), testing all models sequentially

    % --- Preprocessing ---
    if nargin < 2 || isempty(t)
        t = (0:length(y)-1)' / length(y);
    end
    if nargin < 3 || isempty(opt)
        opt = options(); % Default if no options provided
    end

    % --- CASE 1: Custom function ---
    if nargin >= 5 && ~isempty(customFunc)
        if isempty(params0)
            error('params0 must be provided when using a custom function.');
        end
        if ischar(customFunc)
            customFunc = str2func(customFunc);
        elseif ~isa(customFunc, 'function_handle')
            error('customFunc must be a function handle or a valid function name string.');
        end

        isDiv = isGenericDiv(y, opt, customFunc, params0);
        howDiv = ternary(isDiv, 'Custom Divergent Behavior', 'No divergence detected by custom function');
        return;
    end

    % --- CASE 2: Specific model ---
    if nargin >= 4 && ~isempty(effectName)
        switch effectName
            case 'Exponential Divergence'
                isDiv = isExpDivergent(y, opt);
            case 'Damped Oscillations'
                isDiv = isDampOscillating(y, opt);
            case 'Permanent Oscillations'
                isDiv = isPermOscillating(y, opt);
            case 'Divergent Oscillations'
                isDiv = isDivOscillating(y, opt);
            case 'Sum of Sinusoids'
                isDiv = isMultiSinusoids(y, opt);
            case 'Runge Trend'
                isDiv = isRunge(y, opt);
            case 'Arctangent Trend'
                isDiv = isArcTanDivergent(y, opt);
            case 'Cubic Radix Trend'
                isDiv = isCubicRadix(y, opt);
            case 'Fifth Radix Trend'
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
        'Exponential Divergence',   @isExpDivergent;
        'Permanent Oscillations',   @isPermOscillating;
        'Damped Oscillations',      @isDampOscillating;
        'Divergent Oscillations',   @isDivOscillating;
        'Cubic Radix Trend',        @isCubicRadix;
        'Fifth Radix Trend',        @isFifthRadix;
        'Arctangent Trend',         @isArcTanDivergent;
        'Runge Trend',              @isRunge;
        'Sum of Sinusoids',         @isMultiSinusoids
    };

    isDiv = false;
    howDiv = 'No divergence detected';

    for k = 1:size(modelTests,1)
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





