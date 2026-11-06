classdef (Abstract) BaseEffect < handle
    % BaseEffect
    %
    % Abstract base class defining the common structure of an effect
    % within the Simulink Fault Analyzer effect analysis framework.
    %
    % This class implements the Template Method design pattern by
    % defining the general analysis workflow while delegating
    % effect-specific operations to concrete subclasses.
    %
    % Each effect configures its own sequence of Tasks, which are
    % executed sequentially and operate on a shared EffectContext.
    %
    % BaseEffect inherits from handle to ensure reference semantics,
    % allowing modifications to its properties and execution context
    % to be shared across methods.
    %
    % Main responsibilities:
    %   - orchestrating the effect analysis pipeline
    %   - managing the shared execution context
    %   - handling analysis configuration
    %   - coordinating task execution

    properties (Access = protected)
        % Ordered collection of Task objects composing the pipeline.
        tasks (1,:) cell

        % Configuration parameters used during effect analysis.
        % Empty until a valid BaseOptions object is assigned.
        options

        % Shared context containing input data and intermediate results.
        % Created when the analysis is started.
        context
    end

    methods
        function obj = BaseEffect()
            % BASEEFFECT Initializes the internal effect structure.
            %
            % The constructor initializes an empty task collection
            % and clears the configuration and execution context.
            % Concrete subclasses are responsible for configuring
            % the task pipeline.

            % Initialize an empty task list.
            obj.tasks = {};

            % Initialize configuration and context references.
            obj.options = [];
            obj.context = [];
        end

        function result = analyze(obj, y, t)
            % ANALYZE Executes the effect analysis pipeline.
            %
            % INPUT:
            %   y -> input signal to be analyzed.
            %   t -> time vector corresponding to the input signal.
            %
            % OUTPUT:
            %   result -> logical scalar indicating whether the
            %             analyzed effect has been recognized.
            %
            % The method initializes the execution context, configures
            % the task pipeline, and executes its tasks sequentially.

            % Ensure that configuration options have been set.
            if isempty(obj.options)
                error('BaseEffect:MissingOptions', ...
                    'Options must be set before calling analyze().');
            end

            % Reset the task list before configuring a new pipeline.
            obj.tasks = {};

            % Create the shared execution context.
            obj.context = EffectContext(y, t, obj.options);

            % Configure the task pipeline (implemented by subclasses).
            obj.configureTasks();

            % Execute all configured tasks.
            result = obj.executeTasks();
        end

        function addTask(obj, task)
            % ADDTASK Adds a task to the execution pipeline.
            %
            % INPUT:
            %   task -> scalar Task object to append to the pipeline.
            %
            % The task is added at the end of the collection and will
            % be executed after all previously configured tasks.

            % Validate the task object.
            if ~isa(task, 'Task') || ~isscalar(task)
                error('BaseEffect:InvalidTask', ...
                    'The task must be a scalar Task object.');
            end

            obj.tasks{end+1} = task;
        end

        function setOptions(obj, opt)
            % SETOPTIONS Assigns the configuration parameters.
            %
            % INPUT:
            %   opt -> scalar BaseOptions object or instance of a
            %          derived options class.
            %
            % The assigned configuration is shared with the analysis
            % context created when analyze() is called.

            % Validate the options object.
            if ~isa(opt, 'BaseOptions') || ~isscalar(opt)
                error('BaseEffect:InvalidOptions', ...
                    'Options must be a scalar BaseOptions object.');
            end

            obj.options = opt;
        end

        function context = getContext(obj)
            % GETCONTEXT Returns the context of the most recent analysis.
            %
            % OUTPUT:
            %   context -> EffectContext object containing the input data,
            %              intermediate results and diagnostic information.
            %
            % An error is raised if no analysis has been performed yet.

            if isempty(obj.context)
                error('BaseEffect:MissingContext', ...
                    'No analysis context is available. Call analyze() first.');
            end

            context = obj.context;
        end
    end

    methods (Access = protected)
        function result = executeTasks(obj)
            % EXECUTETASKS Executes the configured tasks sequentially.
            %
            % OUTPUT:
            %   result -> logical scalar indicating whether the
            %             analyzed effect has been recognized.
            %
            % Each task must return a logical scalar indicating whether
            % its execution completed successfully.
            %
            % If a task fails, execution stops immediately and the
            % analysis result is set to false.
            %
            % If all tasks complete successfully, the final analysis
            % result is retrieved from the shared execution context.

            % Assume successful execution until a task reports otherwise.
            result = true;

            % Execute each task in the configured pipeline.
            for i = 1:numel(obj.tasks)
                currentTask = obj.tasks{i};
                ok = currentTask.execute(obj.context);

                % Ensure that each task returns a logical scalar.
                if ~islogical(ok) || ~isscalar(ok)
                    error('BaseEffect:InvalidTaskResult', ...
                        'Each task must return a logical scalar.');
                end

                % Stop immediately if a task fails to execute.
                if ~ok
                    result = false;
                    obj.context.result = false;
                    return;
                end
            end

            % Retrieve the final analysis result from the shared context.
            result = obj.context.result;
        end
    end

    methods (Abstract)
        % GETMODEL Returns the mathematical model associated with the effect.
        %
        % OUTPUT:
        %   model -> function handle representing the effect model.
        %
        % Concrete Effect subclasses must implement this method.

        model = getModel(obj);

        % GETINITIALPARAMS Computes the initial model parameters.
        %
        % INPUT:
        %   y   -> input signal used for parameter initialization.
        %   opt -> effect-specific configuration object.
        %
        % OUTPUT:
        %   params0 -> initial parameter vector for model fitting.
        %
        % Concrete Effect subclasses must implement this method.

        params0 = getInitialParams(obj, y, opt);
    end

    methods (Abstract, Access = protected)
        % CONFIGURETASKS Defines the sequence of tasks composing the
        % effect analysis pipeline.
        %
        % Concrete Effect subclasses must implement this method to
        % specify their own analysis workflow.
        %
        % Example:
        %   ExpEffect:
        %       PreprocessTask
        %       FitModelTask
        %       R2ComputationTask
        %       PostCheckTask
        %       PlotTask

        configureTasks(obj);
    end
end
