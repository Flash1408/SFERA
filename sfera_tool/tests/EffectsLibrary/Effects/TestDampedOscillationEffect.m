classdef TestDampedOscillationEffect < matlab.unittest.TestCase
    % TestDampedOscillationEffect
    %
    % Unit tests for the DampedOscillationEffect implementation.
    %
    % The test suite verifies:
    %   - Recognition of valid damped oscillation signals.
    %   - Rejection of signals with insufficient samples or peaks.
    %   - Handling of non-finite signal and time samples.
    %   - Validation of fitted model parameters.
    %   - Independence of numerical results from plotting.
    %   - Preservation of rejection decisions made by previous tasks.
    %
    % Each test follows the Arrange-Act-Assert structure.

    methods (Test)

        function testValidSignal(testCase)
            % Verify that a valid damped oscillation is recognized.

            % Arrange: generate a synthetic damped oscillation.
            t = (1:800)';

            A = 5;
            beta = -0.0012;
            omega = 0.5;
            phi = 0.2;
            C = 0;

            y = A * exp(beta * t) .* cos(omega * t + phi) + C;

            opt = DampedOscillationOptions();

            effect = DampedOscillationEffect();
            effect.setOptions(opt);

            % Act: analyze the signal.
            result = effect.analyze(y, t);

            % Assert: the signal should be recognized.
            testCase.verifyTrue(result);
        end


        function testInsufficientSamples(testCase)
            % Verify that signals with fewer than five samples are rejected.

            % Arrange: generate a signal with only four samples.
            t = (1:4)';
            y = 5 * exp(-0.0012 * t) .* cos(0.5 * t + 0.2);

            opt = DampedOscillationOptions();

            effect = DampedOscillationEffect();
            effect.setOptions(opt);

            % Act: analyze the signal.
            result = effect.analyze(y, t);

            % Assert: preprocessing should reject the signal.
            testCase.verifyFalse(result);
        end


        function testInsufficientPeaks(testCase)
            % Verify that signals with fewer than three valid peaks
            % are rejected by the damped oscillation pre-check.

            % Arrange: generate a signal containing one significant peak.
            t = (1:200)';
            y = exp(-((t - 100) / 15).^2);

            opt = DampedOscillationOptions();

            effect = DampedOscillationEffect();
            effect.setOptions(opt);

            % Act: analyze the signal.
            result = effect.analyze(y, t);

            % Assert: the signal should not be classified as
            % a damped oscillation.
            testCase.verifyFalse(result);
        end


        function testNonFiniteSamples(testCase)
            % Verify that preprocessing removes non-finite paired samples
            % before the damped oscillation analysis is performed.

            % Arrange: generate a valid damped oscillation.
            t = (1:800)';
            y = 5 * exp(-0.0012 * t) .* cos(0.5 * t + 0.2);

            % Introduce invalid signal and time samples.
            y(5) = NaN;
            y(10) = Inf;
            t(15) = NaN;
            t(20) = Inf;

            opt = DampedOscillationOptions();

            effect = DampedOscillationEffect();
            effect.setOptions(opt);

            % Act: analyze the signal containing non-finite samples.
            result = effect.analyze(y, t);

            % Assert: the remaining valid samples should still allow
            % recognition of the damped oscillation.
            testCase.verifyTrue(result);
        end


        function testInvalidFittedParameters(testCase)
            % Verify that the post-check rejects fitted models whose
            % parameters do not satisfy the damped oscillation criteria.
            %
            % Three independent conditions are tested:
            %   1. Insufficient fitted amplitude.
            %   2. Non-negative damping coefficient.
            %   3. Insufficient angular frequency.

            % Arrange: create a signal and configure the post-check task.
            t = (1:100)';
            y = linspace(-5, 5, 100)';

            opt = DampedOscillationOptions();
            task = DampedOscillationPostCheckTask();

            % Case 1: insufficient fitted amplitude.
            context = EffectContext(y, t, opt);
            context.params_fit = [0.1, -0.1, 1, 0, 0];
            context.result = true;

            % Act: execute the post-check.
            taskOk = task.execute(context);

            % Assert: the task completes, but rejects the fitted model.
            testCase.verifyTrue(taskOk);

            testCase.verifyFalse(context.result);

            % Case 2: non-negative damping coefficient.
            context = EffectContext(y, t, opt);
            context.params_fit = [1, 0, 1, 0, 0];
            context.result = true;

            % Act: execute the post-check.
            taskOk = task.execute(context);

            % Assert: the fitted model should be rejected.
            testCase.verifyTrue(taskOk);

            testCase.verifyFalse(context.result);

            % Case 3: insufficient angular frequency.
            context = EffectContext(y, t, opt);
            context.params_fit = [1, -0.1, 0.4, 0, 0];
            context.result = true;

            % Act: execute the post-check.
            taskOk = task.execute(context);

            % Assert: the fitted model should be rejected.
            testCase.verifyTrue(taskOk);

            testCase.verifyFalse(context.result);
        end


        function testPlottingDoesNotChangeResult(testCase)
            % Verify that enabling plotting does not change the
            % numerical result of the damped oscillation analysis.

            % Arrange: generate a valid damped oscillation.
            t = (1:800)';
            y = 5 * exp(-0.0012 * t) .* cos(0.5 * t + 0.2);

            % Keep track of figures that already exist, so this test
            % only closes figures created during its execution.
            existingFigures = findall(groot, 'Type', 'figure');
            cleanup = onCleanup(@() close(setdiff( ...
                findall(groot, 'Type', 'figure'), existingFigures)));

            % Analyze the signal without plotting.
            opt1 = DampedOscillationOptions();
            opt1.showPlot = false;

            effect1 = DampedOscillationEffect();
            effect1.setOptions(opt1);

            resultWithoutPlot = effect1.analyze(y, t);

            % Analyze the same signal with plotting enabled.
            opt2 = DampedOscillationOptions();
            opt2.showPlot = true;

            effect2 = DampedOscillationEffect();
            effect2.setOptions(opt2);

            resultWithPlot = effect2.analyze(y, t);

            % Assert: plotting must not affect the numerical result.
            testCase.verifyEqual(resultWithPlot, resultWithoutPlot);

            testCase.verifyTrue(resultWithoutPlot);

            % The cleanup object closes only figures created by this test.
            clear cleanup;
        end


        function testPreviousRejectionPreserved(testCase)
            % Verify that the post-check does not override a rejection
            % produced by an earlier analysis task.

            % Arrange: create an analysis context.
            t = (1:100)';
            y = linspace(-5, 5, 100)';

            opt = DampedOscillationOptions();
            context = EffectContext(y, t, opt);

            % Simulate a rejection made by a previous task.
            context.result = false;

            % Use parameters that would otherwise pass the post-check.
            context.params_fit = [1, -0.1, 1, 0, 0];

            task = DampedOscillationPostCheckTask();

            % Act: execute the post-check.
            taskOk = task.execute(context);

            % Assert: the task completes but preserves the rejection.
            testCase.verifyTrue(taskOk);

            testCase.verifyFalse(context.result);
        end

    end
end
