classdef (Abstract) Task < handle
    % Task
    %
    % Abstract base class for all execution steps in an effect pipeline.
    %
    % This class defines the interface that all concrete tasks must
    % implement. Each task represents a single operation in the analysis
    % workflow (e.g., preprocessing, model fitting, validation, plotting).
    %
    % Task inherits from handle so that all task objects exhibit reference
    % semantics and operate consistently on the shared EffectContext.

    properties (Access = protected)
        % Identifier of the task.
        name (1,1) string = ""
    end

    methods
        function obj = Task(name)
            % Constructor of Task.
            %
            % INPUT:
            %   name -> task identifier.
            if nargin > 0 
                obj.name = name; 
            end
        end
    end

    methods (Abstract)
        % Execute the task.
        %
        % INPUT:
        %   context -> EffectContext shared among all tasks.
        %
        % OUTPUT:
        %   ok -> true if the task completes successfully, false otherwise.
        ok = execute(obj, context)
    end

end