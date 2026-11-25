classdef TestCustomEffect < matlab.unittest.TestCase
    % Test_CustomEffect
    %
    % Unit test suite for the CustomEffect class.
    %
    % This class verifies the main behaviors of custom model analysis:
    %   - Recognition of valid user-defined models.
    %   - Rejection of invalid model definitions.
    %   - Acceptance and rejection through custom post-check callbacks.
    %   - Handling of callback execution errors.
    %
    % The test suite focuses on the essential functionality of the
    % custom effect analysis pipeline.

    methods (Access = private)

        function model = createValidUserModel(~)
            % CREATEVALIDUSERMODEL Creates a valid exponential UserModel.
            %
            % The generated model follows:
            %   y(t) = A * exp(B * t) + C

            model = UserModel();

            model.modelFunction = @(p,t) ...
                p(1)*exp(p(2)*t) + p(3);

            model.initialParams = [1, 0.1, 0];
            model.lb = [0, -Inf, -Inf];
            model.ub = [Inf, Inf, Inf];

            model.modelName = "Exponential Custom";
            model.description = "Custom exponential model";
        end

    end

    methods (Test)
        function testValidCustomModel(testCase)
            % TESTVALIDCUSTOMMODEL Verifies the analysis of a valid custom model.

            % Arrange
            model = testCase.createValidUserModel();

            t = (0:0.1:10)';
            y = 2*exp(0.2*t) + 1;

            options = BaseOptions();
            options.threshold = 0.95;

            effect = CustomEffect(model, options);

            % Act
            effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyTrue(context.result);
            testCase.verifyGreaterThan(context.R2, 0.99);
        end

        function testInvalidUserModel(testCase)
            % TESTINVALIDUSERMODEL Verifies rejection of an invalid model.

            % Arrange
            model = testCase.createValidUserModel();
            model.modelFunction = [];

            % Act and Assert
            testCase.verifyError( ...
                @() CustomEffect(model, BaseOptions()), ...
                'CustomEffect:InvalidUserModel');
        end

        function testCustomPostCheckAccepted(testCase)
            % TESTCUSTOMPOSTCHECKACCEPTED Verifies callback acceptance.

            % Arrange
            model = testCase.createValidUserModel();
            model.requiresPostCheck = true;
            model.customPostCheck = @(p,y,yFit) true;

            t = (0:0.1:10)';
            y = 2*exp(0.2*t) + 1;

            effect = CustomEffect(model, BaseOptions());

            % Act
            effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyTrue(context.result);
            testCase.verifyEqual(context.customPostCheckError, "");
        end

        function testCustomPostCheckRejected(testCase)
            % TESTCUSTOMPOSTCHECKREJECTED Verifies callback rejection.

            % Arrange
            model = testCase.createValidUserModel();
            model.requiresPostCheck = true;
            model.customPostCheck = @(p,y,yFit) false;

            t = (0:0.1:10)';
            y = 2*exp(0.2*t) + 1;

            effect = CustomEffect(model, BaseOptions());

            % Act
            effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyFalse(context.result);
            testCase.verifyEqual(context.customPostCheckError, "");
        end

        function testCustomPostCheckError(testCase)
            % TESTCUSTOMPOSTCHECKERROR Verifies callback error handling.

            % Arrange
            model = testCase.createValidUserModel();
            model.requiresPostCheck = true;
            model.customPostCheck = @(p,y,yFit) ...
                p(1) + customUndefinedFunction();

            t = (0:0.1:10)';
            y = 2*exp(0.2*t) + 1;

            effect = CustomEffect(model, BaseOptions());

            % Act
            effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyFalse(context.result);
            testCase.verifyNotEmpty(context.customPostCheckError);
        end
    end
end
