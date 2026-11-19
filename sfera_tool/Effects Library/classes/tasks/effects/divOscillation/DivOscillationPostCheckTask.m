classdef DivOscillationPostCheckTask < Task
    % DivOscillationPostCheckTask
    %
    % Task responsible for performing a final validation specific to
    % divergent oscillation effect analysis after model fitting.
    %
    % This task evaluates whether the fitted divergent oscillation model
    % satisfies the condition required for recognizing an exponentially
    % increasing oscillation.
    %
    % The validation considers:
    %   - The sign of the exponential growth coefficient.
    %
    % A strictly positive growth coefficient indicates that the
    % oscillation amplitude increases exponentially over time.
    %
    % The task can only reject an effect that has not already been
    % rejected by a previous validation stage. An existing negative
    % analysis result is therefore preserved.

    methods
        function obj = DivOscillationPostCheckTask()
            % DIVOSCILLATIONPOSTCHECKTASK Constructs a divergent
            % oscillation post-check task.
            %
            % Initializes the task identifier through the superclass
            % constructor.

            obj = obj@Task("DivOscillationPostCheckTask");
        end

        function ok = execute(~, context)
            % EXECUTE Performs the final validation of the fitted
            % divergent oscillation model.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the fitted
            %              model parameters and the analysis result.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the validation
            %         task was successfully completed.
            %
            % The method:
            %   1. Validates the analysis context.
            %   2. Preserves any rejection made by a preceding task.
            %   3. Validates the fitted parameter vector.
            %   4. Checks whether the exponential growth coefficient
            %      is strictly positive.
            %
            % An effect already rejected by a previous analysis stage
            % remains rejected.

            ok = false;

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('DivOscillationPostCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Preserve a rejection made by a preceding analysis task.
            % No fitted parameters are available when model fitting
            % has been skipped because the signal was not eligible.
            if ~context.result
                ok = true;
                return;
            end

            % Validate the fitted model parameters.
            if ~isnumeric(context.params_fit) || ...
                    ~isvector(context.params_fit) || ...
                    numel(context.params_fit) ~= 4 || ...
                    ~isreal(context.params_fit) || ...
                    any(~isfinite(context.params_fit))
                error('DivOscillationPostCheckTask:InvalidParameters', ...
                    'The fitted parameters must be a finite real vector with four elements.');
            end

            % Retrieve the fitted exponential growth coefficient.
            paramsFit = context.params_fit;
            beta_fit = paramsFit(2);

            % Reject the effect if the exponential growth coefficient
            % is not strictly positive.
            if beta_fit <= 0
                context.result = false;
            end

            % Mark the validation task as successfully completed.
            ok = true;
        end
    end
end
