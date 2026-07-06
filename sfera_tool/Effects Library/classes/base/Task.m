classdef (Abstract) Task < handle
    % Task
    %
    % Abstract base class for all execution steps in an effect pipeline.
    %
    % This class defines the interface that all concrete tasks must implement.
    % Each task represents a single operation in the workflow (e.g., preprocessing,
    % model fitting, validation, plotting).
    %
    % Being a handle class means that Task objects are passed by reference,
    % not by value. This allows consistent interaction with shared data
    % (EffectContext) without unnecessary copying.

    properties
        name (1,1) string   % Task identifier
    end

    methods
        function obj = Task(name)
            % Constructor of Task
            % 
            % INPUT:
            %   name -> identifier of the task
            %
            % Initialize the task name if provided
            if nargin > 0
                obj.name = name;
            end
        end
    end

    methods (Abstract)
        % Perform the task operation.
        %
        % This method must be implemented by all subclasses of Task.
        % It contains the core logic of the task.
        %
        % INPUT:
        %   context -> EffectContext object containing:
        %       - input data (y, t)
        %       - model and parameters
        %       - intermediate and final results
        %
        % OUTPUT:
        %   ok -> logical value:
        %       true  -> task completed successfully
        %       false -> task failed, pipeline execution should stop
        %
        ok = execute(obj, context) 
    end
end