
classdef TestExpEffect < matlab.unittest.TestCase
    % TestExpEffect
    %
    % Unit test suite for the ExpEffect class.
    %
    % This class verifies the correct identification of exponential
    % signals and the robustness of the associated analysis pipeline.
    %
    % The test suite covers the following aspects:
    %   - Recognition of decreasing and increasing exponential signals.
    %   - Rejection of constant signals and signals with insufficient data.
    %   - Handling of non-finite signal and time samples.
    %   - Rejection of signals without valid finite samples.
    %   - Consistency of classification with optional plotting enabled.
    %   - Correct application of the R-squared acceptance threshold.
    %   - Handling of invalid parameter-fitting bounds.
    %
    % Each test method focuses on a specific expected behavior and
    % verifies the analysis outcome using MATLAB unit testing assertions.

    methods (Test)

        function testValidExponentialSignal(testCase)
            % Verifies that a decreasing exponential signal is correctly
            % identified by ExpEffect.
            %
            % The synthetic signal is generated according to the model
            % y(t) = A + B * exp(C * t), with a negative exponential rate.

            % Arrange: generate a decreasing exponential signal.
            t = (1:100)';
            y = 2 + 3 * exp(-0.01 * t);

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the signal must be classified as exponential.
            testCase.verifyTrue(result);
        end

        function testValidIncreasingExponentialSignal(testCase)
            % Verifies that ExpEffect correctly identifies an increasing
            % exponential signal.
            %
            % This test checks that the initial parameter estimation
            % supports positive as well as negative exponential rates.

            % Arrange: generate an increasing exponential signal.
            t = (1:100)';
            y = 2 + 3 * exp(0.01 * t);

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the signal must be classified as exponential.
            testCase.verifyTrue(result);
        end

        function testConstantSignal(testCase)
            % Verifies that a constant signal is not classified as
            % an exponential effect.

            % Arrange: generate a constant signal.
            t = (0:9)';
            y = 7 * ones(size(t));

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the constant signal must be rejected.
            testCase.verifyFalse(result);
        end

        function testInsufficientSamples(testCase)
            % Verifies that signals containing fewer than five samples
            % are rejected before model fitting.

            % Arrange: generate a signal with fewer than five samples.
            t = (0:3)';
            y = 2 + 5 * exp(-0.3 * t);

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the signal must be rejected.
            testCase.verifyFalse(result);
        end

        function testMinimumRequiredSamples(testCase)
            % Verifies that the minimum supported number of samples is
            % sufficient to perform exponential effect analysis.
            %
            % The test uses exactly five samples, corresponding to the
            % minimum sample count required by the analysis pipeline.

            % Arrange: generate an exponential signal with five samples.
            t = (0:4)';
            y = 2 + 5 * exp(-0.3 * t);

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the signal must be successfully classified.
            testCase.verifyTrue(result);
        end

        function testNaNSample(testCase)
            % Verifies that NaN signal samples are handled by the
            % preprocessing stage without preventing classification.
            %
            % The invalid sample and its corresponding time value are
            % expected to be excluded from the analysis.

            % Arrange: generate an exponential signal containing a NaN.
            t = (0:9)';
            y = 2 + 5 * exp(-0.3 * t);
            y(3) = NaN;

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the remaining valid samples must be sufficient.
            testCase.verifyTrue(result);
        end

        function testInfSample(testCase)
            % Verifies that infinite signal samples are handled by the
            % preprocessing stage without preventing classification.

            % Arrange: generate an exponential signal containing Inf.
            t = (0:9)';
            y = 2 + 5 * exp(-0.3 * t);
            y(7) = Inf;

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the remaining valid samples must be sufficient.
            testCase.verifyTrue(result);
        end

        function testNonFiniteTime(testCase)
            % Verifies that non-finite time samples and their
            % corresponding signal samples are excluded during
            % preprocessing.

            % Arrange: generate an exponential signal with a NaN time.
            t = (0:9)';
            y = 2 + 5 * exp(-0.3 * t);
            t(3) = NaN;

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the remaining valid samples must be sufficient.
            testCase.verifyTrue(result);
        end

        function testSignalWithoutFiniteSamples(testCase)
            % Verifies that a signal containing no finite samples is
            % rejected because no valid data is available for fitting.

            % Arrange: generate a signal containing only NaN values.
            t = (0:9)';
            y = NaN(size(t));

            % Act: execute the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            result = effect.analyze(y, t);

            % Assert: the analysis must reject the signal.
            testCase.verifyFalse(result);
        end

        function testPlottingDoesNotChangeResult(testCase)
            % Verifies that enabling optional plotting does not affect
            % the numerical outcome of exponential effect classification.
            %
            % The same signal is analyzed with plotting disabled and
            % enabled. Both executions are expected to produce the
            % same classification result.

            % Arrange: generate a valid exponential signal.
            t = (0:9)';
            y = 2 + 5 * exp(-0.3 * t);

            opt = ExpOptions();
            effect = ExpEffect();
            effect.setOptions(opt);

            % Act: analyze the signal with plotting disabled.
            opt.showPlot = false;
            resultWithoutPlot = effect.analyze(y, t);

            % Act: analyze the same signal with plotting enabled.
            opt.showPlot = true;
            resultWithPlot = effect.analyze(y, t);

            % Assert: plotting must not change the classification.
            testCase.verifyEqual(resultWithPlot, resultWithoutPlot);
            testCase.verifyTrue(resultWithPlot);
        end

        function testR2EqualToThreshold(testCase)
            % Verifies that an R-squared value equal to the configured
            % threshold is not sufficient to accept an exponential effect.
            %
            % This test checks the strict acceptance condition used by
            % PostCheckTask: R-squared must be greater than the threshold.

            % Arrange: create a context with R-squared equal to the threshold.
            opt = ExpOptions();
            context = EffectContext(zeros(5, 1), (0:4)', opt);
            context.R2 = opt.threshold;

            % Act: execute the goodness-of-fit post-check.
            postCheck = PostCheckTask();
            taskOk = postCheck.execute(context);

            % Assert: the task executes successfully, but rejects the effect.
            testCase.verifyTrue(taskOk);
            testCase.verifyFalse(context.result);
        end

        function testInvalidFittingBounds(testCase)
            % Verifies that invalid fitting bounds cause the exponential
            % effect analysis to fail gracefully.
            %
            % The lower bounds are deliberately configured above the
            % upper bounds. The analysis must reject the fitting
            % configuration without propagating an exception.

            % Arrange: configure incompatible parameter bounds.
            opt = ExpOptions();
            opt.lb = [1, 1, 1];
            opt.ub = [-1, -1, -1];

            effect = ExpEffect();
            effect.setOptions(opt);

            % Generate a valid exponential signal for the analysis.
            t = (0:9)';
            y = 2 + 5 * exp(-0.3 * t);

            % Act: execute the exponential effect analysis.
            result = effect.analyze(y, t);

            % Assert: invalid bounds must cause a graceful rejection.
            testCase.verifyFalse(result);
        end

    end
end
