classdef (Abstract) options  
    %OPTIONS  Abstract base class defining fitting and detection options.
    %
    %   This class provides a common interface and shared properties for
    %   all specific model option classes used in signal fitting or 
    %   pattern recognition algorithms (e.g., Runge-like, arctangent,
    %   multi-sinusoidal, or nth-root trends).
    %
    %   Each concrete subclass defines its own model-specific parameters
    %   and behavior, typically used to control:
    %       • initial guesses for parameters in lsqcurvefit
    %       • parameter bounds for model stability
    %       • thresholds for the quality of fit (R²)
    %       • numerical tolerances
    %
    %   ------------------------------------------------------------------
    %   Common usage
    %   ------------------------------------------------------------------
    %
    %   All option classes inherit from this abstract base class and 
    %   can be used in a unified way:
    %
    %       opt = fifthRadixOptions();
    %       disp(opt.threshold)
    %
    %       opt.threshold = 0.98;
    %
    %   These options can then be passed to specific model-fitting 
    %   routines, e.g.:
    %
    %       result = isFifthRadix(y, opt);
    %
    %   ------------------------------------------------------------------
    %   Subclasses overview
    %   ------------------------------------------------------------------
    %
    %   1. **dampedOscillationOptions**
    %      - Detects signals that follow a *decaying sinusoidal model*:
    %        y(t) = A * exp(-beta * t) * cos(omega * t + phi)
    %      - Used for *transient oscillations* with exponential damping.
    %
    %   2. **permanentOscillationOptions**
    %      - Identifies *permanent or sustained oscillations* with no damping:
    %        y(t) = A * cos(omega * t + phi)
    %      - The check involves both curve fitting and spectral norm analysis.
    %
    %   3. **divergentOscillationOptions**
    %      - Models *growing oscillations*:
    %        y(t) = A * exp(beta * t) * cos(omega * t + phi)
    %      - Beta > 0 indicates increasing amplitude over time.
    %
    %   4. **expDivergenceOptions**
    %      - Detects purely *exponential divergence or growth*:
    %        y(t) = A + B * exp(C * t)
    %      - Common in unstable or runaway processes.
    %
    %   5. **cubicRadixOptions**
    %      - Fits a *cubic root law*:
    %        y(t) = A * ((B * (t - H))^(1/3)) + K
    %      - Useful for identifying nonlinear behaviors with saturation.
    %
    %   6. **fifthRadixOptions**
    %      - Fits a *fifth-root curve*:
    %        y(t) = A * ((B * (t - H))^(1/5)) + K
    %      - Captures smoother nonlinear growth trends.
    %
    %   7. **arcTanOptions**
    %      - Fits an *arctangent growth model*:
    %        y(t) = A * atan((t - H) / B) + K
    %      - Common in saturation and asymptotic systems.
    %
    %   8. **rungeOptions**
    %      - Models a *Runge-type function*:
    %        y(t) = A / (1 + B * (t - C)^2) + D
    %      - Represents localized peaks with decay.
    %
    %   9. **multiSinusoidsOptions**
    %      - Detects the presence of *multiple sinusoidal components*:
    %        y(t) = Σ [A_k * cos(ω_k * t + φ_k)] + c
    %      - Useful for spectral analysis or identifying mixed oscillations.
    %
    %   ------------------------------------------------------------------
    %   Shared properties
    %   ------------------------------------------------------------------
    %
    %   threshold (double)
    %       Goodness-of-fit threshold used to decide whether a model
    %       successfully describes a given signal segment.
    %       The default value is 0.95, meaning that the coefficient of
    %       determination (R²) must exceed 0.95 for the fit to be
    %       considered valid.
    %
    %   ------------------------------------------------------------------
    %   Notes
    %   ------------------------------------------------------------------
    %
    %   This abstract class is not meant to be instantiated directly.
    %   It serves as a structural and semantic parent for all concrete
    %   option classes in the model identification framework.
    %
    %   ------------------------------------------------------------------
    properties
        threshold double = 0.95; 
    end   
end

