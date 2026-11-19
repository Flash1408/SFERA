classdef TestMultiSinusoidsEffect < matlab.unittest.TestCase
    % TestMultiSinusoidsEffect
    %
    % Unit test suite for the MultiSinusoidsEffect class.
    %
    % This test suite verifies the correct identification of signals
    % composed of multiple sinusoidal components and the behavior
    % of the associated analysis pipeline.
    %
    % The test suite covers the following aspects:
    %   - Recognition of signals composed of two sinusoidal components.
    %   - Recognition of signals composed of three sinusoidal components.
    %   - Rejection of constant signals.
    %   - Rejection of non-sinusoidal signals.
    %   - Handling of signals with insufficient samples.
    %   - Handling of signals containing non-finite samples.

    methods (Test)

        function testValidTwoSinusoids(testCase)
            % TESTVALIDTWOSINUSOIDS Verify recognition of two sinusoids.
            %
            % The test generates a signal composed of two sinusoidal
            % components and verifies that the effect correctly
            % identifies the signal.

            % Arrange
            effect = MultiSinusoidsEffect();

            opt = MultiSinusoidsOptions();
            opt.N = 2;

            effect.setOptions(opt);

            t = linspace(0, 1, 500)';

            y = 2*cos(2*pi*t) + ...
                1.5*cos(4*pi*t) + 3;

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyTrue(result);
            testCase.verifyGreaterThan(context.R2, opt.threshold);
            testCase.verifyGreaterThan(context.fitExitFlag, 0);
            testCase.verifyEqual(context.fitError, "");
        end

        function testValidThreeSinusoids(testCase)
            % TESTVALIDTHREESINUSOIDS Verify recognition of three sinusoids.
            %
            % The test generates a signal composed of three sinusoidal
            % components and verifies that the effect correctly
            % identifies the signal using three model components.

            % Arrange
            effect = MultiSinusoidsEffect();

            opt = MultiSinusoidsOptions();
            opt.N = 3;

            effect.setOptions(opt);

            t = linspace(0, 1, 1000)';

            y = 2*cos(2*pi*t) + ...
                1.5*cos(4*pi*t) + ...
                0.8*cos(6*pi*t) + 3;

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyTrue(result);
            testCase.verifyGreaterThan(context.R2, opt.threshold);
            testCase.verifyGreaterThan(context.fitExitFlag, 0);
            testCase.verifyEqual(context.fitError, "");
        end

        function testConstantSignal(testCase)
            % TESTCONSTANTSIGNAL Verify rejection of constant signals.
            %
            % The test verifies that a signal without oscillatory
            % components is not classified as a multi-sinusoid effect.

            % Arrange
            effect = MultiSinusoidsEffect();

            opt = MultiSinusoidsOptions();
            opt.N = 2;

            effect.setOptions(opt);

            t = linspace(0, 1, 500)';
            y = 3 * ones(size(t));

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyFalse(result);
            testCase.verifyTrue(isnan(context.R2));
        end

        function testNonSinusoidalSignal(testCase)
            % TESTNONSINUSOIDALSIGNAL Verify rejection of non-sinusoidal signals.
            %
            % The test generates a deterministic random signal and
            % verifies that it is not classified as a multi-sinusoid
            % effect.

            % Arrange
            effect = MultiSinusoidsEffect();

            opt = MultiSinusoidsOptions();
            opt.N = 2;

            effect.setOptions(opt);

            t = linspace(0, 1, 500)';

            previousRngState = rng;
            cleanup = onCleanup(@() rng(previousRngState));

            rng(1, 'twister');
            y = randn(size(t));

            % Act
            result = effect.analyze(y, t);

            % Assert
            testCase.verifyFalse(result);

            clear cleanup
        end

        function testInsufficientSamples(testCase)
            % TESTINSUFFICIENTSAMPLES Verify handling of short signals.
            %
            % The test verifies that signals containing fewer than
            % the minimum required number of samples are rejected.

            % Arrange
            effect = MultiSinusoidsEffect();

            opt = MultiSinusoidsOptions();
            opt.N = 2;

            effect.setOptions(opt);

            t = (1:4)';
            y = cos(2*pi*t);

            % Act
            result = effect.analyze(y, t);

            % Assert
            testCase.verifyFalse(result);
        end

        function testNonFiniteSamples(testCase)
            % TESTNONFINITESAMPLES Verify handling of non-finite samples.
            %
            % The test inserts NaN and Inf values into an otherwise
            % valid multi-sinusoid signal.
            %
            % The preprocessing task should remove the invalid samples
            % while preserving enough valid data for the analysis.

            % Arrange
            effect = MultiSinusoidsEffect();

            opt = MultiSinusoidsOptions();
            opt.N = 2;

            effect.setOptions(opt);

            t = linspace(0, 1, 500)';

            y = 2*cos(2*pi*t) + ...
                1.5*cos(4*pi*t) + 3;

            y(50) = NaN;
            y(100) = Inf;

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyTrue(result);
            testCase.verifyGreaterThan(context.R2, opt.threshold);
        end
    end
end
