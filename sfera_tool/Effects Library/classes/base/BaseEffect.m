classdef (Abstract) BaseEffect < handle
    % BaseEffect
    %
    % Abstract class representing the core structure of an "Effect"
    % within the Simulink Fault Analyzer effect analysis framework.
    %
    % This class implements the Template Method design pattern, defining
    % the skeleton of the analysis algorithm while delegating the definition
    % of specific processing steps (tasks) to concrete subclasses.
    %
    % It inherits from "handle" to ensure reference semantics:
    % - modifications to context and properties are shared across methods.
    %
    % Overall responsibilities:
    % - orchestration of the analysis pipeline
    % - management of execution context
    % - configuration handling
    % - task execution coordination

    properties (Access = protected)
        tasks (1,:) cell            % Cell array of Task objects
        options (1,1) BaseOptions   % Configuration parameters
        context (1,1) EffectContext % Shared execution context
    end

    methods

        function obj = BaseEffect()
            % Constructor of BaseEffect
            %
            % Initializes the internal pipeline structure.

            % Initialize an empty task list.
            obj.tasks = {};

            % Initialize empty references.
            obj.options = [];
            obj.context = [];
        end

        function result = analyze(obj, y, t)
            % Main entry point of the analysis pipeline.
            %
            % INPUT:
            %   y -> input signal
            %   t -> time vector
            %
            % OUTPUT:
            %   result -> true if all tasks complete successfully

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
            % Adds a new task to the execution pipeline.
            %
            % INPUT:
            %   task -> Task object to be added.
            obj.tasks{end+1} = task;
        end

        function setOptions(obj, opt)
            % Sets the configuration parameters.
            %
            % INPUT:
            %   opt -> BaseOptions object (or derived class).
            obj.options = opt;
        end

    end

    methods (Access = protected)

        function result = executeTasks(obj)
            % Executes all configured tasks sequentially.
            %
            % OUTPUT:
            %   result -> true if every task succeeds,
            %             false otherwise.

            result = true;

            % Execute each task in the configured pipeline.
            for i = 1:numel(obj.tasks)

                currentTask = obj.tasks{i};

                ok = currentTask.execute(obj.context);

                % Stop immediately if one task fails.
                if ~ok
                    result = false;
                    return;
                end

            end

        end

    end

    methods (Abstract, Access = protected)
        % Configure the task pipeline.
        %
        % Concrete Effect subclasses must implement this method to
        % define the sequence of tasks composing the analysis.
        %
        % Example:
        %   ExpEffect:
        %       PreprocessTask
        %       FitTask
        %       ComputeR2Task
        %       ThresholdTask
        %       PlotTask
        configureTasks(obj);
    end

end