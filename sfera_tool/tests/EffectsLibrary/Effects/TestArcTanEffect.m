classdef TestArcTanEffect < matlab.unittest.TestCase
    % TestArcTanEffect
    %
    % Unit test suite for the ArcTanEffect class.
    %
    % This class verifies the correct identification of arc-tangent
    % signals and the behavior of the associated analysis pipeline.
    %
    % The test suite covers the following aspects:
    %   - Recognition of valid arc-tangent signals.
    %   - Rejection of signals with insufficient samples or curvature.
    %   - Handling of non-finite signal and time samples.
    %   - Validation of the fitted model amplitude.
    %   - Preservation of rejection decisions made by previous tasks.
    %   - Consistency of classification with optional plotting enabled.
    %
    % Some tests exercise the complete effect analysis, while others
    % directly verify the behavior of ArcTanPostCheckTask.
    %
    % Each test method focuses on a specific expected behavior and
    % verifies the outcome using MATLAB unit testing assertions.

    methods (Test)

        function testValidSignal(testCase)
            % Verifies that a valid arc-tangent signal is correctly
            % identified by ArcTanEffect.
            %
            % The synthetic signal is generated according to the model:
            % y(t) = A * atan((t - H) / C) + D.

            % Arrange: generate a valid arc-tangent signal.
            t = linspace(0, 1, 30)';
            y = 2 * atan((t - 0.5) / 0.2) + 1;

            % Act: execute the arc-tangent effect analysis.
            effect = ArcTanEffect();
            effect.setOptions(ArcTanOptions());
            result = effect.analyze(y, t);

            % Assert: the signal must be classified as an arc-tangent effect.
            testCase.verifyTrue(result);
        end

        function testInsufficientSamples(testCase)
            % Verifies that signals containing fewer than five samples
            % are rejected before model fitting.

            % Arrange: generate an arc-tangent signal with four samples.
            t = linspace(0, 1, 4)';
            y = 2 * atan((t - 0.5) / 0.2) + 1;

            % Act: execute the arc-tangent effect analysis.
            effect = ArcTanEffect();
            effect.setOptions(ArcTanOptions());
            result = effect.analyze(y, t);

            % Assert: the signal must be rejected.
            testCase.verifyFalse(result);
        end

        function testInsufficientCurvature(testCase)
            % Verifies that a linear signal is rejected by the curvature
            % pre-check because it does not exhibit sufficient curvature
            % to be considered an arc-tangent effect.

            % Arrange: generate a linear signal.
            t = linspace(0, 1, 30)';
            y = 2 * t + 1;

            % Act: execute the arc-tangent effect analysis.
            effect = ArcTanEffect();
            effect.setOptions(ArcTanOptions());
            result = effect.analyze(y, t);

            % Assert: the signal must fail the curvature pre-check.
            testCase.verifyFalse(result);
        end

        function testNonFiniteSamples(testCase)
            % Verifies that non-finite signal and time samples are handled
            % by preprocessing without preventing classification.
            %
            % Invalid samples are expected to be removed together with
            % their corresponding time values.

            % Arrange: generate an arc-tangent signal with invalid samples.
            t = linspace(0, 1, 30)';
            y = 2 * atan((t - 0.5) / 0.2) + 1;

            y(5) = NaN;
            y(10) = Inf;
            t(15) = NaN;
            t(20) = Inf;

            % Act: execute the arc-tangent effect analysis.
            effect = ArcTanEffect();
            effect.setOptions(ArcTanOptions());
            result = effect.analyze(y, t);

            % Assert: the remaining valid samples must allow classification.
            testCase.verifyTrue(result);
        end

        function testInsufficientAmplitude(testCase)
            % Verifies that ArcTanPostCheckTask rejects a fitted model
            % whose amplitude is insufficient relative to the signal range.
            %
            % The context is initialized with a successful previous result
            % so that the amplitude validation can be tested independently.

            % Arrange: create a context with a signal range of two.
            t = linspace(0, 1, 30)';
            y = linspace(-1, 1, 30)';

            opt = ArcTanOptions();
            context = EffectContext(y, t, opt);

            % Simulate fitted parameters with insufficient amplitude.
            context.params_fit = [0.1, 0.5, 0.2, 0];
            context.result = true;

            % Act: execute the arc-tangent post-check.
            task = ArcTanPostCheckTask();
            taskOk = task.execute(context);

            % Assert: the task must complete, but reject the fitted model.
            testCase.verifyTrue(taskOk);
            testCase.verifyFalse(context.result);
        end

        function testPreviousRejectionPreserved(testCase)
            % Verifies that ArcTanPostCheckTask preserves a rejection
            % performed by an earlier task in the analysis pipeline.
            %
            % The fitted amplitude is deliberately sufficient to pass
            % the amplitude check. Nevertheless, the previous rejection
            % must remain unchanged.

            % Arrange: create a context already marked as rejected.
            t = linspace(0, 1, 30)';
            y = linspace(-1, 1, 30)';

            opt = ArcTanOptions();
            context = EffectContext(y, t, opt);
            context.result = false;

            % Simulate fitted parameters with sufficient amplitude.
            context.params_fit = [1, 0.5, 0.2, 0];

            % Act: execute the arc-tangent post-check.
            task = ArcTanPostCheckTask();
            taskOk = task.execute(context);

            % Assert: the task completes without restoring acceptance.
            testCase.verifyTrue(taskOk);
            testCase.verifyFalse(context.result);
        end

        function testPlottingDoesNotChangeResult(testCase)
            % Verifies that enabling optional plotting does not affect
            % the numerical outcome of arc-tangent effect classification.
            %
            % The same signal is analyzed independently with plotting
            % disabled and enabled. Both executions must produce the
            % same successful classification.

            % Arrange: generate a valid arc-tangent signal.
            t = linspace(0, 1, 30)';
            y = 2 * atan((t - 0.5) / 0.2) + 1;

            % Configure the first effect with plotting disabled.
            optWithoutPlot = ArcTanOptions();
            optWithoutPlot.showPlot = false;

            effectWithoutPlot = ArcTanEffect();
            effectWithoutPlot.setOptions(optWithoutPlot);

            % Act: analyze the signal without plotting.
            resultWithoutPlot = effectWithoutPlot.analyze(y, t);

            % Configure the second effect with plotting enabled.
            optWithPlot = ArcTanOptions();
            optWithPlot.showPlot = true;

            effectWithPlot = ArcTanEffect();
            effectWithPlot.setOptions(optWithPlot);

            % Act: analyze the same signal with plotting enabled.
            resultWithPlot = effectWithPlot.analyze(y, t);

            % Assert: plotting must not change the classification.
            testCase.verifyEqual(resultWithPlot, resultWithoutPlot);
            testCase.verifyTrue(resultWithPlot);
        end

    end
end
