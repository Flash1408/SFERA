classdef CustomPostCheckTask < Task
    % CustomPostCheckTask
    %
    % Task responsible for executing the user-defined validation
    % callback associated with a custom model.
    %
    % The callback receives the fitted model parameters, the original
    % input signal, and the signal reconstructed by the fitted model.
    %
    % The callback must return a scalar logical value:
    %   - true  -> the custom validation is satisfied.
    %   - false -> the custom effect is rejected.
    %
    % Callback execution errors and invalid return values are recorded
    % separately from model fitting errors.

    properties (Access = private)
        % User-defined model containing the custom validation callback.
        userModel (1,1) UserModel
    end

    methods
        function obj = CustomPostCheckTask(userModel)
            % CUSTOMPOSTCHECKTASK Constructs a custom validation task.
            %
            % INPUT:
            %   userModel -> Scalar UserModel containing the callback
            %                to execute after the standard post-check.

            obj = obj@Task("CustomPostCheckTask");

            if ~isa(userModel, 'UserModel') || ~isscalar(userModel)
                error('CustomPostCheckTask:InvalidUserModel', ...
                    'A scalar UserModel object is required.');
            end

            if ~userModel.validateModel() || ...
                    ~userModel.requiresPostCheck

                error('CustomPostCheckTask:InvalidUserModel', ...
                    'The UserModel must define a valid custom post-check.');
            end

            obj.userModel = userModel;
        end

        function ok = execute(obj, context)
            % EXECUTE Executes the user-defined validation callback.
            %
            % INPUT:
            %   context -> Shared EffectContext containing the fitted
            %              parameters and the original and fitted signals.
            %
            % OUTPUT:
            %   ok -> Logical scalar indicating whether the task
            %         completed successfully.
            %
            % A negative validation result does not indicate task
            % execution failure. Callback errors and invalid outputs
            % are instead recorded in customPostCheckError.

            if ~isa(context, 'EffectContext') || ~isscalar(context)
                error('CustomPostCheckTask:InvalidContext', ...
                    'The context must be a scalar EffectContext object.');
            end

            % Preserve a negative result established by a previous task.
            if ~context.result
                ok = true;
                return;
            end

            % Execute the user-defined validation callback.
            try
                callback = obj.userModel.customPostCheck;

                validationResult = callback( ...
                    context.params_fit, ...
                    context.y, ...
                    context.y_fit);

                % Require a scalar logical return value.
                if ~islogical(validationResult) || ...
                        ~isscalar(validationResult)

                    error('CustomPostCheckTask:InvalidCallbackOutput', ...
                        'The custom post-check must return a scalar logical value.');
                end

                % Store the custom validation outcome.
                context.result = validationResult;
                context.customPostCheckError = "";

                ok = true;

            catch ME
                % Record the callback execution error.
                context.customPostCheckError = string(ME.message);
                context.result = false;

                ok = false;
            end
        end
    end
end
