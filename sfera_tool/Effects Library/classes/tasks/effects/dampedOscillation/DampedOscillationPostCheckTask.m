classdef DampedOscillationPostCheckTask < Task
    % DampedOscillationPostCheckTask
    %
    % Task responsible for performing a final validation specific to
    % damped oscillation effect analysis after model fitting.
    %
    % This task evaluates whether the fitted damped oscillation model
    % satisfies the physical and numerical conditions required for
    % recognizing a damped oscillation.
    %
    % The validation considers:
    %   - The amplitude of the fitted oscillation.
    %   - The sign of the exponential damping coefficient.
    %   - The minimum angular frequency of the oscillation.
    %
    % The task can only reject an effect that has not already been
    % rejected by a previous validation stage. An existing negative
    % analysis result is therefore preserved.
    
    methods
        function obj = DampedOscillationPostCheckTask()
            % DAMPEDOSCILLATIONPOSTCHECKTASK Constructs a damped
            % oscillation post-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.
    
            obj = obj@Task("DampedOscillationPostCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Performs the final validation of the fitted damped
            % oscillation model.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the fitted model
            %              parameters and the analysis result.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the validation
            %         task was successfully completed.
            %
            % The method checks:
            %   1. The fitted amplitude relative to the input signal range.
            %   2. The sign of the exponential damping coefficient.
            %   3. The minimum angular frequency.
            %
            % An effect already rejected by a previous analysis stage
            % remains rejected.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('DampedOscillationPostCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            if ~isnumeric(context.params_fit) || ...
                    ~isvector(context.params_fit) || ...
                    numel(context.params_fit) ~= 5 || ...
                    ~isreal(context.params_fit) || ...
                    any(~isfinite(context.params_fit))
                error('DampedOscillationPostCheckTask:InvalidParameters', ...
                    'The fitted parameters must be a finite real vector with five elements.');
            end

            % Retrieve the fitted model parameters.
            paramsFit = context.params_fit;

            A_fit = paramsFit(1);
            beta_fit = paramsFit(2);
            omega_fit = paramsFit(3);

            % Compute the range of the preprocessed input signal.
            localRange = max(context.y) - min(context.y);

            % Reject the effect if any model-specific condition is not satisfied.
            if context.result && ...
                    (abs(A_fit) < 0.05 * localRange || ...
                    beta_fit >= 0 || ...
                    omega_fit < 0.5 - 1e-10)
                context.result = false;
            end

            % Mark the validation task as successfully completed.
            ok = true;
        end
    end
end