function [isDiv, howDiv] = isDivergent(y, effectName, customFunc, params0)
%
%   DESCRIPTION:
%   isDivergent(y, effectName, customFunc, params0) analyzes the signal y to determine if it 
%   exhibits any form of divergence or convergence pattern. 
%   If effectName is provided, only that specific effect is tested.
%   If a custom function is provided, it overrides all default methods.
%

    % --- CASE 1: Custom function ---
    if nargin > 2 && ~isempty(customFunc)
        if isempty(params0)
            error('params0 must be provided when customFunc is used.');
        end
        if ischar(customFunc)
            customFunc = str2func(customFunc);
        elseif ~isa(customFunc, 'function_handle')
            error('customFunc must be a function handle or a string representing a function name');
        end
        isDiv = isGenericDiv(y, customFunc, params0);
        if isDiv
            howDiv = 'Divergent according to the custom function.';
        else
            howDiv = 'Not divergent according to the custom function.';
        end
        return;
    end

    % --- CASE 2: Specific effect requested ---
    if nargin >= 2 && ~isempty(effectName)
        switch effectName
            case 'Exponential Divergence'
                isDiv = isExpDivergent(y);
            case 'Damped Oscillations'
                isDiv = isDampOscillating(y);
            case 'Permanent Oscillations'
                isDiv = isPermOscillating(y);
            case 'Divergent Oscillations'
                isDiv = isDivOscillating(y);
            case 'Sum of Sinusoids'
                isDiv = isMultiSinusoids(y, 3);
            case 'Runge Trend'
                isDiv = isRunge(y);
            case 'Arctangent Trend'
                isDiv = isArcTanDivergent(y);
            case 'Cubic Radix Trend'
                isDiv = isCubicRadix(y);
            otherwise
                warning('Unknown effectName: %s. Running full analysis.', effectName);
                isDiv = 0;
        end

        if isDiv
            howDiv = effectName;
        else
            howDiv = 'No divergence detected';
        end
        return;
    end

    % --- CASE 3: Default full analysis ---
    if isExpDivergent(y)
        isDiv = 1;
        howDiv = 'Exponential Divergence';   
    elseif isPermOscillating(y)
         isDiv = 1;
         howDiv = 'Permanent Oscillations';
    elseif isDampOscillating(y)
         isDiv = 1;
         howDiv = 'Damped Oscillations';
    elseif isDivOscillating(y)
        isDiv = 1;
        howDiv = 'Divergent Oscillations';
    elseif isCubicRadix(y)
        isDiv = 1;
        howDiv = 'Cubic Radix Trend';
    elseif isMultiSinusoids(y,3)
       isDiv = 1;
       howDiv = 'Sum of Sinusoids';
    elseif isArcTanDivergent(y)
        isDiv = 1;
        howDiv = 'Arctangent Trend';
    elseif isRunge(y)
        isDiv = 1;
        howDiv = 'Runge Trend';
    else
        isDiv = 0;
        howDiv = 'No divergence detected';
    end
end




