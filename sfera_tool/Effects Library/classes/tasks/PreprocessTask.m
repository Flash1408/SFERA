classdef PreprocessTask < Task
    % PreprocessTask
    %
    % Task responsible for preparing input signal data before effect
    % analysis.
    %
    % This task performs the initial validation and preprocessing steps
    % required by the subsequent stages of the analysis pipeline.
    %
    % Its responsibilities include:
    %   - Converting signal and time data into column vectors.
    %   - Removing samples containing non-finite values.
    %   - Preserving the correspondence between signal and time samples.
    %   - Checking that the remaining data contain enough valid samples.
    %
    % The processed data are stored directly in the shared EffectContext.
    %
    % PreprocessTask is normally the first task executed in an effect
    % analysis pipeline.

    properties
        % Minimum number of valid samples required after preprocessing.
        minSamples (1,1) double
    end

    methods

        function obj = PreprocessTask()
            % PREPROCESSTASK Constructs a preprocessing task.
            %
            % Initializes the task identifier through the superclass
            % constructor and sets the minimum number of valid samples
            % required for the analysis.

            obj = obj@Task("PreprocessTask");

            % Set the minimum number of valid samples.
            obj.minSamples = 5;
        end

        function ok = execute(obj, context)
            % EXECUTE Preprocesses the input signal stored in the context.
            %
            % INPUT:
            %   context -> Scalar EffectContext object containing the input
            %              signal and corresponding time vector.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether preprocessing
            %         completed successfully.
            %
            % The method:
            %   1. Validates the analysis context and preprocessing configuration.
            %   2. Checks that signal and time data are non-empty numeric
            %      real vectors.
            %   3. Converts signal and time data into column vectors.
            %   4. Checks that both vectors contain the same number of samples.
            %   5. Removes samples with non-finite signal or time values.
            %   6. Checks the minimum number of remaining valid samples.
            %
            % If the input data are invalid or preprocessing cannot be
            % completed, context.result is set to false.

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('PreprocessTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            if ~isfinite(obj.minSamples) || ...
                    obj.minSamples < 1 || ...
                    fix(obj.minSamples) ~= obj.minSamples

                error('PreprocessTask:InvalidMinSamples', ...
                    'The minimum number of samples must be a positive integer.');
            end

            ok = true;

            % 1. Normalize input format (column vectors).
            if ~isnumeric(context.y) || isempty(context.y) || ...
                ~isvector(context.y) || ~isreal(context.y) || ...
                ~isnumeric(context.t) || isempty(context.t) || ...
                ~isvector(context.t) || ~isreal(context.t)

                context.result = false;
                ok = false;
                return;
            end

            context.y = context.y(:);
            context.t = context.t(:);

            % 2. Validate dimensional consistency.
            if numel(context.y) ~= numel(context.t)
                context.result = false;
                ok = false;
                return;
            end

            % 3. Remove samples containing non-finite values.
            % A sample is retained only if both its signal value and
            % corresponding time instant are finite.
            validMask = ...
                isfinite(context.y) & ...
                isfinite(context.t);

            context.y = context.y(validMask);
            context.t = context.t(validMask);

            % 4. Check the minimum number of valid samples.
            if numel(context.y) < obj.minSamples
                context.result = false;
                ok = false;
                return;
            end

            % 5. Mark preprocessing as successful.
            context.result = true;
        end

    end

end
