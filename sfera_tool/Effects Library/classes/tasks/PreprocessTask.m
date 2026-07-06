classdef PreprocessTask < Task
    % PreprocessTask
    % 
    % Task responsible for preprocessing input signals before analysis.
    %
    % Responsibilities:
    %   - Normalize input signal formats
    %   - Remove invalid numerical samples (NaN, Inf)
    %   - Ensure consistency between time (t) and signal (y)
    %   - Validate minimum amount of usable data
    %
    % The processed data are written directly into the shared
    % EffectContext object.
    %
    % This task follows the Task pipeline architecture and represents
    % the first processing stage of the analysis workflow.
    %

    properties
        % Minimum number of valid samples required
        minSamples (1,1) double
    end

    methods

        function obj = PreprocessTask()
            % Constructor of PreprocessTask
            %
            % Call superclass constructor to initialize the object first
            obj = obj@Task("PreprocessTask");

            % Initialize the minimum number of samples required
            obj.minSamples = 5;
        end

        function ok = execute(obj, context)
            % Execute preprocessing stage.
            %
            % INPUT:
            %   context -> Shared analysis context.
            %
            % OUTPUT:
            %   ok -> True if preprocessing succeeds, false otherwise
            %
            % The method:
            %   1. Normalize input format (column vectors)
            %   2. Validate dimensional consistency
            %   3. Remove invalid samples (NaN / Inf)
            %   4. Validate minimum data requirement
            %   5. Mark successful preprocessing

            ok = true;

            % 1. Normalize input format (column vectors)
            context.y = context.y(:);
            context.t = context.t(:);

            % 2. Validate dimensional consistency
            if numel(context.y) ~= numel(context.t)
                context.result = false;
                ok = false;
                return;
            end

            % 3. Remove invalid samples (NaN / Inf)
            % Keep only samples for which both the signal and the
            % corresponding time instant are finite.
            validMask = ...
                isfinite(context.y) & ...
                isfinite(context.t);

            context.y = context.y(validMask);
            context.t = context.t(validMask);

            % 4. Validate minimum data requirement
            if numel(context.y) < obj.minSamples
                context.result = false;
                ok = false;
                return;
            end

            % 5. Mark successful preprocessing
            context.result = true;
        end

    end

end