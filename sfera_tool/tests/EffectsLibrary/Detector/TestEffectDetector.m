classdef TestEffectDetector < matlab.unittest.TestCase
    % TestEffectDetector
    %
    % Unit tests for the EffectDetector class.
    %
    % The tests verify:
    %   - detection of specific predefined effects
    %   - full detection and effect priority
    %   - custom effect detection
    %   - analysis context management
    %   - special configuration of predefined effects

    methods (Test)
        function testSpecificEffectDetection(testCase)
            % Verify detection of a specifically requested effect.

            detector = EffectDetector();

            t = linspace(0, 1, 100)';
            y = 1 + 0.5 .* exp(2 .* t);

            [isDetected, howDetected] = detector.detect( ...
                y, t, 'Exponential Divergence');

            testCase.verifyTrue(isDetected);
            testCase.verifyEqual( ...
                howDetected, 'Exponential Divergence');

            testCase.verifyEqual( ...
                detector.getLastEffectName(), ...
                'Exponential Divergence');
        end

        function testFullDetectionPriority(testCase)
            % Verify that full detection respects the configured priority.

            detector = EffectDetector();

            t = linspace(0, 1, 100)';
            y = 1 + 0.5 .* exp(2 .* t);

            [isDetected, howDetected] = detector.detect(y, t);

            testCase.verifyTrue(isDetected);

            % Exponential Divergence has the highest detection priority.
            testCase.verifyEqual( ...
                howDetected, 'Exponential Divergence');

            testCase.verifyEqual( ...
                detector.getLastEffectName(), ...
                'Exponential Divergence');
        end

        function testSpecificDampedOscillationThreshold(testCase)
            % Verify the special threshold used for explicit detection.

            detector = EffectDetector();

            t = linspace(0, 1, 100)';
            y = 1 + 0.5 .* exp(2 .* t);

            detector.detect(y, t, 'Damped Oscillations');

            context = detector.getContext();

            testCase.verifyEqual(context.options.threshold, 0.7);
        end

        function testCustomEffectDetection(testCase)
            % Verify detection using a user-defined mathematical model.

            detector = EffectDetector();

            t = linspace(0, 1, 100)';
            y = 2 .* exp(1.5 .* t);

            % Define a custom exponential model.
            userModel = UserModel();

            userModel.modelFunction = @(p, t) ...
                p(1) .* exp(p(2) .* t);

            userModel.initialParams = [1, 1];
            userModel.lb = [0, 0];
            userModel.ub = [10, 5];

            userModel.modelName = "My Exponential Model";
            userModel.description = "Custom exponential model";

            options = BaseOptions();

            [isDetected, howDetected] = detector.detectCustom( ...
                y, t, userModel, options);

            context = detector.getContext();

            testCase.verifyTrue(isDetected);

            testCase.verifyEqual( ...
                howDetected, 'My Exponential Model');

            testCase.verifyClass( ...
                context.options, 'CustomOptions');

            testCase.verifyEqual( ...
                context.params_fit, [2, 1.5], ...
                'AbsTol', 1e-3);

            testCase.verifyEqual(context.R2, 1, 'AbsTol', 1e-6);

            testCase.verifyEqual( ...
                detector.getLastEffectName(), ...
                'My Exponential Model');
        end

        function testGetContextBeforeAnalysis(testCase)
            % Verify that requesting the context before any analysis
            % raises the expected error.

            detector = EffectDetector();

            testCase.verifyError( ...
                @() detector.getContext(), ...
                'EffectDetector:NoAnalysisAvailable');
        end
    end
end