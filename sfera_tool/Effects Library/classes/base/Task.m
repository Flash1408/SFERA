classdef (Abstract) Task < handle
    % Task
    %
    % Abstract base class for all execution steps in an effect pipeline.
    %
    % This class defines the common interface that all concrete tasks
    % must implement. Each task performs a specific operation in the
    % analysis workflow, such as preprocessing, model fitting,
    % validation, or plotting.
    %
    % Task inherits from handle so that all task objects exhibit
    % reference semantics and can operate on the shared EffectContext.

    properties (Access = protected)
        % Name identifying the task within the execution pipeline.
        name (1,1) string = ""
    end

    methods
        function obj = Task(name)
            % TASK Constructs a task object.
            %
            % INPUT:
            %   name -> optional string identifying the task.
            %
            % OUTPUT:
            %   obj  -> initialized Task object.

            if nargin > 0
                obj.name = name;
            end
        end
    end

    methods (Abstract)
        % Execute the task using the shared analysis context.
        %
        % INPUT:
        %   context -> EffectContext shared among all pipeline tasks.
        %
        % OUTPUT:
        %   ok -> logical scalar indicating whether the task completed
        %         successfully. This does not necessarily indicate
        %         whether the analyzed effect was recognized.
        ok = execute(obj, context)
    end
end
